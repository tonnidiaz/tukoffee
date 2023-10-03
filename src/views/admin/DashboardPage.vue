<template>
    <ion-page>
        <Appbar title="Dashboard" :show-cart="false">
        <DropdownBtn :items="[
            {label: 'Back to home', cmd: ()=> toHome()}
        ]"/>
        </Appbar>
        <ion-content :fullscreen="true">
        <InkWell class="p-4 bg-primary w-150px" :on-long-press="()=>{
            console.log('Long press')
        }" @click="()=>{
            console.log('Click')
        }">
            Hello fools
        </InkWell>
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
import Appbar from '@/components/Appbar.vue';
import DropdownBtn from "@/components/DropdownBtn.vue";
import InkWell from "@/components/InkWell.vue";
import { toHome } from "@/utils/funcs";

</script>