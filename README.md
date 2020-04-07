# finding-pypi
WIP: Alternative search bar for PyPI packages

[proper README.md coming]

Steps to launch:

1. git clone https://github.com/meilisearch/finding-pypi.git  
2. cd finding-pypi  
3. python3 -m venv env_finding_pypi  
4. source env_finding_pypi/bin/activate  
5. pip install -r requirements.txt  
6. export PYPI_MEILI_URL="SOME_URL"
7. export PYPI_MEILI_KEY="SOME_KEY"
8. python data_collector/collector.py
