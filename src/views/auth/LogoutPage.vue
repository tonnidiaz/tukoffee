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
    IonContent} from "@ionic/vue";
import { onMounted} from 'vue';

onMounted(() => {
    localStorage.removeItem('authToken')
    location.href = '/'
});

</script>