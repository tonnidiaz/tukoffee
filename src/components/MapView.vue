<template>
    <ion-fab vertical="bottom" horizontal="end">
                <ion-fab-button @click="goToCurrentLocation" size="small" color="dark" >
                    <span class="mt-1">
                          <i class=" fi fi-br-location-crosshairs fs-18 text-gray-200"></i>
                    </span>
                  
                </ion-fab-button>
                <ion-fab-button @click="_onOk" color="dark">
                    <ion-icon :icon="checkmark"></ion-icon>
                </ion-fab-button>
            </ion-fab>
            <div class="bg-base-100 w-full h-full" id="map">

                <div class="w-full  fixed top-2 left-0 z-[9999] py-2 px-4">
                    <div class="h-45px relative flex items-center rounded w-full bg-base-100 shadow-md rounded-">

                        <ion-searchbar  v-model="query" id="searchbar" class="tu h-50px" :debounce="500" :search-icon="ionLoc"
                            @ion-input="onSearchChange" @ion-focus="searchBarOpen = true" placeholder="Location"
                            type="search">
                        </ion-searchbar>

                        <OnClickOutside @trigger="hideSearchbar" :options="{ ignore: ['#searchbar'] }">
                            <div v-if="searchBarOpen" class=" p-2 w-full absolute bg-base-100 shadow-md left-0 rounded"
                                style="top: calc(100% + 4px);">
                                <ion-list class="bg-base-100">
                                    <ion-item @click="()=>onSuggestionClick(e)" v-for="e in features" color="clear">
                                        <ion-label>{{ e.place_name }}</ion-label>
                                    </ion-item>
                                </ion-list>
                            </div>
                        </OnClickOutside>

                    </div>

                </div>
                <l-map :use-global-leaflet="false" ref="map" v-model:zoom="zoom" :center="center">
                    <l-tile-layer :url="tileUrl" layer-type="base" name="OpenStreetMap" attribution=""></l-tile-layer>
                    <l-marker :icon="centerIcon" :lat-lng="center"></l-marker>

                </l-map>
            </div>
</template>

<script setup lang="ts">
import {
    IonList,
    IonIcon,
    IonFab,
    IonFabButton,
    IonSearchbar,
    IonLabel,
    IonItem,
    useIonRouter
} from "@ionic/vue";
import { location as ionLoc, checkmark, } from 'ionicons/icons';
import { OnClickOutside } from '@vueuse/components';
import { ref } from "vue";
import 'leaflet/dist/leaflet.css';
import L from 'leaflet'
import { LMap, LTileLayer, LMarker, } from "@vue-leaflet/vue-leaflet";
import axios from "axios";
import { mapboxPublicToken } from "@/utils/constants";
import { dummyFeatures } from "@/utils/dummies";
import { Geolocation } from '@capacitor/geolocation';


const searchBarOpen = ref(false)


const router = useIonRouter()
const jhbCenter = [-26.1974939, 28.0534776,]
const zoom = ref(13), center = ref<any>(jhbCenter), currCenter = ref(jhbCenter);

const query = ref("")
const
    tileUrl = ref('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',);
const features = ref<any[]>([]);
const isGeocoding = ref(false), setIsGeocoding = (val: boolean) => isGeocoding.value = val;
const address = ref<{name: string, center: number[]}>()

const centerIcon = L.icon({
    iconUrl: '/assets/images/MapMarker.svg',
    iconSize: [32, 37],
    iconAnchor: [16, 37]
})


const props = defineProps({
    onOk: Function
})

async function _onOk(){
    if (props.onOk){
        await props.onOk(address.value)
    }


}
async function goToCurrentLocation(){
    const coordinates = await Geolocation.getCurrentPosition();
    const {latitude, longitude} = coordinates.coords
    center.value =[latitude, longitude]

}
const onSuggestionClick = (val: any) => { 
    query.value = val.place_name; hideSearchbar()
    const _center = val.center
    center.value = [_center[1], _center[0]]
    address.value = {name: val.place_name, center: _center}
 }

function hideSearchbar() {
    searchBarOpen.value = false

    features.value = []
}

function onSearchChange(e: any) {
    searchAddress(e.target.value)
}
async function searchAddress(query: string) {
    if (isGeocoding.value || query.length < 3) return;
    setIsGeocoding(true)
    try {

        if (false) {
            features.value = dummyFeatures;
            setIsGeocoding(false)
            return;
        }
        else {
            const baseURL = "https://api.mapbox.com/geocoding/v5/mapbox.places/";
            const res = await axios.get(`${baseURL}/${query}.json`, {
                params: {
                    proximity: "28.0534776,-26.1974939",//`${jhbCenter[0]},${jhbCenter[1]}`,
                    access_token: mapboxPublicToken
                }
            })

            features.value = res.data.features
        }


    } catch (e) {
        console.log(e)
    }
    setIsGeocoding(false);
}

</script>
<style lang="scss">
.leaflet-control-attribution.leaflet-control,
.leaflet-control-container {
    display: none
}


</style>