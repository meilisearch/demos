# MeiliSearch finds PyPI packages

A [new experience of search](https://meilisearch.github.io/finding-pypi) to find your favorite python packages 🎉

Search by package name or by keywords.

The search is powered by [MeiliSearch](https://github.com/meilisearch/MeiliSearch), the open-source and instant search engine.

# Demo

[![Finding PyPI demo gif](docs/img/demo-pypi-meili.gif)](https://meilisearch.github.io/finding-pypi)

# See also

- Finding [Rubygems](https://rubygems.meilisearch.com/), for Ruby  
- Finding [Crates](https://crates.meilisearch.com/), for Rust  

# Developer environment

## Collect packages info and index to MeiliSearch:

#### Setup your environment

1. git clone https://github.com/meilisearch/finding-pypi.git  
2. cd finding-pypi  
3. python3 -m venv env_finding_pypi  
4. source env_finding_pypi/bin/activate  
5. pip3 install -r requirements.txt  
6. export PYPI_MEILI_URL="SOME_URL"  
7. export PYPI_MEILI_KEY="SOME_KEY"  

#### Setup your GCP Credentials  

In order to collect Downloads data from GCP, you need to provide GCP credentials:  

1. Set up your account following the instructions in https://github.com/ofek/pypinfo  
2. run `export PYPI_MEILI_GCP_CREDS="{ HERE YOUR GCP CREDENTIALS JSON FILE CONTENT (escape double quotes, "  becomes  \" )}"`
3. Run `python3 data_collector/collector.py`  
4. Enjoy