<template>
    <ion-page>
        <Appbar title="Reset password" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div class="p-3 bg-base-100 flex flex-col justify- h-full">
                    <component :is="steps[step]"/>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,

} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";

import Step2 from "../forgot/Step2.vue"
import Step3 from "../forgot/Step3.vue"
import { useAuthStore } from "@/stores/auth";
import { storeToRefs } from "pinia";
import Step1 from "./Step1.vue";
import { onMounted } from "vue";

const authStore = useAuthStore()

const {step} = storeToRefs(authStore)
const steps = [
    Step1, Step2, Step3
]

onMounted(()=>{
    step.value = 0
})
</script>

<style>
ion-button.tu {
    box-shadow: none !important;
    --box-shadow: 0 1px 1px 2px rgba(185, 185, 185, 0.192) !important;
}
input:-internal-autofill-selected {
    background: red !important;
}
</style>
