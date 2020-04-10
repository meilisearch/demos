# MeiliSearch finds PyPI packages

A [new experience of search](https://meilisearch.github.io/finding-pypi) to find your favorite python packages 🎉

Search by package name or by keywords.

TODO: PyPI DEMO PENDING (rubygems placeholder)
[![rubygems demo gif](https://raw.githubusercontent.com/meilisearch/finding-rubygems/master/misc/rubygems.gif)](https://meilisearch.github.io/finding-pypi)

The search is powered by [MeiliSearch](https://github.com/meilisearch/MeiliSearch), the open-source and instant search engine.

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
2. run `GOOGLE_APPLICATION_CREDENTIALS=[path_to_creds_json_file...] python3 data_collector/collector.py`  