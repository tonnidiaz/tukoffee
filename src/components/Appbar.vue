<template>
    <ion-header class="ion-no-border border-b border-gray-200">
            <ion-toolbar>
                <ion-buttons slot="start">
                 
                  <button v-if="selectedItems.length" class="btn btn-sm btn-ghost rounded-full w-40px h-40px p-0 "  router-direction="back" @click="()=> appStore.setSelectedItems([])" slot="icon-only">
                    <ion-icon class="w-45px h-25px fs-40" :md="close"></ion-icon>
                   </button> 
           <button v-else-if="showBack" class="btn btn-sm btn-ghost rounded-full w-40px h-40px p-0 "  router-direction="back" @click="onBack($route.path, $router)" slot="icon-only">
                    <ion-icon class="w-40px h-25px" :md="arrowBack"></ion-icon>
                   </button>
<!--                    <ion-back-button  @click="onBack($route.path, $router)" v-else-if="showBack"></ion-back-button>
 -->                </ion-buttons>
                <ion-title  class="fs-18 fw-6">{{ selectedItems.length ? `${selectedItems.length} selected` : (title ?? appStore.title) }}</ion-title>
                <ion-buttons slot="end">
                    <CartBtn v-if="showCart"/> 
                    <slot/>
                </ion-buttons>
                <ion-progress-bar color="medium" v-if="loading" type="indeterminate"></ion-progress-bar>

            </ion-toolbar> 
        </ion-header>
</template>
<script setup lang="ts">
import {IonTitle, IonHeader, IonToolbar,IonBackButton, IonButtons,IonProgressBar, IonIcon, useBackButton, useIonRouter} from '@ionic/vue';
import CartBtn from '@/components/CartBtn.vue';  
import { useRouter } from 'vue-router';
import { arrowBack, close } from 'ionicons/icons';
import { useAppStore } from '@/stores/app';
import { storeToRefs } from 'pinia';
import { onBack } from '@/utils/funcs';

const appStore = useAppStore()
const {selectedItems} = storeToRefs(appStore)
const ionRouter = useIonRouter()
const router = useRouter()
defineProps({
    title: {type: String},
    showCart: {
        type: Boolean,
        default: true
    },
    showBack: {
        type: Boolean,
        default: true
    },
    loading: {
        type: Boolean,
        default: false
    },
})
</script>