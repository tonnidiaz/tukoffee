<template>
    <ion-header class="ion-no-border border-b border-gray-200">
            <ion-toolbar>
                <ion-buttons slot="start">
                  <ion-button router-direction="back" @click="()=> router.back()" slot="icon-only">
                  <ion-icon :ios="arrowBack" />
                   </ion-button> 
       
                </ion-buttons>
                <ion-title  class="fs-18">{{ title }}</ion-title>
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
import { arrowBack } from 'ionicons/icons';
const router = useRouter()
defineProps({
    title: String,
    showCart: {
        type: Boolean,
        default: true
    },
    loading: {
        type: Boolean,
        default: false
    },
})
</script>