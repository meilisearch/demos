use std::env;
use std::error::Error;
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
    pub readme: String,
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

    let mut toml_infos = None;
    let mut readme = None;

    for res in tar.entries()? {
        // stop early if we found both files
        if toml_infos.is_some() && readme.is_some() { break }

        let mut entry = res?;
        let path = entry.path()?;
        let file_name = path.file_name().and_then(|s| s.to_str());

        match file_name {
            Some("Cargo.toml") if toml_infos.is_none() => {
                let mut content = Vec::new();
                entry.read_to_end(&mut content)?;

                let manifest = Manifest::from_slice(&content)?;
                let package = match manifest.package {
                    Some(package) => package,
                    None => break,
                };

                let name = info.name.clone();
                let description = package.description.unwrap_or_default();
                let keywords = package.keywords;
                let categories = package.categories;
                let version = info.vers.clone();

                toml_infos = Some((
                    name,
                    description,
                    keywords,
                    categories,
                    version,
                ));
            },
            Some("README.md") if readme.is_none() => {
                let mut content = String::new();
                entry.read_to_string(&mut content)?;

                let options = comrak::ComrakOptions::default();
                let html = comrak::markdown_to_html(&content, &options);

                let document = scraper::Html::parse_document(&html);
                let html = document.root_element();
                let text = html.text().collect();

                readme = Some(text);
            },
            _ => (),
        }
    }

    match (toml_infos, readme) {
        (Some((name, description, keywords, categories, version)), readme) => {
            Ok(CompleteCrateInfos {
                name,
                description,
                keywords,
                categories,
                readme: readme.unwrap_or_default(),
                version,
            })
        },
        (None, _) => Err(String::from("No Cargo.toml found in this crate").into()),
    }

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
