use std::path::Path;

use async_std::fs;
use async_std::io::BufReader;
use async_std::prelude::*;

use futures::channel::mpsc;
use futures::sink::SinkExt;
use futures::stream::{self, TryStreamExt, StreamExt};
use walkdir::WalkDir;

use meili_crates::{chunk_crates_to_meili, retrieve_crate_toml, CrateInfo};

async fn process_file(entry: walkdir::DirEntry) -> Result<Option<CrateInfo>, surf::Exception> {
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
) -> Result<(), surf::Exception>
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
