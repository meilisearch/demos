use std::env;
use std::error::Error;
use std::ffi::OsStr;
use std::io::Read;
use std::time::Duration;

use futures::channel::mpsc;
use futures::stream::StreamExt;
use futures_timer::Delay;

use cargo_toml::Manifest;
use flate2::read::GzDecoder;
use isahc::prelude::*;
use serde::{Serialize, Deserialize};
use tar::Archive;

pub const MEILI_PROJECT_NAME: &str = "MEILI_PROJECT_NAME";
pub const MEILI_INDEX_NAME: &str = "MEILI_INDEX_NAME";
pub const MEILI_API_KEY: &str = "MEILI_API_KEY";

pub mod backoff;

pub type Result<T> = std::result::Result<T, Box<dyn Error + Send + Sync>>;

#[derive(Debug, Deserialize)]
pub struct CrateInfo {
    pub name: String,
    pub vers: String,
}

#[derive(Debug, Serialize)]
pub struct CompleteCrateInfos {
    pub name: String,
    pub description: String,
    pub keywords: Vec<String>,
    pub categories: Vec<String>,
    pub version: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct DownloadsCrateInfos {
    pub name: String,
    downloads: u64,
}

pub async fn retrieve_crate_toml(info: &CrateInfo) -> Result<CompleteCrateInfos> {
    let url = format!(
        "https://static.crates.io/crates/{name}/{name}-{version}.crate",
        name = info.name,
        version = info.vers,
    );

    let mut result = None;
    for multiplier in backoff::new().take(10) {
        match isahc::get_async(&url).await {
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
        let body = res.text()?;
        return Err(format!("{}", body).into());
    }

    let gz = GzDecoder::new(res.into_body());
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
            };

            return Ok(complete_infos)
        }
    }

    Err(String::from("No Cargo.toml found in this crate").into())
}

pub async fn chunk_complete_crates_info_to_meili(
    receiver: mpsc::Receiver<CompleteCrateInfos>,
) -> Result<()>
{
    let api_key = env::var(MEILI_API_KEY).expect(MEILI_API_KEY);
    let index_name = env::var(MEILI_INDEX_NAME).expect(MEILI_INDEX_NAME);
    let project_name = env::var(MEILI_PROJECT_NAME).expect(MEILI_PROJECT_NAME);

    let client = HttpClient::new()?;

    let mut receiver = receiver.chunks(150);
    while let Some(chunk) = StreamExt::next(&mut receiver).await {
        let url = format!("https://{project_name}.getmeili.com/indexes/{index_name}/documents",
            project_name = project_name,
            index_name = index_name,
        );

        let chunk_json = serde_json::to_string(&chunk)?;

        let request = Request::post(url)
            .header("X-Meili-API-Key", &api_key)
            .header("Content-Type", "application/json")
            .body(chunk_json)?;

        let mut res = client.send_async(request).await?;
        let res = res.text()?;
        eprintln!("{}", res);
    }

    Ok(())
}

pub async fn chunk_downloads_crates_info_to_meili(
    receiver: mpsc::Receiver<DownloadsCrateInfos>,
) -> Result<()>
{
    let api_key = env::var(MEILI_API_KEY).expect(MEILI_API_KEY);
    let index_name = env::var(MEILI_INDEX_NAME).expect(MEILI_INDEX_NAME);
    let project_name = env::var(MEILI_PROJECT_NAME).expect(MEILI_PROJECT_NAME);

    let client = HttpClient::new()?;

    let mut receiver = receiver.chunks(150);
    while let Some(chunk) = StreamExt::next(&mut receiver).await {
        let url = format!("https://{project_name}.getmeili.com/indexes/{index_name}/documents",
            project_name = project_name,
            index_name = index_name,
        );

        let chunk_json = serde_json::to_string(&chunk)?;

        let request = Request::put(url)
            .header("X-Meili-API-Key", &api_key)
            .header("Content-Type", "application/json")
            .body(chunk_json)?;

        let mut res = client.send_async(request).await?;
        let res = res.text()?;
        eprintln!("{}", res);
    }

    Ok(())
}
