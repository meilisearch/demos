<p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch" width="200" height="200" />
</p>

<h1 align="center">Meilisearch Federated search demi</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/meilisearch">Meilisearch</a> |
  <a href="https://docs.meilisearch.com">Documentation</a> |
  <a href="https://discord.gg/meilisearch">Discord</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/demos/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational" alt="License"></a>
</p>
<br/>


## 🧰 Stack

This project requires:

- [Node 18](https://nodejs.org/)
- [Yarn](https://classic.yarnpkg.com/) — Node.js packages manager
- [Meilisearch](https://meilisearch.com) — Fast, relevant search engine

## 🛠️ Setup

### Dependencies

Install the dependencies with Yarn:

```bash
yarn install
```

### Environment

[Download and launch Meilisearch](https://docs.meilisearch.com/learn/getting_started/quick_start.html) using the basic configuration. For example, by using [Docker](https://docs.docker.com/get-docker/) in your terminal.

```bash
# Fetch the latest version of Meilisearch image from DockerHub
docker pull getmeili/meilisearch:v1.1

# Launch Meilisearch in development mode with a master key
docker run -it --rm \
    -p 7700:7700 \
    -e MEILI_ENV='development' \
    -v $(pwd)/meili_data:/meili_data \
    getmeili/meilisearch:v1.1
# Use ${pwd} instead of $(pwd) in PowerShell
```

Environment variables should hold your Meilisearch database credentials. The easiest way to launch a database is to [create a free project](https://cloud.meilisearch.com/) on Meilisearch Cloud. Alternatively, you can read [local installation](https://docs.meilisearch.com/learn/getting_started/installation.html#local-installation) documentation for self-hosted options.

This project loads environment variables from an `.env` file. You can duplicate the existing `.env.example` file and rename it as `.env`. Update the content of the file to match your credentials.

```bash
# .env

# Meilisearch configuration
NEXT_PUBLIC_MEILISEARCH_HOST="use the Database URL here"
NEXT_PUBLIC_MEILISEARCH_SEARCH_API_KEY="use the Default Search API Key here"
NEXT_PUBLIC_MEILISEARCH_ADMIN_API_KEY="use the Default Admin API Key here"


### Database

Run the setup script to configure and seed your Meilisearch instance:

```bash
yarn setup
```

## 🧑‍💻 Development

> **Note**
> Make sure to complete instructions from the Setup section before running the server.

Start the development server on http://localhost:3000

```bash
yarn dev
```

## 🚀 Deployment

Build the application for production:

```bash
yarn build
```

Start a Next.js production server

```bash
yarn start
```

Check out the [deployment documentation](https://nextjs.org/docs/deployment) for more information.
