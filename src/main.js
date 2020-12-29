import Vue from 'vue'
import App from './App.vue'
import InstantSearch from 'vue-instantsearch'
import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faChevronDown, faChevronUp, faFlag, faVenusMars, faHashtag } from '@fortawesome/free-solid-svg-icons'

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

library.add(faChevronDown, faChevronUp, faFlag, faVenusMars, faHashtag)

Vue.component('font-awesome-icon', FontAwesomeIcon)

Vue.use(InstantSearch)
// Install BootstrapVue
Vue.use(BootstrapVue)
// Optionally install the BootstrapVue icon components plugin
Vue.use(IconsPlugin)

Vue.config.productionTip = false

new Vue({
  render: h => h(App)
}).$mount('#app')
