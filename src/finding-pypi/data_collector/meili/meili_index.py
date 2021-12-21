import conf
import meilisearch
import json


def setup_index():

    if (conf.PYPI_MEILI_URL is None or conf.PYPI_MEILI_KEY is None):
        exit("""
            ERROR:
            Set your own key and url as environment variables
            - PYPI_MEILI_URL
            - PYPI_MEILI_KEY.
            See documentation at https://docs.meilisearch.com/
            """)
    client = meilisearch.Client(conf.PYPI_MEILI_URL, conf.PYPI_MEILI_KEY)
    index = client.get_or_create_index(conf.INDEX_UUID, {'primaryKey': '_id'})
    index.update_settings(json.loads(
        """
        {
            "rankingRules": [
                "typo",
                "desc(fame)",
                "proximity",
                "attribute",
                "exactness",
                "desc(downloads)"
            ],
            "searchableAttributes": [
                "name",
                "description",
                "version"
            ],
            "displayedAttributes": [
                "name",
                "json_data_url",
                "description",
                "project_url",
                "version",
                "_id",
                "downloads",
                "fame"
            ]
        }
        """
    ))
    return index


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
