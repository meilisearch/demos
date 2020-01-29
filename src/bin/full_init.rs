use std::env;
use std::path::Path;

use async_std::task;
use async_std::fs;
use async_std::io::BufReader;
use async_std::prelude::*;

use futures::channel::mpsc;
use futures::sink::SinkExt;
use futures::stream::{self, TryStreamExt, StreamExt};
use walkdir::WalkDir;
use isahc::prelude::*;

use meili_crates::{chunk_complete_crates_info_to_meili, retrieve_crate_toml, CrateInfo, Result};
use meili_crates::{MEILI_API_KEY, MEILI_INDEX_NAME, MEILI_PROJECT_NAME};

async fn process_file(entry: walkdir::DirEntry) -> Result<Option<CrateInfo>> {
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
            None => return Ok(None),
        };

        let info: CrateInfo = match serde_json::from_str(&last_line) {
            Ok(info) => info,
            Err(_) => return Ok(None),
        };

        return Ok(Some(info));
    }

    Ok(None)
}

async fn crates_infos<P: AsRef<Path>>(
    mut sender: mpsc::Sender<CrateInfo>,
    crates_io_index: P,
) -> Result<()>
{
    let walkdir = WalkDir::new(crates_io_index)
                        .max_open(1)
                        .contents_first(true);

    for result in walkdir {
        let entry = match result {
            Ok(entry) => entry,
            Err(e) => { eprintln!("{}", e); continue },
        };

        match process_file(entry).await {
            Ok(Some(info)) => {
                if let Err(e) = sender.send(info).await {
                    eprintln!("{}", e);
                }
            },
            Ok(None) => (),
            Err(e) => eprintln!("{}", e),
        }
    }

    Ok(())
}

async fn init_index_schema() -> Result<()> {
    let api_key = env::var(MEILI_API_KEY).expect(MEILI_API_KEY);
    let index_name = env::var(MEILI_INDEX_NAME).expect(MEILI_INDEX_NAME);
    let project_name = env::var(MEILI_PROJECT_NAME).expect(MEILI_PROJECT_NAME);

    let url = format!("https://{project_name}.getmeili.com/indexes/{index_name}",
        project_name = project_name,
        index_name = index_name,
    );

    let schema = r#"{
        "name":         ["identifier", "displayed", "indexed"],
        "description":  [              "displayed", "indexed"],
        "keywords":     [              "displayed", "indexed"],
        "categories":   [              "displayed", "indexed"],
        "readme":       [              "displayed", "indexed"],
        "version":      [              "displayed"           ],
        "downloads":    [              "displayed",  "ranked"]
    }"#;

    let client = HttpClient::new()?;
    let request = Request::post(url)
        .header("X-Meili-API-Key", &api_key)
        .header("Content-Type", "application/json")
        .body(schema)?;

    let mut res = client.send_async(request).await?;
    let res = res.text()?;
    eprintln!("{}", res);

    Ok(())
}

async fn init_index_browse_key() -> Result<()> {
    let api_key = env::var(MEILI_API_KEY).expect(MEILI_API_KEY);
    let project_name = env::var(MEILI_PROJECT_NAME).expect(MEILI_PROJECT_NAME);

    let url = format!("https://{project_name}.getmeili.com/keys",
        project_name = project_name,
    );

    let key = r#"{
        "description": "Browse documents",
        "acl": ["documentsRead"],
        "indexes": ["*"],
        "expiresAt": 1636293235
    }"#;

    let client = HttpClient::new()?;
    let request = Request::post(url)
        .header("X-Meili-API-Key", &api_key)
        .header("Content-Type", "application/json")
        .body(key)?;

    let mut res = client.send_async(request).await?;
    let res = res.text()?;
    eprintln!("{}", res);

    Ok(())
}

// git clone --depth=1 https://github.com/rust-lang/crates.io-index.git
// https://static.crates.io/crates/{crate}/{crate}-{version}.crate

fn main() -> Result<()> {
    task::block_on(async {
        let (infos_sender, infos_receiver) = mpsc::channel(1000);
        let (cinfos_sender, cinfos_receiver) = mpsc::channel(1000);

        init_index_schema().await?;
        init_index_browse_key().await?;

        let retrieve_handler = task::spawn(async {
            crates_infos(infos_sender, "crates.io-index/").await
        });

        let publish_handler = task::spawn(async {
            chunk_complete_crates_info_to_meili(cinfos_receiver).await
        });

        let retrieve_toml = StreamExt::zip(infos_receiver, stream::repeat(cinfos_sender))
            .for_each_concurrent(Some(64), |(info, mut sender)| {
                task::spawn(async move {
                    match retrieve_crate_toml(&info).await {
                        Ok(cinfo) => sender.send(cinfo).await.unwrap(),
                        Err(e) => eprintln!("{:?} {}", info, e),
                    }
                })
            });

        retrieve_toml.await;
        retrieve_handler.await?;
        publish_handler.await?;

        Ok(())
    })
}
