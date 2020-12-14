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
          <ais-search-box class="search-box" placeholder="Search here..." autofocus>
          </ais-search-box>          
          <div class="search-panel__filters-and-results">
            <div class="search-panel__filters-and-clear">
              <button id="show-filters" class="btn" @click.prevent="show = !show" type="button">{{this.show? 'HIDE FILTERS' : 'SHOW FILTERS'}}</button>
              <ais-clear-refinements v-show="show" :class-names="{'ais-ClearRefinements-button': 'btn btn--clear', 'ais-ClearRefinements-button--disabled': 'btn--clear--disabled' }">
                <span slot="resetLabel">Clear all filters</span>
              </ais-clear-refinements>
              <div class="search-panel__filters" v-show="show">
                <div v-for="(filter, index) of filters" v-bind:key="index" :class="['search-panel__filters-' + index]">
                  <h3 @click.prevent="filter.isExpanded = !filter.isExpanded">  {{filter.name}} <font-awesome-icon :icon="filter.isExpanded? 'chevron-up' : 'chevron-down'" size="xs" /></h3> 
                  <div >
                    <ais-refinement-list v-show="filter.isExpanded" :limit="5" :show-more="filter.name === 'Gender'? false : true" :transform-items="transformRefinementListItem" :attribute="filter.name" 
                    :class-names="{'ais-RefinementList-showMore': 'btn'}"
                    />
                  </div>
                </div>
              </div>
            </div>
            <div class="search-panel__results">
              <ais-infinite-hits class="hits"
              :class-names="{
                'ais-InfiniteHits': 'myInfiniteHits',
                'ais-InfiniteHits-list': 'myInfiniteHitsList',
                'ais-InfiniteHits-item': 'myInfiniteHitsItem',
                'ais-InfiniteHits-loadMore': 'myInfiniteHitsLoadMore'}"
              :transform-items="transformHitItems"
              >
                <template slot="item" slot-scope="{ item }" class="hit">
                  <h4> <span class="artwork-title">{{ item.Title }} </span><span class="artwork-date">{{ item.Date }}</span></h4>
                  <a v-if="item.ThumbnailURL" :href="item.URL" ><img :src="item.ThumbnailURL" :alt="item.Title" class="picture"></a>
                  <a v-else-if="item.URL" :href="item.URL">No picture available. Go to MoMA's artwork website</a>
                  <p v-else>No picture available</p>
                  <p>{{ item.Artist }}</p>
                  <p>Medium <br>{{ item.Medium }}</p>
                  <p>Dimensions <br>{{ item.Dimensions }}</p>
                  <p>Department of {{ item.Department }}</p>
                </template>
              </ais-infinite-hits>
            </div>
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
      show: false,
      isExpanded: true,
      filters: [
        { name: 'Nationality',
          isExpanded: true 
        }, 
        { name: 'Gender', 
          isExpanded: true        
        },
        { name: 'Medium', 
          isExpanded: true
        }, 
        { name: 'Classification',
          isExpanded: true        
        }
        ]
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
      Artist: this.displayArtistAndBio(item.Artist, item.ArtistBio),
      Nationality: this.displayArrayElements(item.Nationality),
      ArtistBio: this.displayArrayElements(item.ArtistBio)
    }))
  },
  displayArrayElements(array) {
    let elementsString = "";
    for(var i= 0; i < array.length; i++) {
      i === 0? elementsString += array[i] : elementsString += `, ${array[i]}`;
    }
    return elementsString
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
  margin-right: 3em;
  margin-bottom: 2em;
  
}
.picture {
  max-width: 100%;
}
.myInfiniteHitsList {
  justify-content: center;
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
.search-box {
  margin-bottom: 1rem;
}
.myInfiniteHitsLoadMore {
  display: block;
  margin: auto;
  margin-top: 1rem;
}
.btn {
  height: 28px;
  min-width: 130px;
  padding: 5px, 12.4px;
  font-size: .75rem;
  font-weight: 500;
  border-radius: 5px;
  border: hidden;
  box-shadow: 0 3px 1px -2px rgba(0,0,0,.2),0 2px 2px 0 rgba(0,0,0,.14),0 1px 5px 0 rgba(0,0,0,.12);
  background-color: #ffcd00;
  color: black;
  margin: 15px;
  letter-spacing: 0.15em;
  cursor: pointer;
}
.btn:hover {
  box-shadow: 0 8px 11px 0 rgba(37,44,97,.15),0 4px 6px 0 rgba(93,100,148,.2);
}
.btn--clear {
  background-color: #ffffff;
  border: 0 solid;
}
.btn--clear:hover {
  background-color: #ffffff;
  box-shadow: 0 8px 11px 0 rgba(37,44,97,.15),0 4px 6px 0 rgba(93,100,148,.2);
}
@media screen and (min-width: 768px) {
  .myInfiniteHitsItem {
    width: 45%;
  }
  .search-panel__filters {
    display: flex;
    flex-direction: column;
    min-width: 250px;
  }
  .search-panel__filters-and-results {
    display: flex;
    flex-direction: row;
  }
}
</style>
