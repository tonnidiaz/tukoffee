<template>

    <ion-page>
        <ion-header class="ion-no-border ">
            <ion-toolbar>
                <ion-buttons slot="start">
                    <CartBtn/>
                </ion-buttons>
                <ion-title class="fs-17 text-center">Tunedbass</ion-title>
                <ion-buttons slot="end">
                    <ion-menu-toggle>
                        <ion-button fill="clear">
                            <i class="fi fi-rr-menu-burger"></i>
                        </ion-button>
                    </ion-menu-toggle>
                </ion-buttons>
            </ion-toolbar>
        </ion-header>
        <ion-content :fullscreen="true">
            <div class="m-3 flex flex-column">
                <IonText>The best coffee in town!</IonText>
                <IonText class="text-xl my-1 font-pacifico fs-30 fw-8"
                    >Grab yours now!</IonText
                >
                <ion-searchbar class="rounded"></ion-searchbar>
  
                <div class="my-2">
                    <!-- Top selling section -->
                    <ion-text class="fs-18">Top selling</ion-text>
                    <div class="mt-2 flex overflow-scroll ">
                        <InkWell v-if="topSelling" @click="() => router.push(`/product/${e.pid}`)" v-for="(e, i) in topSelling" class="flex flex-column align-items-center	 flex-shrink-0">
                            <div class="flex flex-column align-items-center">
                                     <ion-avatar  class="">
                            <img
                                alt=""
                                :src="e.images[0].url"
                            />
                        </ion-avatar>
                        <h5 class="mt-2 text-black fs-14 fw-8">R{{e.price.toFixed(2)}}</h5>
                        <h4 class="fs-16 fw-9" >{{e.name}}</h4>
                            </div>
                          
                        </InkWell>
                     
                    </div>
                </div>
                <div class="my-2">
                    <!-- Special section -->
                    <ion-text class="fs-18">Today's special</ion-text>
                    <div class="mt-2 flex gap- overflow-scroll ">
                        <InkWell  @click="() => router.push(`/product/${e.pid}`)" v-if="special" v-for="(e, i) in special" class="flex flex-column align-items-center	 flex-shrink-0">
                               <ion-avatar  class="">
                            <img
                                alt=""
                                :src="e.images[0].url"
                            />
                        </ion-avatar>
                        <h5 class="mt-2 text-black fs-14 fw-8">R{{e.price.toFixed(2)}}</h5>
                        </InkWell>
                     
                    </div>
                </div>

            </div>
        </ion-content>
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
    IonMenuToggle,
    IonButtons,
    IonRippleEffect,
    IonSearchbar,
    IonText,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import { onBeforeMount, ref } from "vue";
import InkWell from '@/components/InkWell.vue';
import {randomImg} from '@/utils/funcs';
import { useRouter } from 'vue-router';
import CartBtn from '@/components/CartBtn.vue';
import axios from "axios";
import { apiURL } from "@/utils/constants";
const special = ref<any[]>(), topSelling = ref<any[]>();
const router = useRouter()

const getProducts =async (q: string) => { 
    try {
        const res = await axios.get(`${apiURL}/products?q=${q}`)
        return res.data.data
    } catch (error) {
        console.log(error)
        return []
    }
 }

 async function getSpecial() {
    special.value = await getProducts('special')
 }
 async function getTopSelling() {
    topSelling.value = await getProducts('top-selling')
 }

 onBeforeMount(()=>{
    getTopSelling()
    getSpecial()
 })
</script>

<style scoped>


.ripple-parent { 
    position: relative;
    overflow: hidden;

    border: 1px solid #ddd;
  }
  .rectangle {
    width: 300px;
    height: 150px;
  }



</style>