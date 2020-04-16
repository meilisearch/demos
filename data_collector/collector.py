import asyncio
import aiojobs
import conf
from pypi import pypi
from aiochannel import Channel
from meili import meili_index as meili
from bigquery_pypi import bigquery_pypi as bq


async def handle_package_loop(channel, pkg_list_size, index):

    all_pkg = []
    indexed_counter = 0
    pkg_count = 0

    async for pkg in channel:
        pkg_count += 1
        if pkg is not None:
            all_pkg.append(pkg)

        # Check if all packages are treated and handle last batch
        if pkg_count == pkg_list_size \
                or (conf.PKG_CNT_LIMIT and pkg_count >= conf.PKG_CNT_LIMIT):
            indexed_counter += meili.index_packages(all_pkg, index)
            print("{}: {}".format(
                "Total packages sent to MeiliSearch Index",
                indexed_counter
            ))
            break

        # Handle a single batch
        elif len(all_pkg) >= conf.PKG_INDEXING_BATCH_SIZE:
            batch = all_pkg[:conf.PKG_INDEXING_BATCH_SIZE]
            all_pkg = all_pkg[conf.PKG_INDEXING_BATCH_SIZE:]
            indexed_counter += meili.index_packages(batch, index)
            print("{}: {}".format(
                "Total packages sent to MeiliSearch Index",
                indexed_counter
            ))
    channel.close()


async def main():

    # Create a MeiliSearch index
    index = meili.get_or_create_index()
    if index is None:
        exit("\tERROR: Couldn't create a Meilisearch index")

    # Create an Asynchronous scheduler and channel
    scheduler = await aiojobs.create_scheduler()
    scheduler._limit = conf.SCHEDULER_MAX_TASKS
    channel = Channel(loop=asyncio.get_event_loop())

    # Get downloads data
    downloads_dict = bq.downloads_dict_from_file()
    sorted_dict = sorted(downloads_dict.items(), key=lambda t: t[1], reverse=True)
    fame_levels = {
        "top100": sorted_dict[100][1],
        "top500": sorted_dict[500][1],
        "top1K": sorted_dict[1000][1],    
        "top5K": sorted_dict[5000][1], 
        ">10Kmonthly": 10000
    }

    pkg_list = pypi.get_url_list()
    await scheduler.spawn(handle_package_loop(channel, len(pkg_list), index))
    for pkg_link in pkg_list:
        pkg = pypi.Package(pkg_link.get_text())
        pkg.update_package_downloads(downloads_dict, fame_levels)
        await scheduler.spawn(pkg.single_pkg_request(channel))
    await channel.join()

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(main())
