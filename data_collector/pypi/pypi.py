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
        all_pkg_list = all_pkg_list[:conf.PKG_CNT_LIMIT]
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
    fame = 0

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
    
    def update_package_downloads(self, downloads_dict):
        lowercase_name = self.name.lower()
        if lowercase_name in downloads_dict:
            self.downloads = downloads_dict[lowercase_name]
            if self.downloads > 10000000:
                self.fame = 15
            elif self.downloads > 5000000:
                self.fame = 14
            elif self.downloads > 2000000:
                self.fame = 13
            elif self.downloads > 1000000:
                self.fame = 12
            elif self.downloads > 500000:
                self.fame = 11
            elif self.downloads > 200000:
                self.fame = 10
            elif self.downloads > 100000:
                self.fame = 9
            elif self.downloads > 50000:
                self.fame = 8
            elif self.downloads > 20000:
                self.fame = 7
            elif self.downloads > 10000:
                self.fame = 6
            elif self.downloads > 5000:
                self.fame = 5
            elif self.downloads > 2000:
                self.fame = 4
            elif self.downloads > 1000:
                self.fame = 3
            elif self.downloads > 500:
                self.fame = 2
            elif self.downloads > 200:
                self.fame = 1
            else:
                self.fame = 0
        else:
            self.downloads = 0
            self.fame = 0
                


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
