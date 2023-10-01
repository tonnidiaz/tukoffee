<template>
    <ion-header class="ion-no-border border-b border-gray-200">
            <ion-toolbar>
                <ion-buttons slot="start">
                 
                  <button v-if="selectedItems.length" class="btn btn-sm btn-ghost rounded-full w-40px h-40px p-0 "  router-direction="back" @click="()=> appStore.setSelectedItems([])" slot="icon-only">
                    <ion-icon class="w-40px h-20px" :md="close"></ion-icon>
                   </button> 
                 <button v-else-if="showBack" class="btn btn-sm btn-ghost rounded-full w-40px h-40px p-0 "  router-direction="back" @click="console.log('back'); router.back()" slot="icon-only">
                    <ion-icon class="w-40px h-20px" :md="arrowBack"></ion-icon>
                   </button> 
                </ion-buttons>
                <ion-title  class="fs-18 fw-6">{{ selectedItems.length ? `${selectedItems.length} selected` : (title ?? appStore.title) }}</ion-title>
                <ion-buttons slot="end">
                    <CartBtn v-if="showCart"/> 
                    <slot/>
                </ion-buttons>
                <ion-progress-bar v-if="loading" type="indeterminate"></ion-progress-bar>

            </ion-toolbar> 
        </ion-header>
</template>
<script setup lang="ts">
import {IonTitle, IonHeader, IonToolbar,IonButton, IonButtons,IonProgressBar, IonIcon, IonNavLink} from '@ionic/vue';
import CartBtn from '@/components/CartBtn.vue';  
import { useRouter } from 'vue-router';
import { arrowBack, close } from 'ionicons/icons';
import { useAppStore } from '@/stores/app';
import { storeToRefs } from 'pinia';

const appStore = useAppStore()
const {selectedItems} = storeToRefs(appStore)

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