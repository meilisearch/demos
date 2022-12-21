<p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch" width="200" height="200" />
</p>
<h1 align="center">MeiliSearch Multi-Tenant Token</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/MeiliSearch">MeiliSearch</a> |
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

<p align="center">⚡ The Meilisearch Multi-Tenant Token application using Nodejs</p>

## Table of Contents <!-- omit in toc -->

- [📖 Documentation](#-documentation)
- [📝 Requirements](#-requirements)
- [🎁 Content of this repository](#-content-of-this-repository)
- [🎬 Getting Started](#-getting-started)
- [💡 Learn More](#-learn-more)



## 📖 Documentation

See our [Documentation](https://docs.meilisearch.com/learn/security/tenant_tokens.html#what-is-multitenancy) or our [API References](https://docs.meilisearch.com/reference/api/).

## 📝 Requirements

 - [NodeJs](https://nodejs.org/en/download/)
 - [npm](https://www.npmjs.com/get-npm)
 - [Docker](https://docs.docker.com/get-docker/)
 
## 🎁 Content of this repository
In this repository, you will find three sub directories:
  1. **Frontend** - React App to search, create token and switch between tokens.
  2. **Backend** - Express App to handle Apis.
  3. **Seed** - Script to feed intial data in meilisearch.

## 🎬 Getting Started

>Prerequisite: Start Docker and download latest Meilisearch docker image using the command `docker pull getmeili/meilisearch:v0.30.4` before going further.

### 1. Seed Data

Navigate to `/seed` and create a **.env** file with content
```
MEILI_MASTER_KEY=<PUT_YOUR_MASTER_KEY_HERE>
```
Then run `npm run meilisearch-serve`  to start meilisearch on docker.

This will start your meilisearch server on [http://localhost:7700](http://localhost:7700).

Next, open a new terminal with same base path(`/seed`) and run following commands to seed data:
```
npm i
npm start
```

## 2. Backend

Navigate to `/backend` and create a **.env** file with content.

```
MEILI_HOST=http://localhost:7700
MEILI_ADMIN_API_KEY=<PUT_YOUR_ADMIN_API_KEY_HERE>
```
Run the following commands:

```
npm i
npm start
```

This will start your express server on [http://localhost:5001](http://localhost:5000)

## 3. Frontend

Navigate to `/frontend` and create a **.env** file with content

```
REACT_APP_MEILI_HOST=http://localhost:7700
REACT_APP_MEILI_SEARCH_API_KEY=<PUT_YOUR_SEARCH_API_KEY_HERE>
REACT_APP_MEILI_INDEX=tenant_token
REACT_APP_API_HOST=http://localhost:5001
```

Run the following commands:

```
npm i
npm start
```

This will start your react app on [http://localhost:3000](http://localhost:3000)

## 💡 Learn More

The following sections may interest you:

- **Documentation**: see the [Official Documentation](https://docs.meilisearch.com/learn/security/tenant_tokens.html#what-is-multitenancy)
- **Blog**: see the [Multi-Token Blog](https://blog.meilisearch.com/)
