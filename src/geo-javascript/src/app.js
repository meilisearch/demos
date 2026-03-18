/* eslint-disable no-undef */
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import { setOptions, importLibrary } from '@googlemaps/js-api-loader'

const GOOGLE_MAP_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY

setOptions({
  key: GOOGLE_MAP_API_KEY,
  v: 'weekly',
})

importLibrary('maps').then(() => {
  const search = instantsearch({
    indexName: 'world_cities_geojson:population:desc',
    searchClient: instantMeiliSearch(
      'https://ms-adf78ae33284-106.lon.meilisearch.io',
      'a63da4928426f12639e19d62886f621130f3fa9ff3c7534c5d179f0f51c4f303',
      {}
    ).searchClient,
  })

  search.addWidgets([
    instantsearch.widgets.sortBy({
      container: '#sort-by',
      items: [
        { value: 'world_cities_geojson', label: 'Relevant' },
        {
          value: 'world_cities_geojson:population:desc',
          label: 'Most Populated',
        },
        {
          value: 'world_cities_geojson:population:asc',
          label: 'Least Populated',
        },
      ],
    }),
    instantsearch.widgets.searchBox({
      container: '#searchbox',
    }),
    instantsearch.widgets.configure({
      hitsPerPage: 20,
    }),
    instantsearch.widgets.geoSearch({
      container: '#maps',
      googleReference: window.google,
      initialZoom: 7,
      initialPosition: {
        lat: 50.655250871381355,
        lng: 4.843585698860502,
      },
      enableRefineOnMapMove: false,
      enableClearMapRefinement: true,
      enableRefineControl: false,
    }),
    instantsearch.widgets.infiniteHits({
      container: '#hits',
      transformItems: (items) =>
        items.map((item) => ({
          ...item,
          populationFormatted: item.population
            ? new Intl.NumberFormat().format(item.population)
            : 'N/A',
        })),
      templates: {
        item: `
          <div class="hit-card">
            <div class="hit-city-name">
              {{#helpers.highlight}}{ "attribute": "name" }{{/helpers.highlight}}
            </div>
            <div class="hit-country">
              {{#helpers.highlight}}{ "attribute": "country" }{{/helpers.highlight}}
            </div>
            <div class="hit-population">{{populationFormatted}} pop.</div>
          </div>
        `,
      },
    }),
  ])

  search.start()
})
