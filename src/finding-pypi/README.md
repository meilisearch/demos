# MeiliSearch finds PyPI packages

A [new experience of search](https://pypi.meilisearch.com/) to find your favorite python packages 🎉

Search by package name or by keywords.

The search is powered by [MeiliSearch](https://github.com/meilisearch/MeiliSearch), the open-source and instant search engine.

# Demo

[![Finding PyPI demo gif](docs/img/demo-pypi-meili.gif)](https://meilisearch.github.io/finding-pypi)

# See also

- Finding [Rubygems](https://rubygems.meilisearch.com/), for Ruby
- Finding [Crates](https://crates.meilisearch.com/), for Rust

# Developer environment

## Collect packages info and index to MeiliSearch:

These steps are automatically done every day.

#### Setup your environment

```
git clone https://github.com/meilisearch/finding-pypi.git
cd finding-pypi
python3 -m venv env_finding_pypi
source env_finding_pypi/bin/activate
pip3 install -r requirements.txt
export PYPI_MEILI_URL="<MEILISEARCH_URL>"
export PYPI_MEILI_KEY="<MEILISEARCH_MASTER_KEY_IF_ANY>"
```

#### Setup your GCP Credentials

In order to collect Downloads data from GCP, you need to provide GCP credentials:

Set up your account following the instructions in https://github.com/ofek/pypinfo

```
export PYPI_MEILI_GCP_CREDS="{ HERE YOUR GCP CREDENTIALS JSON FILE CONTENT (escape double quotes, "  becomes  \" )}"`
python3 data_collector/collector.py
```

Enjoy
