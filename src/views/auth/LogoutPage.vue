<template>
    <ion-page>
        <ion-content :fullscreen="true">
                <div class="w-full h-full flex justify-center items-center">
                    <h2 class="text-black fs-20">Loging out...</h2>
                </div>
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
    IonInfiniteScroll,useIonRouter
} from "@ionic/vue";
import {onBeforeMount, onMounted} from 'vue';
import { useRouter, useRoute,  } from "vue-router";
const router = useRouter()
const ionRouter = useIonRouter()

onMounted(() => {
    console.log(localStorage.getItem('authToken'))
    localStorage.removeItem('authToken')
    console.log('Pushing')
    location.href = '/'
});

</script>