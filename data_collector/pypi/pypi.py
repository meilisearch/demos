import conf
import requests
import json
import hashlib
from bs4 import BeautifulSoup


def get_url_list():

    print("Retrieving PyPI package list at {}". format(conf.SIMPLE_API_URL))
    pkg_list_response = requests.get(conf.SIMPLE_API_URL)
    soup = BeautifulSoup(pkg_list_response.text, "html.parser")
    all_pkg_list = soup.find_all('a')[conf.PKG_LIST_OFFSET:]
    if conf.PKG_CNT_LIMIT:
        all_pkg_list = soup.find_all('a')[:conf.PKG_CNT_LIMIT]
    print("PyPI package list retrieved. {} items found.".format(
        len(all_pkg_list)
    ))
    return all_pkg_list


class Package():

    _id = ""
    name = ""
    version = ""
    description = ""
    project_url = ""
    json_data_url = ""
    downloads = 0

    def __init__(self, name):
        self.name = name
        md5t = hashlib.md5()
        md5t.update(name.encode('utf-8'))
        self._id = md5t.hexdigest()
        self.json_data_url = "{}{}/json".format(conf.PYPI_API_URL, self.name)

    def __str__(self):

        return "Package: {}, version: {}".format(self.name, self.version)

    def update_object_data(self, json_data):

        self.name = json_data["name"]
        self.version = json_data["version"]
        self.description = json_data["summary"]
        self.project_url = json_data["project_url"]

    async def update_pypi_data(self):

        req = requests.get(self.json_data_url)
        if req.status_code == 200:
            try:
                json_data = json.loads(req.text)["info"]
                self.update_object_data(json_data)
            except Exception as e:
                print("\tError for package {}: {}".format(self.name, e))
        else:
            if conf.SHOW_PYPI_HTTP_ERRORS:
                print("\tError {} in request for package {}. URL: {}".format(
                    req.status_code,
                    self.name,
                    self.json_data_url
                ))

    async def single_pkg_request(self, channel):

        try:
            await self.update_pypi_data()
            await channel.put(self)
        except Exception:
            await channel.put(None)
