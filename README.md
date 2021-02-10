# Finding Crates

A [new experience of search](https://crates.meilisearch.com) to find your favorite crates 🎉

**Search by crate name or by keywords.**

[![crates demo gif](assets/crates-io-demo.gif)](https://crates.meilisearch.com)

The search is powered by [MeiliSearch](https://github.com/meilisearch/MeiliSearch), the open-source and instant search engine.

## See also

- MeiliSearch finds [PyPI packages](https://pypi.meilisearch.com/) (Python)
- MeiliSearch finds [RubyGems](https://rubygems.meilisearch.com/) (Ruby)

## How to run the data collector

Set the following envrionment variables:
- `MEILI_HOST_URL`
- `MEILI_API_KEY`
- `MEILI_INDEX_UID` (it should set to `crates` to be used with the front of this repo)

```bash
$ rm -rf crates.io-index/
$ ./run.sh
```

## Details

The front is deployed to GitHub Pages.

We pull new crates and crates updates every 10 minutes from [docs.rs](https://docs.rs/releases) and all the downloads counts every day at 3:30 PM UTC from [crates.io](https://crates.io/data-access).

Here is the [repository of MeiliSearch](https://github.com/meilisearch/MeiliSearch).
