<template>
    <ion-page>

        <ion-content :fullscreen="true">
            <MapView/>

        </ion-content>

    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent} from "@ionic/vue";

import MapView from '@/components/MapView.vue';
</script>
