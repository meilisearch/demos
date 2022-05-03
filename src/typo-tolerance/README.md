<p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch" width="200" height="200" />
</p>
<h1 align="center">Meilisearch typo tolerance demo</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/MeiliSearch">MeiliSearch</a> |
  <a href="https://docs.meilisearch.com">Documentation</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://blog.meilisearch.com">Blog</a> |
  <a href="https://twitter.com/meilisearch">Twitter</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://slack.meilisearch.com"><img src="https://img.shields.io/badge/slack-Meilisearch-blue.svg?logo=slack" alt="Slack"></a>
  <a href="https://github.com/meilisearch/MeiliSearch/discussions" alt="Discussions"><img src="https://img.shields.io/badge/github-discussions-red" /></a>
</p>

## Requirements

 - [npm](https://www.npmjs.com/get-npm)
 - [Docker](https://docs.docker.com/get-docker/)

## Demo

If you want to replicate this demo using your own Meilisearch instance, you have to follow these steps:

  
### 1. Downloand and launch Meilisearch

[Download and launch Meilisearch](https://docs.meilisearch.com/learn/getting_started/quick_start.html) using the basic configuration. For example, by using [Docker](https://docs.docker.com/get-docker/) in your terminal.

```bash

# Fetch the latest version of Meilisearch image from DockerHub
docker pull getmeili/meilisearch:latest

# Launch Meilisearch
docker run -it --rm \
    -p 7700:7700 \
    -v $(pwd)/data.ms:/data.ms \
    getmeili/meilisearch:latest
```

This walkthrough runs Meilisearch in a development environment, and therefore it does not use any [master key](https://docs.meilisearch.com/learn/security/master_api_keys.html#protecting-a-meilisearch-instance).

There are many other easy ways to [download and run a Meilisearch instance](https://docs.meilisearch.com/learn/getting_started/quick_start.html#download-and-launch).


### 2. Set your credentials

Set the credentials of the Meilisearch instance as environment variables. 
```
VITE_MEILISEARCH_HOST="<yourMeilisearchInstanceAddress>"
VITE_MEILISEARCH_API_KEY="<yourMeilisearchAPIKey>"
```
Because we did not set any Master key in the previous step, we can leave `VITE_MEILISEARCH_API_KEY` as an empty string and only set the host: 
`VITE_MEILISEARCH_HOST='http://127.0.0.1:7700'`


### 3. Install the dependencies

```bash

$ npm install

```

### 4. Run the setup

```bash

$ npm run setup

```

This will do the following:

- Create two indexes called `books_default` and `books_typo` in your Meilisearch instance.

- Add documents to those indexes.

- Add custom settings to each one.

👉 Feel free to modify the typo tolerance rules in `customTypeTolerance`, located inside `setupFunctions.js`. Doing so will allow you to see how different configurations impact the returned search results.

### 5. Run the project

You can now run the project. The front-end client is now communicating with your Meilisearch instance.

```bash

$ npm run dev

```

 Visit `http://localhost:3000/` in your browser and start searching with Meilisearch!

<hr>

**Meilisearch** provides and maintains many **SDKs and Integration tools** like the ones used in this project. We want to provide everyone with an **amazing search experience for any kind of project**. If you want to contribute, make suggestions, or just know what's going on right now, visit us in the [integration-guides](https://github.com/meilisearch/integration-guides) repository.
