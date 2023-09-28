<template>
    <ion-page>
        <Appbar title="Products" :show-cart="false" /><ion-fab
            vertical="bottom"
            horizontal="end"
        >
            <ion-fab-button @click="router.push('/add/product')" color="dark">
                <span class="mt-1"><i class="fi fi-rr-plus"></i></span>
            </ion-fab-button>
        </ion-fab>
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="getProducts" />
            <div class="my-2 bg-base-100 p-3">
                <div
                    class="bg-base-200 rounded-md flex items-center px-4 h-45px gap-2"
                >
                    <span class="mt-1"
                        ><i class="fi fi-rr-search fs-18 text-gray-700"></i
                    ></span>

                    <ion-input
                        color="clear"
                        placeholder="Search"
                        class="tu bg-primar"
                    ></ion-input>
                    <span class="mt-2"
                        ><i
                            class="fi fi-rr-settings-sliders fs-18 text-gray-700"
                        ></i
                    ></span>
                </div>
            </div>
                        <div
                v-if="!products"
                class="bg-base-100 h-full w-full flex items-center justify-center"
            >
                <ion-spinner class="w-45px h-45px" color="medium"></ion-spinner>
            </div>
            <div v-else class="bg-base-100 pb-4 my-2">
                <ProductItem v-for="it in products" :item="it" />
            </div>
            
        </ion-content>
        <BottomSheet @did-dismiss="newProductSheetOpen = false" :is-open="newProductSheetOpen" >
            <AddProductView/>
            </BottomSheet>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonFab,
    IonFabButton,
    IonSpinner,
    IonInput,
    IonText,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";

import Appbar from "@/components/Appbar.vue";
import ProductItem from "@/components/ProductItem.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import Refresher from "@/components/Refresher.vue";

import { useDashStore } from "@/stores/dash";
import AddProductView from "@/components/AddProductView.vue";
import { onMounted, ref } from "vue";
import { Obj } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { useRouter } from "vue-router";

const newProductSheetOpen = ref(false)
const products = ref<Obj[] | null>()
const dashStore = useDashStore();

const router = useRouter()
const getProducts = async () => { 
    try {
        products.value = null
        const res = await apiAxios.get('/products')
        products.value = res.data.data
    } catch (e) {
        console.log(e)
        products.value = []
    }
 }
onMounted(()=>{
getProducts()
})
</script>
