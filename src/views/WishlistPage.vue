<template>
    <ion-page>
        <Appbar title="Wishlist"/> 
        <ion-content :fullscreen="true"></ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';

</script>