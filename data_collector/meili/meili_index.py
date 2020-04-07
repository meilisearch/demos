import conf
import meilisearch


def get_or_create_index():

    if (conf.PYPI_MEILI_URL is None or conf.PYPI_MEILI_KEY is None):
        exit("""
            ERROR:
            Set your own key and url as environment variables
            - PYPI_MEILI_URL
            - PYPI_MEILI_KEY.
            See documentation at https://docs.meilisearch.com/
            """)
    client = meilisearch.Client(conf.PYPI_MEILI_URL, conf.PYPI_MEILI_KEY)
    try:
        index = client.create_index(conf.INDEX_UUID, primary_key="_id")
        return index
    except Exception as e:
        print("ERROR: Couldn't create index", e)
    try:
        index = client.get_index(conf.INDEX_UUID)
        return index
    except Exception as e:
        print("ERROR: Couldn't get index", e)
    return None


def index_packages(pkg_to_index, index):

    try:
        pkgs = []
        for pkg in pkg_to_index:
            pkgs.append(pkg.__dict__)
        resp = index.add_documents(pkgs)
        print("MEILI server response", resp)
    except Exception as e:
        print("ERROR INDEXING:", e)
        return 0
    print("Sent to index: {} packages".format(len(pkg_to_index)))
    return len(pkg_to_index)
