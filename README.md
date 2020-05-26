# MeiliSearch finds RubyGems

A [new experience of search](https://rubygems.meilisearch.com) to find your favorite RubyGems 🎉

Search by gem name or by keywords.

[![rubygems demo gif](misc/rubygems.gif)](https://rubygems.meilisearch.com)

The search is powered by [MeiliSearch](https://github.com/meilisearch/MeiliSearch), the open-source and instant search engine.

## See also

- MeiliSearch finds [PyPI packages](https://pypi.meilisearch.com/) (Python)
- MeiliSearch finds [Crates](https://crates.meilisearch.com/) (Rust)

This project uses the [Ruby SDK for MeiliSearch](https://github.com/meilisearch/meilisearch-ruby).

## How to run the data collector

Set:

- `MEILISEARCH_URL`
- `MEILISEARCH_MASTER_KEY`

Run:

```bash
$ bundle install
$ bundle exec ruby meilisearch/app.rb
```

## MeiliSearch settings

```ruby
require 'meilisearch'

...

settings = {
  rankingRules: [
    'typo',
    'words',
    'desc(fame)',
    'proximity',
    'attribute',
    'exactness',
    'desc(total_downloads)',
  ],
  searchableAttributes: [
    'name',
    'summary'
  ],
  displayedAttributes: [
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

The front is deployed to GitHub Pages.

All gems data and main of HTML/CSS come from [RubyGems website](https://rubygems.org/).

The script to fetch data and push them to MeiliSearch runs every day on Heroku with to Heroku Scheduler.

Here is the [repository of MeiliSearch](https://github.com/meilisearch/MeiliSearch).
