# MeiliSearch finds RubyGems

A [new experience of search](https://rubygems.meilisearch.com) to find your favorite RubyGems 🎉

Search by gem name or by keywords.

[![rubygems demo gif](misc/rubygems.gif)](https://rubygems.meilisearch.com)

The search is powered by [MeiliSearch](https://github.com/meilisearch/MeiliSearch), the open-source and instant search engine.

#### WARNING

This project runs with an old version of MeiliSearch (`v0.8.4`). The settings and the methods used might be obsolete.

## See also

- MeiliSearch finds [PyPI packages](https://pypi.meilisearch.com/) (Python)
- MeiliSearch finds [Crates](https://crates.meilisearch.com/) (Rust)

This project uses the [Ruby SDK for MeiliSearch](https://github.com/meilisearch/meilisearch-ruby).

## MeiliSearch settings

```ruby
require 'meilisearch'

settings = {
  rankingOrder: [
    '_sum_of_typos',
    '_number_of_words',
    'fame',
    '_word_proximity',
    '_sum_of_words_attribute',
    '_exact',
    'total_downloads',
  ],
  distinctField: nil,
  rankingRules: {
    total_downloads: 'dsc',
    fame: 'dsc',
  }
}

client = MeiliSearch::Client.new(URL, API_KEY)
index = client.index(index_uid)
index.add_settings(settings)
```

## Details

The front is deployed to GitHub Pages.

All gems data and main of HTML/CSS come from [RubyGems website](https://rubygems.org/).

The script to fetch data and push them to MeiliSearch runs every day on Heroku with to Heroku Scheduler.

Here is the [repository of MeiliSearch](https://github.com/meilisearch/MeiliSearch).
