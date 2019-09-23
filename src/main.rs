use std::env;
use std::ffi::OsStr;
use std::io::Read;
use std::path::Path;
use std::time::Duration;

use async_std::fs;
use async_std::io::BufReader;
use async_std::prelude::*;

use futures::sink::SinkExt;
use futures::stream::{self, TryStreamExt, StreamExt};
use futures::channel::mpsc;
use futures_timer::Delay;

use cargo_toml::Manifest;
use flate2::read::GzDecoder;
use serde::{Serialize, Deserialize};
use tar::Archive;
use walkdir::WalkDir;

mod backoff;

#[derive(Debug, Deserialize)]
struct CrateInfo {
    name: String,
    vers: String,
}

async fn crates_infos<P: AsRef<Path>>(
    mut sender: mpsc::Sender<CrateInfo>,
    crates_io_index: P,
) -> Result<(), surf::Exception>
{
    let walkdir = WalkDir::new(crates_io_index)
                        .max_open(1)
                        .contents_first(true);

    for res in walkdir {
        let entry = res?;
        if entry.file_type().is_file() {
            let file = fs::File::open(entry.path()).await?;
            let file = BufReader::new(file);
            let mut lines = file.lines();

            let mut last = None;
            while let Some(line) = lines.try_next().await? {
                last = Some(line);
            }

            let last_line = match last {
                Some(line) => line,
                None => continue,
            };

            let info: CrateInfo = match serde_json::from_str(&last_line) {
                Ok(info) => info,
                Err(_) => continue,
            };

            sender.send(info).await?;
        }
    }

    Ok(())
}

#[derive(Debug, Serialize)]
struct CompleteCrateInfos {
    name: String,
    description: String,
    keywords: Vec<String>,
    categories: Vec<String>,

    version: String,
    id: String,
}

async fn retrieve_crate_toml(
    info: &CrateInfo,
) -> Result<CompleteCrateInfos, surf::Exception>
{
    let url = format!(
        "https://static.crates.io/crates/{name}/{name}-{version}.crate",
        name = info.name,
        version = info.vers,
    );

    let mut result = None;
    for multiplier in backoff::new().take(10) {
        match surf::get(&url).await {
            Ok(res) => { result = Some(res); break },
            Err(e) => {
                let dur = Duration::from_secs(1) * (multiplier + 1);
                eprintln!("error downloading {} {} retrying in {:.2?}", url, e, dur);
                let _ = Delay::new(dur).await;
            },
        }
    }

    let mut res = match result {
        Some(res) => res,
        None => return Err(format!("Could not download {}", url).into()),
    };

    if !res.status().is_success() {
        let body = res.body_string().await?;
        return Err(format!("{}", body).into());
    }

    let body = res.body_bytes().await?;

    let gz = GzDecoder::new(body.as_slice());
    let mut tar = Archive::new(gz);

    for res in tar.entries()? {
        let mut entry = res?;
        let path = entry.path()?;
        if path.file_name() == Some(OsStr::new("Cargo.toml")) {
            let mut content = Vec::new();
            entry.read_to_end(&mut content)?;

            let manifest = Manifest::from_slice(&content)?;
            let package = match manifest.package {
                Some(package) => package,
                None => break,
            };

            let description = package.description.unwrap_or_default();
            let keywords = package.keywords;
            let categories = package.categories;

            let complete_infos = CompleteCrateInfos {
                name: info.name.clone(),
                description,
                keywords,
                categories,
                version: info.vers.clone(),
                id: info.name.clone(),
            };

            return Ok(complete_infos)
        }
    }

    Err(String::from("No Cargo.toml found in this crate").into())
}

async fn chunk_crates_to_meili(
    receiver: mpsc::Receiver<CompleteCrateInfos>,
) -> Result<(), surf::Exception>
{
    let api_key = env::var("MEILI_API_KEY").expect("MEILI_API_KEY");
    let index_name = env::var("MEILI_INDEX_NAME").expect("MEILI_INDEX_NAME");

    let mut receiver = receiver.chunks(50);
    while let Some(chunk) = StreamExt::next(&mut receiver).await {
        let url = format!("https://{name}.getmeili.com/indexes/{name}/documents", name = index_name);
        let res = surf::post(url)
                    .set_header("X-Meili-API-Key", &api_key)
                    .body_json(&chunk)?
                    .recv_string()
                    .await?;

        println!("{}", res);
    }

    Ok(())
}

// git clone --depth=1 https://github.com/rust-lang/crates.io-index.git
// https://static.crates.io/crates/{crate}/{crate}-{version}.crate

#[runtime::main]
async fn main() -> Result<(), surf::Exception> {
    let (infos_sender, infos_receiver) = mpsc::channel(100);
    let (cinfos_sender, cinfos_receiver) = mpsc::channel(100);

    let retrieve_handler = runtime::spawn(async {
        crates_infos(infos_sender, "../crates.io-index/").await
    });

    let publish_handler = runtime::spawn(async {
        chunk_crates_to_meili(cinfos_receiver).await
    });

    StreamExt::zip(infos_receiver, stream::repeat(cinfos_sender))
        .for_each_concurrent(Some(8), |(info, mut sender)| async move {
        match retrieve_crate_toml(&info).await {
            Ok(cinfo) => sender.send(cinfo).await.unwrap(),
            Err(e) => eprintln!("{:?} {}", info, e),
        }
    })
    .await;

    retrieve_handler.await?;
    publish_handler.await?;

    Ok(())
}
