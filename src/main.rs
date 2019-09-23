use std::ffi::OsStr;
use std::io::Read;
use std::path::Path;

use async_std::fs;
use async_std::io::BufReader;
use async_std::prelude::*;

use futures::sink::SinkExt;
use futures::stream::{TryStreamExt, StreamExt};
use futures::channel::mpsc;

use cargo_toml::Manifest;
use flate2::read::GzDecoder;
use serde::{Serialize, Deserialize};
use tar::Archive;
use walkdir::WalkDir;

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
    for res in WalkDir::new(crates_io_index).contents_first(true) {
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
    version: String,
    description: String,
}

async fn retrieve_crate_toml(info: CrateInfo) -> Result<CompleteCrateInfos, surf::Exception> {
    let url = format!(
        "https://static.crates.io/crates/{name}/{name}-{version}.crate",
        name = info.name,
        version = info.vers
    );

    eprintln!("downloading {}", url);
    let mut res = surf::get(url).await?;
    // TODO retry downloads

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
            let complete_infos = CompleteCrateInfos {
                name: info.name,
                version: info.vers,
                description
            };

            println!("{:?}", complete_infos);

            return Ok(complete_infos)
        }
    }

    Err(String::from("No Cargo.toml found in this crate").into())
}

// git clone --depth=1 https://github.com/rust-lang/crates.io-index.git
// https://static.crates.io/crates/{crate}/{crate}-{version}.crate

#[runtime::main]
async fn main() -> Result<(), surf::Exception> {
    let (sender, receiver) = mpsc::channel(100);
    let handler = runtime::spawn(async { crates_infos(sender, "../crates.io-index/").await });

    receiver.for_each_concurrent(None, |info| async move {
        if let Err(e) = retrieve_crate_toml(info).await {
            eprintln!("{}", e);
        }
    })
    .await;

    handler.await
}
