<template>
    <ion-accordion>
        <ion-item slot="header">
            <ion-label class="fs-18">{{ title }}</ion-label>
        </ion-item>
        <div class="ion-padding" slot="content">
        <slot/>    
        </div
    ></ion-accordion>
</template>
<script setup lang="ts">
import { IonAccordion, IonLabel, IonItem } from "@ionic/vue";

defineProps({
    title: String
})
</script>
