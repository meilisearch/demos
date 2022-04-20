<template>
  <b-container fluid class="px-0">
    <ais-instant-search
      index-name="artWorks"
      :search-client="searchClient"  
    >
      <b-row>
        <b-col class="col-md-3 col-lg-2 nav-left">
          <b-nav id="sidebar-1" class="d-flex justify-content-center">
             <b-navbar class="px-1 d-flex flex-column">
               <div class="d-flex flex-column d-md-none">
                <b-navbar-brand class="d-flex flex-column align-items-center navbar-mobile">
                  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch logo" width="70" height="70" class="mb-3"> 
                  <div class="d-flex flex-column align-items-center">
                    <p class='header-title'>Meilisearch x MoMA</p> 
                    <p class="disclaimer">Enjoy searching with Meilisearch!</p>
                  </div>
                </b-navbar-brand>
                </div>
                <div v-show="show" class="filters mt-5">
                  <ais-clear-refinements style="text-align:center;" 
                    :class-names="{
                      'ais-ClearRefinements-button': 'mybtn mybtn--clear', 
                      'ais-ClearRefinements-button--disabled': 'mybtn--clear--disabled' 
                    }"
                  >
                    <span slot="resetLabel">Clear filters</span>
                  </ais-clear-refinements>
                  <div v-for="(filter, index) of filters" v-bind:key="index" class="search-panel__filters d-flex flex-column align-items-start">
                    <h4 class="filters mt-4" @click.prevent="filter.isExpanded = !filter.isExpanded"> <font-awesome-icon :icon="whichIcon(filter.name)" size="xs"/> {{filter.name}} <font-awesome-icon :icon="filter.isExpanded? 'chevron-up' : 'chevron-down'" size="xs" /></h4> 
                    <div class="d-flex">
                      <ais-refinement-list v-show="filter.isExpanded" :limit="5" :show-more="filter.name === 'Gender'? false : true" :transform-items="transformRefinementListItem" :attribute="filter.name" 
                        :class-names="{
                          'ais-RefinementList-showMore': 'btn btn-secondary btn-sm',
                          'ais-RefinementList': 'mx-auto'
                        }"
                      />
                    </div>
                  </div>
                </div>
                <b-button size="sm" variant="light" class="d-md-none" @click.prevent="show=!show">{{this.show? 'HIDE FILTERS' : 'SHOW FILTERS'}}</b-button>
              </b-navbar>
          </b-nav>
        </b-col>
        <b-col class="col-md-9 col-lg-10">
          <b-row>
            <b-col>
             <b-navbar class="pl-5 d-none d-md-flex flex-column align-items-start">
                <b-navbar-brand class="d-flex justify-content-center align-items-center">
                  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch logo" height="60px"> 
                  <p class="header-title my-0"> Meilisearch x MoMA</p> 
                </b-navbar-brand>
                <div class="disclaimer disclaimer-desktop">Enjoy searching with Meilisearch!</div>
              </b-navbar>
            </b-col>
          </b-row>
          <b-row class="mt-5">
            <b-col class="col-10 mx-auto ">
              <b-row>
                <b-col class="col-12 col-md-10 my-3 mx-auto d-flex up-bar">
                  <ais-stats/>
                  <ais-sort-by
                    :items="[
                      { value: 'artWorks', label: 'Featured' },
                      { value: 'artWorks:DateToSortBy:asc', label: 'Date asc.' },
                      { value: 'artWorks:DateToSortBy:desc', label: 'Date desc.' }
                    ]"
                    :class-names="{
                      'ais-SortBy': 'MyCustomSortBy'
                    }"
                  />
                </b-col>
              </b-row>
              <b-row>
                <b-col class="col-12 col-md-10 mx-auto">
                  <ais-search-box class="search-box" placeholder="Search here..." autofocus>
                  </ais-search-box> 
                </b-col>
              </b-row>
              <b-row>
                <ais-current-refinements 
                  :class-names="{
                    'ais-CurrentRefinements': 'MyCustomCurrentRefinements',
                    'ais-CurrentRefinements-item': 'MyCustomCurrentRefinementsItem'
                  }"
                />  
              </b-row>
            </b-col>    
          </b-row>
          <b-row class="mt-3">
            <b-col class="px-5">
              <ais-infinite-hits class="hits"
              :class-names="{
                'ais-InfiniteHits': 'myInfiniteHits',
                'ais-InfiniteHits-list': 'myInfiniteHitsList',
                'ais-InfiniteHits-item': 'myInfiniteHitsItem'}"
              :transform-items="transformHitItems"
              >
                <template slot="item" slot-scope="{ item }" class="hit">
                  <h4 class="center-title"> 
                    <ais-highlight 
                      attribute="Title"
                      :hit="item" :class-names="{'ais-Highlight':'artwork-title'}"
                    />
                  <br>
                    <ais-highlight 
                      attribute="Date"
                      :hit="item" :class-names="{'ais-Highlight':'artwork-date'}"
                    />
                  </h4>
                  <a v-if="item.ThumbnailURL" :href="item.URL" ><img :src="item.ThumbnailURL" :alt="item.Title" class="picture"></a>
                  <p v-else-if="item.URL" class="center-title">No picture available. <br> <a class="center-title"  :href="item.URL">Go to MoMA's artwork website</a></p>
                  <p v-else>No picture available</p>
                  <p class="center-title">
                    <ais-highlight
                      attribute="Artist"
                      :hit="item"
                      
                    />
                    <br>
                    <ais-highlight
                      v-show="!item.VariousArtists"
                      attribute="ArtistBio"
                      :hit="item"
                    />
                  </p>
                  <p class="center-title">Medium <br>
                    <ais-highlight
                      attribute="Medium"
                      :hit="item"
                    />
                  </p>
                  <p class="center-title">Dimensions <br>
                    <ais-highlight
                      attribute="Dimensions"
                      :hit="item"
                    />
                  </p>
                  <p>Department of 
                    <ais-highlight
                    attribute="Department"
                    :hit="item"
                  />
                  </p>
                </template>
                <b-button
                  slot="loadMore"
                  slot-scope="{isLastPage, refineNext }"
                  :disabled="isLastPage"
                  @click="refineNext"
                  class="mx-auto my-5"
                >
                  Show more
                </b-button>
              </ais-infinite-hits>
            </b-col>
          </b-row>
        </b-col>
      </b-row>
    </ais-instant-search>
  </b-container>
</template>

<script>
import 'instantsearch.css/themes/algolia-min.css'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

export default {
  data() {
    return {
      searchClient: instantMeiliSearch(
        "https://demos.meilisearch.com",
        "dc3fedaf922de8937fdea01f0a7d59557f1fd31832cb8440ce94231cfdde7f25"
      ),
      show: true,
      isExpanded: true,
      filters: [
        { name: 'Classification',
          isExpanded: true        
        },
        { name: 'Nationality',
          isExpanded: true 
        }, 
        { name: 'Gender', 
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
      _highlightResult: { 
        ...item._highlightResult
      }
    }))
  },
  whichIcon(filterName) {
    if (filterName === 'Gender') {
      return 'venus-mars'
    } else if (filterName === 'Nationality') {
      return 'flag'
    } else {
      return 'hashtag'
    }
  }
}
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
  overflow-x: hidden;
}

.nav-left {
  background-color: #EEE5E9;
}
.header-title {
  font-family: 'Libre Franklin', sans-serif;
  font-size: 1.5rem;
}
.container {
  padding: 1rem;
}
.navbar-mobile {
  margin-right: 0;
}
.disclaimer-desktop {
  margin-left: 60px;
}
.MyCustomCurrentRefinements {
  margin: 1rem;
}
.MyCustomCurrentRefinementsItem {
  background-color: #6c757d;
}
.up-bar {
  justify-content: space-between;
}
.search-panel {
  display: flex;
  flex-direction: column;
}
.search-panel__filters {
  margin-right: 3em;
  margin: 1em; 
}

.ais-Highlight-highlighted {
  background-color: #ee8ab7;
  padding: 0, 0.15em;
  display: inline-block;
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
  align-items: center;
}
.center-title {
  text-align: center;
}
.artwork-title {
  font-size: 1.1rem;
  font-weight: bold;
}
.artwork-date {
  font-weight: 200;
}
.artist-name {
  color: #00afd7;
  font-weight: 500;
}
.search-box {
  margin-bottom: 1rem;
}
.hits {
  display: flex;
  flex-direction: column;
}

.mybtn {
  height: 28px;
  min-width: 130px;
  padding: 5px, 12.4px;
  font-size: .75rem;
  font-weight: 500;
  border-radius: 5px;
  border: hidden;
  box-shadow: 0 3px 1px -2px rgba(0,0,0,.2),0 2px 2px 0 rgba(0,0,0,.14),0 1px 5px 0 rgba(0,0,0,.12);
  color: black;
  margin: 15px;
  letter-spacing: 0.15em;
  cursor: pointer;
  background-color: #6c757d
}
.mybtn:hover {
  box-shadow: 0 8px 11px 0 rgba(37,44,97,.15),0 4px 6px 0 rgba(93,100,148,.2);
  background-color: #ffffff;
}
.mybtn-sm {
  height: 25px;
  min-width: 100px;
  padding: 5px, 5px;
  letter-spacing: inherit;
}
.mybtn--clear {
  background-color: #ffffff;
  border: 0 solid;
}
.mybtn--clear:hover {
  background-color: #ffffff;
  box-shadow: 0 8px 11px 0 rgba(37,44,97,.15),0 4px 6px 0 rgba(93,100,148,.2);
}
.mybtn--clear--disabled {
 display: none;
}
@media screen and (min-width: 768px) {
  .myInfiniteHitsItem {
    width: 45%;
  }
  .search-panel__filters-and-results {
    display: flex;
    flex-direction: row;
  }

}
@media screen and (min-width: 768px) and (max-width: 1199px) {
  h4.filters {
    font-size: 1rem;
  }
  ais-RefinementList-labelText {
    font-size: 0.9rem;
  }
  .ais-RefinementList-showMore {
    font-size: 0.8rem;
  }
}
</style>
