<p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch" width="200" height="200" />
</p>
<h1 align="center">Meilisearch matching strategy demo</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/MeiliSearch">MeiliSearch</a> |
  <a href="https://docs.meilisearch.com">Documentation</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://blog.meilisearch.com">Blog</a> |
  <a href="https://twitter.com/meilisearch">Twitter</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/MeiliSearch/discussions" alt="Discussions"><img src="https://img.shields.io/badge/github-discussions-red" /></a>
</p>

## Requirements

 - [yarn](https://yarnpkg.com/)
 - [Docker](https://docs.docker.com/get-docker/)

## Demo

This demo showcases Meilisearch's v0.30 new pagination mode: numbered pagination.

v0.30 introduces a numbered pagination mode for users who need pagination interfaces.

You can find more information about this pagination mode in [our documentation](https://docs.meilisearch.com/learn/advanced/pagination.html#numbered-page-selectors)

If you want to replicate this demo using your own Meilisearch instance, you have to follow these steps:
  
### 1. Download and launch Meilisearch

[Download and launch Meilisearch](https://docs.meilisearch.com/learn/getting_started/quick_start.html) using the basic configuration. For example, by using [Docker](https://docs.docker.com/get-docker/) in your terminal.

```bash

# Fetch the latest version of Meilisearch image from DockerHub
docker pull getmeili/meilisearch:v0.30

# Launch Meilisearch in development mode with a master key
docker run -it --rm \
    -p 7700:7700 \
    -e MEILI_MASTER_KEY='MASTER_KEY'\
    -v $(pwd)/meili_data:/meili_data \
    getmeili/meilisearch:v0.30 \
    meilisearch --env="development"
```

There are many other easy ways to [download and run a Meilisearch instance](https://docs.meilisearch.com/learn/getting_started/quick_start.html#download-and-launch).


### 2. Set your credentials

Set the credentials of the Meilisearch instance as environment variables. 
```
VITE_MEILI_HOST="<yourMeilisearchInstanceAddress>"
VITE_MEILI_SEARCH_API_KEY="<yourMeilisearchSearchAPIKey>"
VITE_MEILI_ADMIN_API_KEY="<yourMeilisearchAdminAPIKey>"
```

You can learn more about master and API keys in [the dedicated section of our documentation](https://docs.meilisearch.com/learn/security/master_api_keys.html).

### 3. Install the dependencies

```bash

yarn

```

### 4. Run the setup

```bash

yarn setup

```

This does the following:

- Creates an index called `movies` in your Meilisearch instance.

- Adds documents to the index


### 5. Run the project

You can now run the project. The front-end client is now communicating with your Meilisearch instance.

```bash

yarn dev

```

 Visit `http://localhost:5173` in your browser and start searching with Meilisearch!

<hr>

**Meilisearch** provides and maintains many **SDKs and Integration tools** like the ones used in this project. We want to provide everyone with an **amazing search experience for any kind of project**. If you want to contribute, make suggestions, or just know what's going on right now, visit us in the [integration-guides](https://github.com/meilisearch/integration-guides) repository.
