import os
import pickle
from datetime import datetime, timedelta
from google.cloud import bigquery
from google.oauth2 import service_account


"""
Package downloads data from PyPI is available in a public GCP Bigquery
database. This module gets the last month downloads data from GCP
and stores the results in a binary file for further use by the collector.
"""

# Define last month slug for Bigquery requests and file naming
last_month = datetime.now().replace(day=1) - timedelta(days=1)
date_prefix = last_month.strftime("%Y%m")
downloads_file = "data_collector/bigquery_pypi/data/downloads_{}.pkl".format(
        date_prefix
    )


"""
Create a credentials temporary file for GCP authentication (from env variable).
Authenticate and delete the file. Return the client.
"""


def gcp_client_authenticate():

    print("Requesting GCP authentication...")
    creds_env = os.getenv('PYPI_MEILI_GCP_CREDS')
    if creds_env == "":
        raise Exception("Set PYPI_MEILI_GCP_CREDS with your GCP credentials")
    f = open("data_collector/bigquery_pypi/data/tmp_file.txt", "w+")
    f.write(creds_env)
    f.close()
    credentials = service_account.Credentials.from_service_account_file(
        "data_collector/bigquery_pypi/data/tmp_file.txt",
    )
    client = bigquery.Client(
        credentials=credentials,
        project=credentials.project_id,
    )
    os.remove("data_collector/bigquery_pypi/data/tmp_file.txt")
    return client


"""
Request Bigquery for last months downloads of every package having more than
50 downloads. Return the result in a dictionary containing every package name
as key, and last month downloads as value
"""


def get_most_downloaded_pkgs(limit=200000, offset=None):

    downloads_dict = {}
    client = gcp_client_authenticate()

    sql_request = "SELECT file.project AS name, COUNT(*) AS download_count, \
    FROM `the-psf.pypi.downloads{}*` \
    GROUP BY name \
    HAVING download_count>50 \
    ORDER BY download_count DESC".format(date_prefix)
    if limit is not None:
        sql_request += " LIMIT {}".format(limit)
    if offset is not None:
        sql_request += " OFFSET {}".format(offset)
    query_job = client.query(sql_request)
    rows = query_job.result()

    for row in rows:
        downloads_dict[row.name.lower()] = row.download_count
    return downloads_dict


"""
If there is no file containing last months downloads, this method requests
GCP Bigquery for data and creates the file. Otherwise, it reads the file.
It returns a dictionary containing every package name as key, and number of
downloads as value
"""


def downloads_dict_from_file():

    if os.path.isfile(downloads_file):
        f = open(downloads_file)
        print("Downloads file found: {}".format(downloads_file))
    else:
        print("Downloads file NOT found. Requesting downloads from Bigquery")
        downloads_dict = get_most_downloaded_pkgs()
        try:
            with open(downloads_file, 'wb') as f:
                pickle.dump(downloads_dict, f, pickle.HIGHEST_PROTOCOL)
                print("Downloads file created: {}".format(downloads_file))
        except IOError as e:
            print("I/O ERROR: {}".format(e))
    with open(downloads_file, 'rb') as f:
        dict = pickle.load(f)
        print("Found downloads data for {} packages".format(len(dict)))
        return dict


if __name__ == "__main__":

    dict = downloads_dict_from_file()
    print("Downloads data stored for {} packages".format(len(dict)))
    sorted_dict = sorted(dict.items(), key=lambda t: t[1], reverse=True)
    most_popular = sorted_dict[:50]
    print("Most popular:", most_popular)
