<template>

    <ion-page>
        <ion-header class="ion-no-border ">
            <ion-toolbar>
                <ion-buttons slot="start">
                    <CartBtn/>
                </ion-buttons>
                <ion-title class="text-gray-600">Tunedbass</ion-title>
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
  
                <div class="my-3">
                    <!-- Top selling section -->
                    <ion-text class="fs-18">Top selling</ion-text>
                    <div class="mt-4 flex overflow-scroll ">
                        <InkWell @click="() => router.push(`/product/${i}`)" v-for="(e, i) in new Array(20).fill(3)" class="flex flex-column align-items-center	 flex-shrink-0">
                            <div class="flex flex-column align-items-center">
                                     <ion-avatar  class="">
                            <img
                                alt="Silhouette of a person's head"
                                :src="randomImg()"
                            />
                        </ion-avatar>
                        <ion-text class="mt-1 orange fw-4">R{{i*10}}</ion-text>
                        <ion-text>Coffee {{ i }}</ion-text>
                            </div>
                          
                        </InkWell>
                     
                    </div>
                </div>
                <div class="my-3">
                    <!-- Special section -->
                    <ion-text class="fs-18">Today's special</ion-text>
                    <div class="mt-4 flex gap- overflow-scroll ">
                        <InkWell v-for="(e, i) in new Array(20).fill(3)" class="flex flex-column align-items-center	 flex-shrink-0">
                               <ion-avatar  class="">
                            <img
                                alt="Silhouette of a person's head"
                                :src="randomImg()"
                            />
                        </ion-avatar>
                        <ion-text class="mt-1 orange fw-4">R{{i*10}}</ion-text>
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
import { ref } from "vue";
import InkWell from '@/components/InkWell.vue';
import {randomImg} from '@/utils/funcs';
import { useRouter } from 'vue-router';
import CartBtn from '@/components/CartBtn.vue';

const router = useRouter()
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