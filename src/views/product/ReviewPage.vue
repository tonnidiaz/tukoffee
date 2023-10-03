<template>
    <ion-page>
        <Appbar title="Write a review" :show-cart="false" />

        <ion-content :fullscreen="true"> 
        <ReviewView/>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import Appbar from "@/components/Appbar.vue";
import ReviewView from "@/components/ReviewView.vue";

import { IonPage, IonContent } from "@ionic/vue";
</script>
