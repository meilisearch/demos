<p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="MeiliSearch-Vue" width="200" height="200" />
</p>
<h1 align="center">MeiliSearch x MoMA</h1>

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
</p>



In this repository, you will find the front-end interface to search through the [Museum Of Modern Art Collection](https://github.com/MuseumofModernArt/collection). The search is powered by [**MeiliSearch**](https://github.com/meilisearch/meilisearch), a powerful, fast and open-source search engine easy to use and deploy.





## Requirements

 - [npm](https://www.npmjs.com/get-npm)
 - [cURL](https://curl.haxx.se/download.html)

## Demo

If you want to replicate this demo using your own MeiliSearch instance, you will have to follow these steps:

  
### 1. Download and launch MeiliSearch

  

[Download and launch MeiliSearch](https://docs.meilisearch.com/guides/advanced_guides/installation.html) using the basic configuration. For example, by using [cURL](https://curl.haxx.se/) in your terminal.

```bash

$ curl -L https://install.meilisearch.com | sh

$ ./meilisearch

```

This walkthrough runs MeiliSearch in a development environment, and therefore it does not use any [master key](https://docs.meilisearch.com/guides/advanced_guides/configuration.html#master-key).

 There are many other easy ways to [download and run a MeiliSearch instance](https://docs.meilisearch.com/guides/advanced_guides/installation.html#download-and-launch).


### 2. Change the credentials in the .env file

Set the credentials of the MeiliSearch instance as environment variables. 
```
VUE_APP_MEILISEARCH_HOST="yourMeiliSearchInstanceAddress"
VUE_APP_MEILISEARCH_API_KEY="yourMeiliSearchAPIKey"
```

Because we did not set any Master key in the previous step, we can leave `VUE_APP_MEILISEARCH_API_KEY` as an empty string.


### 3. Donwload the dataset:

You can download the dataset with cURL by running the following command: 
```bash

$ npm run get-dataset

```
Or you can get it manually in the [MoMA repository](https://github.com/MuseumofModernArt/collection/blob/master/Artworks.json) and copy it in the setup folder.


  ### 4. Run the setup
  ```bash

$ npm install

$ npm run prep-meili

```

This will do the following:

- Create an index called `artWorks` in your MeiliSearch instance.

- Add all artworks documents to that index.

- Add custom settings for a more relevant search.

### 5. Run the project

 
You can now go back to the root directory and run the project. The front-end client is now communicating with your MeiliSearch instance.

```bash

$ npm run serve

```

 You can now visit `http://localhost:8080/` in your browser and start searching with MeiliSearch!

<hr>

**MeiliSearch** provides and maintains many **SDKs and Integration tools** like this one. We want to provide everyone with an **amazing search experience for any kind of project**. If you want to contribute, make suggestions, or just know what's going on right now, visit us in the [integration-guides](https://github.com/meilisearch/integration-guides) repository.