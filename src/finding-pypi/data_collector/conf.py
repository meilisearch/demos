import os

# Set pkg_count_limit to None for no limit
PKG_CNT_LIMIT = None

# Set the size of the batch that will be treated by MeiliSearch
PKG_INDEXING_BATCH_SIZE = 1000

# Set the scheduler number of concurrent tasks
SCHEDULER_MAX_TASKS = 100

# Set the offset to start treating the package list
PKG_LIST_OFFSET = 0

# MeiliSearch params
INDEX_UUID = "pypi"
PYPI_MEILI_URL = os.getenv('PYPI_MEILI_URL')
PYPI_MEILI_KEY = os.getenv('PYPI_MEILI_KEY')

# Data sources
SIMPLE_API_URL = "https://pypi.org/simple/"
PYPI_API_URL = "https://pypi.org/pypi/"

SHOW_PYPI_HTTP_ERRORS = False
