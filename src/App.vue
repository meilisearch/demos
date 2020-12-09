<template>
  <div>
    <header class="header">
      <h1 class='header-title'>
        MoMA x MeiliSearch
      </h1>
    </header>
    <p class="disclaimer">
      Enjoy searching with MeiliSearch!
    </p>
    <div class="container">
      <ais-instant-search
      index-name="artWorks"
      :search-client="searchClient"  
      >
        <div class="search-panel">
          <div class="search-panel__filters">
            <ais-clear-refinements>
              <span slot="resetLabel">Clear all filters</span>
            </ais-clear-refinements>
            <h3>Nationality</h3>
            <ais-refinement-list :transform-items="transformRefinementListItem" attribute="Nationality" />
            <h3>Gender</h3>
            <ais-refinement-list :transform-items="transformRefinementListItem" attribute="Gender" />
            <h3>Medium</h3>
            <ais-refinement-list :transform-items="transformRefinementListItem"  attribute="Medium" />
            <h3>Classification</h3>
            <ais-refinement-list :transform-items="transformRefinementListItem" attribute="Classification" />
          </div>
          <div class="search-panel__results">
            <ais-search-box placeholder="Search here..." autofocus>
            </ais-search-box>
            <ais-infinite-hits class="hits"
            :class-names="{'ais-InfiniteHits-item': 'myInfiniteHitsItem'}"
            :transform-items="transformHitItems"
            >
              <template slot="item" slot-scope="{ item }" class="hit">
                <p class="artwork-title">{{ item.Title }} <br><span class="artwork-date">{{ item.Date }}</span></p>
                <a v-if="item.ThumbnailURL" :href="item.URL" ><img :src="item.ThumbnailURL" :alt="item.Title" class="picture"></a>
                <a v-else-if="item.URL" :href="item.URL">No picture available. Go to MoMA's artwork website</a>
                <p v-else>No picture available</p>
                <div class="hit-info">
                  <p>{{ item.Artist }}</p>
                </div>
                <div class="hit-info">
                  <p>Medium <br>
                  {{ item.Medium }}</p>
                </div>
                <div class="hit-info">
                  <p>Dimensions <br>
                    {{ item.Dimensions }}
                  </p>
                </div>
                <div class="hit-info">Department of {{ item.Department }}</div>
              </template>
            </ais-infinite-hits>
          </div>
        </div>
      </ais-instant-search>
    </div>
  </div>
</template>

<script>
import 'instantsearch.css/themes/algolia-min.css'
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
  methods: {
  transformRefinementListItem(items) {
    return items.map(item => ({
      ...item,
      label: item.label === "" ? "Unspecified" : item.label
    }));
  },
  transformHitItems(items) {
    return items.map(item => ({
      ...item,
      Artist: this. displayArtistAndBio(item.Artist, item.ArtistBio),
      Nationality: this.displayArrayElements(item.Nationality),
      ArtistBio: this.displayArrayElements(item.ArtistBio)
    }))
  },
  displayArrayElements(array) {
    let temp = "";
    for(var i= 0; i < array.length; i++) {
      i === 0? temp += array[i] : temp += `, ${array[i]}`;
    }
    return temp
  },
  displayArtistAndBio(artist, bio) {
    let artistAndBioString = "";
    if (artist.length === 1) {
      artistAndBioString = `${artist[0]} (${bio[0]})`
    } else {
      for(let i= 0; i < artist.length; i++) {
        i === 0? artistAndBioString  += `${artist[i]}` : artistAndBioString  += `, ${artist[i]}`;
      }
    }
    return artistAndBioString 
  }
},
};
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Libre+Franklin:wght@700&display=swap');
body,
h1 {
  margin: 0;
  padding: 0;
}

body {
  font-family:  -apple-system, BlinkMacSystemFont,  "Segoe UI", Roboto, Helvetica,
    Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
}
.header {
  display: flex;
  align-items: center;
  min-height: 60px;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
  background-color: #00afd7;
}
.header-title {
  font-family: 'Libre Franklin', sans-serif;
  font-size: 1.5rem;
}

.disclaimer {
  margin-left: 1em;
}
.container {
  padding: 1rem;
}

.search-panel {
  display: flex;
  flex-direction: column;
}
.search-panel__filters {
  flex: 1;
  margin-right: 3em;
  margin-bottom: 2em; 
}
.picture {
  max-width: 100%;
}
.myInfiniteHitsItem {
  width: 100%;
  display: flex;
  flex-direction: column;
}
.artwork-title {
  font-size: 1.1rem;
  font-weight: bold;
}
.artwork-date {
  font-weight: 200;
}
@media screen and (min-width: 768px) {
  .myInfiniteHitsItem {
    width: 40%;
  }
}
</style>
