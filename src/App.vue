<template>
  <div id="app">

  </div>
</template>

<script>

import instantMeiliSearch from '@meilisearch/instant-meilisearch';
import { MEILISEARCH_HOST, MEILISEARCH_API_KEY } from './meilisearch-client'

export default {
  data() {
    return {
      searchClient: instantMeiliSearch(
        MEILISEARCH_HOST,
        MEILISEARCH_API_KEY
      ),
    }
  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
