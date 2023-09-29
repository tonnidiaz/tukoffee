<template>
    <ion-page>
        <Appbar title="Payment" :show-cart="false" />
        <ion-content :fullscreen="true">
            <h1>Payment</h1>
            
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
import Appbar from "@/components/Appbar.vue";
import { onMounted, ref } from "vue";



onMounted(() => {
    const win = window as any;
});
</script>
