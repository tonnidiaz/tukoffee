<template>
    <ion-page>
        <Appbar title="Account settings" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div class="h-full py-0">
  
                <div class="p-3 my-1 bg-base-100">
                    <tu-btn expand="block" color="dark" ionic>
                        Change password</tu-btn
                    >
                </div>
                <div class="p-3 my-1 bg-base-100">
                    <tu-btn expand="block" color="danger" ionic>
                        <span><i class="fi fi-sr-triangle-warning"></i></span>
                        &nbsp;Delete account</tu-btn
                    >
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonContent, IonInput } from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
</script>
