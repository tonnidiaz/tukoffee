<template>
    <ion-header class="ion-no-border">
            <ion-toolbar>
                <ion-buttons slot="start">
                   <ion-button shape="round" @click="()=>router.back()" slot="icon-only">
                    <i class="fi fi-br-angle-left fs-18"></i>
                   </ion-button>
                </ion-buttons>
                <ion-title  class="fs-17 text-center">{{ title }}</ion-title>
                <ion-buttons slot="end">
                    <CartBtn v-if="showCart"/>
                    <slot/>
                </ion-buttons>
                <ion-progress-bar type="indeterminate"></ion-progress-bar>

            </ion-toolbar>
        </ion-header>
</template>
<script setup lang="ts">
import {IonTitle, IonHeader, IonToolbar,IonButton, IonButtons,IonProgressBar} from '@ionic/vue';
import CartBtn from '@/components/CartBtn.vue';  
import { useRouter } from 'vue-router';
const router = useRouter()
defineProps({
    title: String,
    showCart: {
        type: Boolean,
        default: true
    }
})
</script>