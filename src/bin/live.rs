use std::io::BufReader;

use atom_syndication::Feed;
use futures::channel::mpsc;
use futures::sink::SinkExt;
use futures::stream::{self, StreamExt};

use meili_crates::{chunk_crates_to_meili, retrieve_crate_toml, CrateInfo};

async fn crates_infos(mut sender: mpsc::Sender<CrateInfo>) -> Result<(), surf::Exception> {
    let body = surf::get("https://docs.rs/releases/feed").recv_bytes().await?;
    let feed = Feed::read_from(BufReader::new(body.as_slice())).unwrap();

    for entry in feed.entries() {
        // urn:docs-rs:hello_exercism:0.2.8
        let name = match entry.id().split(':').nth(2) {
            Some(name) => name.to_string(),
            None => continue,
        };

        let vers = match entry.id().split(':').nth(3) {
            Some(vers) => vers.to_string(),
            None => continue,
        };

        let info = CrateInfo { name, vers };

        if let Err(e) = sender.send(info).await {
            eprintln!("{}", e);
        }
    }

    Ok(())
}

#[runtime::main]
async fn main() -> Result<(), surf::Exception> {
    let (infos_sender, infos_receiver) = mpsc::channel(100);
    let (cinfos_sender, cinfos_receiver) = mpsc::channel(100);

    let retrieve_handler = runtime::spawn(async {
        crates_infos(infos_sender).await
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
