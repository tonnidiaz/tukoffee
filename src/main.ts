import { createApp } from 'vue'
import App from './App.vue'
import router from './router';
 
import { IonicVue } from '@ionic/vue';

/* Core CSS required for Ionic components to work properly */
import '@ionic/vue/css/core.css';

/* Basic CSS for apps built with Ionic */
import '@ionic/vue/css/normalize.css';
import '@ionic/vue/css/structure.css';
import '@ionic/vue/css/typography.css';

/* Optional CSS utils that can be commented out */
import '@ionic/vue/css/padding.css';
import '@ionic/vue/css/float-elements.css';
import '@ionic/vue/css/text-alignment.css';
import '@ionic/vue/css/text-transformation.css';
import '@ionic/vue/css/flex-utils.css';
import '@ionic/vue/css/display.css'; 

/* Theme variables */
import "@/theme/tw.css"
import './theme/variables.css';
import './styles/main.scss';

import { createPinia } from 'pinia';
import BottomSheetVue from './components/BottomSheet.vue';
import TuButtonVue from './components/TuButton.vue';
import AppbarVue from './components/Appbar.vue';
import RefresherVue from './components/Refresher.vue';
import IconBtn from './components/IconBtn.vue';
import TuField from './components/TuField.vue';
import MapViewVue from './components/MapView.vue';
import InkWellVue from './components/InkWell.vue';
import StarRating from 'vue-star-rating'

const pinia = createPinia() 

const app = createApp(App,)
  .use(IonicVue)
  .use(router)
  .use(pinia)


/*  components */
app.component('bottom-sheet', BottomSheetVue).
component('tu-btn', TuButtonVue).
component('appbar', AppbarVue).
component('refresher', RefresherVue).
component('icon-btn', IconBtn).
component('icon-btn', IconBtn).
component('tu-field', TuField)
.component('map-view', MapViewVue)
.component('ink-well', InkWellVue)
.component('star-rating', StarRating)

router.isReady().then(() => {
  app.mount('#app');
});