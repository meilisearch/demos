# Meilisearch finds RubyGems

A [new experience of search](https://rubygems.meilisearch.com) to find your favorite RubyGems 🎉

**Search by gem name or by keywords.**

[![rubygems demo gif](misc/rubygems.gif)](https://rubygems.meilisearch.com)

The search is powered by [Meilisearch](https://github.com/meilisearch/MeiliSearch), the open-source and instant search engine.

## See also

- Meilisearch finds [PyPI packages](https://pypi.meilisearch.com/) (Python)
- Meilisearch finds [Crates](https://crates.meilisearch.com/) (Rust)

This project uses the [Ruby SDK for Meilisearch](https://github.com/meilisearch/meilisearch-ruby).

## How to run the data collector

Set the following environment variables:

- `MEILISEARCH_HOST_URL`
- `MEILISEARCH_API_KEY`

Run:

```bash
$ bundle install
$ bundle exec ruby meilisearch/app.rb
```

## Meilisearch settings

```ruby
require 'meilisearch'

...

settings = {
  ranking_rules: [
    'typo',
    'words',
    'fame:desc',
    'proximity',
    'attribute',
    'exactness',
    'total_downloads:desc',
  ],
  searchable_attributes: [
    'name',
    'summary'
  ],
  displayed_attributes: [
    'name',
    'summary',
    'description',
    'version',
    'total_downloads'
  ]
}

client = MeiliSearch::Client.new(URL, API_KEY)
client.index(index_uid).update_settings(settings)
```

## Details

The front is deployed to Vercel.

All gems data and main of HTML/CSS come from [RubyGems website](https://rubygems.org/).

The script to fetch data and push them to Meilisearch runs every day on Heroku with to Heroku Scheduler.

Here is the [repository of Meilisearch](https://github.com/meilisearch/MeiliSearch).
