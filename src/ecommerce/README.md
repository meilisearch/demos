  <p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch" width="200" height="200" />
</p>
<h1 align="center">Meilisearch Ecommerce</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/MeiliSearch">Meilisearch</a> |
  <a href="https://docs.meilisearch.com">Documentation</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://blog.meilisearch.com">Blog</a> |
  <a href="https://twitter.com/meilisearch">Twitter</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://slack.meilisearch.com"><img src="https://img.shields.io/badge/slack-MeiliSearch-blue.svg?logo=slack" alt="Slack"></a>
  <a href="https://github.com/meilisearch/MeiliSearch/discussions" alt="Discussions"><img src="https://img.shields.io/badge/github-discussions-red" /></a>
  <a href="https://doi.org/10.5281/zenodo.4408594"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.4408594.svg" alt="DOI"></a>
</p>

<p align="center">⚡ Ecommerce platform using Meilisearch</p>

## 📝 Requirements

- [NodeJs](https://nodejs.org/en/download/)
- [npm](https://www.npmjs.com/get-npm)

## 🎬 Getting Started

If you want to replicate this demo using your own Meilisearch instance, you will have to follow these steps:

### 1. Download and launch Meilisearch

[Download and launch Meilisearch](https://docs.meilisearch.com/guides/advanced_guides/installation.html) using the basic configuration. For example, by using [cURL](https://curl.haxx.se/) in your terminal.

```bash

$ curl -L https://install.meilisearch.com | sh

$ ./meilisearch

```

This walkthrough runs Meilisearch in a development environment, and therefore it does not use any [master key](https://docs.meilisearch.com/guides/advanced_guides/configuration.html#master-key).

There are many other easy ways to [download and run a Meilisearch instance](https://docs.meilisearch.com/guides/advanced_guides/installation.html#download-and-launch).

### 2. Set Environment Variables

Create a **.env** file with the credentials of your Meilisearch instance

```
NEXT_PUBLIC_MEILI_HOST_NAME=<PUT_YOUR_MEILI_HOST_HERE>
NEXT_PUBLIC_MEILI_API_KEY=<PUT_YOUR_API_KEY_HERE>

```

## 3. Seed data

Run the following commands:

```
npm install
npm run seed
```

This will create an index `products` and seed data in your meilisearch.

## 4. Start server

Don't forget to run `npm install` first, if you didn't do it in the previous step.

```
npm run dev
```

This will start your frontend server on [http://localhost:8000](http://localhost:8000).
