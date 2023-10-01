<template>
    <ion-page>
        <Appbar :title="mode == 'add' ? 'New product' : 'Edit product'"/> 
        <ion-content :fullscreen="true">
        <AddProductView :mode="(mode as string)"/>
    </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import { useRoute } from "vue-router";
import AddProductView from "@/components/AddProductView.vue";

const route = useRoute()
const {mode} = route.params
</script>