import Vue from 'vue'
import App from './App.vue'
import InstantSearch from 'vue-instantsearch';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faChevronDown } from '@fortawesome/free-solid-svg-icons'
import { faChevronUp } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
 
library.add(faChevronDown, faChevronUp)
 
Vue.component('font-awesome-icon', FontAwesomeIcon)

Vue.use(InstantSearch);

Vue.config.productionTip = false

new Vue({
  render: h => h(App),
}).$mount('#app')
