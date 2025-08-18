import { createApp } from 'vue'
import App from './App.vue'

import InstantSearch from 'vue-instantsearch/vue3/es'
import { createBootstrap } from 'bootstrap-vue-next'

import { library } from '@fortawesome/fontawesome-svg-core'
import { faChevronDown, faChevronUp, faFlag, faVenusMars, faHashtag } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue-next/dist/bootstrap-vue-next.css'

library.add(faChevronDown, faChevronUp, faFlag, faVenusMars, faHashtag)

createApp(App)
  .use(InstantSearch)
  .use(createBootstrap())
  .component('font-awesome-icon', FontAwesomeIcon)
  .mount('#app')
