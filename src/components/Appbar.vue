<template>
    <ion-header class="ion-no-border">
            <ion-toolbar>
                <ion-buttons slot="start">
                   <ion-button @click="()=>router.back()" slot="icon-only">
                    <i class="fi fi-ss-angle-left fs-18"></i>
                   </ion-button>
                </ion-buttons>
                <ion-title class="text-gray-600">{{ title }}</ion-title>
                <ion-buttons slot="end">
                    <CartBtn v-if="showCart"/>
                </ion-buttons>
            </ion-toolbar>
        </ion-header>
</template>
<script setup lang="ts">
import {IonTitle, IonHeader, IonToolbar,IonButton, IonButtons} from '@ionic/vue';
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