<template>
    <ion-fab vertical="bottom" horizontal="end">
        <ion-fab-button @click="goTo(center)" size="small" color="dark">
            <span class="mt-1">
                <i class="fi fi-br-location-crosshairs fs-18 text-gray-200"></i>
            </span>
        </ion-fab-button>
        <ion-fab-button @click="goToCurrentLocation" size="small" color="dark">
            <span class="mt-1">
                <i class="fi fi-br-user fs-18 text-gray-200"></i>
            </span>
        </ion-fab-button>
        <ion-fab-button @click="_onOk" color="dark">
            <ion-icon :icon="checkmark"></ion-icon>
        </ion-fab-button>
    </ion-fab>
    <div class="bg-base-100 w-full h-full" id="map">
        <div class="w-full fixed top-2 left-0 z-[9999] py-2 px-4">
            <div
                class="h-50px relative flex items-center justify-between gap-2 rounded w-full bg-base-100 shadow-md rounded-"
            >
                <button
                    class="btn btn-sm btn-ghost rounded-full w-40px h-full p-0"
                    @click="hideModal()"
                    slot="icon-only"
                >
                    <ion-icon class="w-40px h-20px" :md="arrowBack"></ion-icon>
                </button>
                <span class="mt-2 hidden">
                    <i class="fi fi-sr-marker fs-20 text-gray-600"></i>
                </span>
                <ion-input
                    v-model="query"
                    id="searchbar"
                    class="tu h-50px"
                    :debounce="500"
                    :search-icon="ionLoc"
                    @ion-input="onSearchChange"
                    @ion-focus="searchBarOpen = true"
                    placeholder="Location"
                    type="search"
                    color="clear"
                    clear-input
                >
                </ion-input>

                <OnClickOutside
                    @trigger="hideSearchbar"
                    :options="{ ignore: ['#searchbar'] }"
                >
                    <div
                        v-if="searchBarOpen"
                        class="p-2 w-full absolute bg-base-100 shadow-md left-0 rounded"
                        style="top: calc(100% + 4px)"
                    >
                        <ion-list class="bg-base-100">
                            <ion-item
                                @click="() => onSuggestionClick(e)"
                                v-for="e in features"
                                color="clear"
                            >
                                <ion-label>{{ e.place_name }}</ion-label>
                            </ion-item>
                        </ion-list>
                    </div>
                </OnClickOutside>
            </div>
        </div>
        <l-map
            @ready="onMapReady"
            ref="mapRef"
            :use-global-leaflet="false"
            v-model:zoom="zoom"
            :center="center"
        >
            <l-tile-layer
                :url="tileUrl"
                layer-type="base"
                name="OpenStreetMap"
                attribution=""
            ></l-tile-layer>
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
    IonInput,
    IonLabel,
    IonItem,
    useIonRouter,
} from "@ionic/vue";
import { location as ionLoc, checkmark, arrowBack, add } from "ionicons/icons";
import { OnClickOutside } from "@vueuse/components";
import { onMounted, ref, watch } from "vue";
import "leaflet/dist/leaflet.css";
import L, { LatLngExpression } from "leaflet";
import { LMap, LTileLayer, LMarker } from "@vue-leaflet/vue-leaflet";
import axios from "axios";
import { mapboxPublicToken } from "@/utils/constants";
import { dummyFeatures } from "@/utils/dummies";
import { Geolocation } from "@capacitor/geolocation";
import { hideModal } from "@/utils/funcs";

const searchBarOpen = ref(false),
    mapRef = ref<any>();

const router = useIonRouter();
const jhbCenter = [-26.1974939, 28.0534776];
const zoom = ref(13),
    center = ref<any>(jhbCenter),
    currCenter = ref(jhbCenter);

const query = ref("");
const tileUrl = ref("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png");
const features = ref<any[]>([]);
const isGeocoding = ref(false),
    setIsGeocoding = (val: boolean) => (isGeocoding.value = val);

interface TypeAddr { name: string; center: number[] }
const address = ref<TypeAddr>();

const centerIcon = L.icon({
    iconUrl: "/assets/images/MapMarker.svg",
    iconSize: [32, 37],
    iconAnchor: [16, 37],
});

const props = defineProps({
    onOk: Function,
    location:{type: Object},
});
const goTo = (point: any) => {
    mapRef.value.leafletObject.flyTo(point);
};
const onMapReady = (e: any) => {
    goTo(center.value);
};
async function _onOk() {
    if (props.onOk) {
        await props.onOk(address.value);
    }
}
async function goToCurrentLocation() {
    const coordinates = await Geolocation.getCurrentPosition();
    const { latitude, longitude } = coordinates.coords;
    center.value = [latitude, longitude];
    goTo(center.value);
    reverseGeocode(longitude, latitude)
}
const onSuggestionClick = (val: any) => {
    hideSearchbar();
    const _center = val.center;
    center.value = [_center[1], _center[0]];
    address.value = { name: val.place_name, center: _center };
};

function hideSearchbar() {
    searchBarOpen.value = false;

    features.value = [];
}

function onSearchChange(e: any) {
    searchAddress(e.target.value);
}
async function searchAddress(query: string) {
    if (isGeocoding.value || query.length < 3) return;
    setIsGeocoding(true);
    try {
        if (false) {
            features.value = dummyFeatures;
            setIsGeocoding(false);
            return;
        } else {
            const baseURL =
                "https://api.mapbox.com/geocoding/v5/mapbox.places/";
            const res = await axios.get(`${baseURL}/${query}.json`, {
                params: {
                    proximity: "28.0534776,-26.1974939", //`${jhbCenter[0]},${jhbCenter[1]}`,
                    access_token: mapboxPublicToken,
                },
            });

            features.value = res.data.features;
        }
    } catch (e) {
        console.log(e);
    }
    setIsGeocoding(false);
}

const reverseGeocode = async(lng: number, lat: number)=>{
    try{    
        const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json`
        const res = await axios.get(url,{
            params: {
                access_token: mapboxPublicToken,
                limit: 1
            }
        })
        const ft = res.data.features[0]
        address.value =   { name: ft.place_name, center: ft.center.reverse() }
    }
    catch(e){
        console.log(e)
    }
}

watch(address, _address=>{
    if (_address){
        query.value = _address.name
    }
}, {deep: true})
onMounted(() => {
    if (props.location) {
        const _center = props.location.center;
        center.value = [_center[1], _center[0]];
        address.value = props.location as TypeAddr
        
    }
});
</script>
<style lang="scss">
.leaflet-control-attribution.leaflet-control,
.leaflet-control-container {
    display: none;
}
</style>
