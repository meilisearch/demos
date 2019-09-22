use async_std::fs;
use async_std::io::BufReader;
use async_std::prelude::*;
use futures::stream::TryStreamExt;

use walkdir::WalkDir;
use serde::Deserialize;
use flate2::read::GzDecoder;
use tar::Archive;

#[derive(Debug, Deserialize)]
struct CrateInfo<'a> {
    name: &'a str,
    vers: &'a str,
}

// git clone --depth=1 https://github.com/rust-lang/crates.io-index.git
// https://static.crates.io/crates/{crate}/{crate}-{version}.crate

#[runtime::main]
async fn main() -> Result<(), surf::Exception> {

    let entries = WalkDir::new("../crates.io-index/");
    let mut count = 2;

    for res in entries {
        let entry = res?;
        let type_ = entry.file_type();

        if type_.is_file() {
            if count == 0 { break }
            count -= 1;

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

            let url = format!(
                "https://static.crates.io/crates/{name}/{name}-{version}.crate",
                name = info.name,
                version = info.vers
            );

            println!("downloading {}", url);
            let mut res = surf::get(url).await?;
            println!("res: {:?}", res);

            if !res.status().is_success() {
                let body = res.body_string().await?;
                eprintln!("{}", body);
                continue
            }

            let body = res.body_bytes().await?;

            let gz = GzDecoder::new(body.as_slice());
            let mut tar = Archive::new(gz);

            for res in tar.entries()? {
                let entry = res?;
                let path = entry.path()?;
                println!("{:?}", path);
            }
        }
    }

    Ok(())
}
