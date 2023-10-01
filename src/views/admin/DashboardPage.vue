<template>
    <ion-page>
        <Appbar title="Dashboard" :show-cart="false">
        <DropdownBtn :items="[
            {label: 'Back to home', cmd: ()=> $router.push('/')}
        ]"/>
        </Appbar>
        <ion-content :fullscreen="true"></ion-content>
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
import Appbar from '@/components/Appbar.vue';
import DropdownBtn from "@/components/DropdownBtn.vue";

</script>