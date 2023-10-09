<template>
    <ion-page>
        <ion-header class="ion-no-border">
            <ion-toolbar>
                <ion-buttons slot="start">
                    <button
                        class="btn btn-sm btn-ghost rounded-full w-40px h-40px p-0"
                        router-direction="back"
                        @click="() => $router.back()"
                        slot="icon-only"
                    >
                        <ion-icon
                            class="w-40px h-20px"
                            :md="arrowBack"
                        ></ion-icon>
                    </button>
                </ion-buttons>
                <form action="" @submit="onFormSubmit">
                     <div class="searchbar">
                    <span class="mt-1"
                        ><i class="fi fi-br-search fs-18 text-gray-500"></i
                    ></span>

                    <ion-input
                        color="clear"
                        placeholder="Search"
                        class="tu fs-18"
                        type="search"
                        name="q"
                    ></ion-input>
                    <span class="mt-1"
                        ><i class="fi fi-br-settings-sliders fs-18 text-gray-500"></i
                    ></span>

                </div>
                </form>
               
                
            </ion-toolbar>
        </ion-header>
        <ion-content :fullscreen="true">
            <div class="h-full flex flex-column w-full">

                <div class="my-1 bg-base-100 p-3 w-full relative" style="overflow-y: scroll;">
                    <div class="flex flex-center h-full" v-if="!items">
                        <div v-if="query.length">
                                <ion-spinner color="medium" class="w-50px h-50px"></ion-spinner>
                        </div>
                    </div>
                    <div v-else>
                    <h3  class="fs-18 fw-5 my-4">Search results for: <span class="fw-6 text-underline text-secondary">{{query}}</span></h3>

                    <div v-if="items.length" class="my-4 grid justify-center gap-1 grid-cols-2">

                        <ProductCard v-for="(e, i) in items" :product="e" />
                    </div>
                    <div class="my-4 flex flex-center h-full" v-else>
                        

                        <h3 class="fs-20 fw-5 my-4">No results</h3>
                    </div>
                    </div>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import ProductCard from "@/components/ProductCard.vue";
import { Obj } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import {
    IonPage,
    IonHeader,
    IonToolbar,
    IonContent,
    IonInput,
    IonButtons,
    IonIcon,
    IonSpinner,

} from "@ionic/vue";
import { arrowBack } from "ionicons/icons";
import { ref } from "vue";

const query = ref(""), items = ref< Obj[] | null>(), setItems = (v : Obj[] | null) => items.value = v
const searchBy = ref<string | null>()
const onFormSubmit = (e: any) => { 
    e.preventDefault()
    const {q} = e.target
    query.value = q.value
    searchProducts(q.value)
 }

 async function searchProducts(q: string)  {
    try {
      setItems(null);
      const res = await apiAxios
          .get('/search',{ params: {q, 'by': searchBy.value}});
      setItems(res.data['products']);
    } catch (e) {
      setItems([]);
      console.log(e);
    }
  }
</script>
