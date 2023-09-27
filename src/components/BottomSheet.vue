<template>
    <ion-modal :ref="ref" :trigger="trigger" :initial-breakpoint="0.25" :breakpoints="breakpoints">
       <!--  <ion-content class="ion-padding flex flex-col justify-center items-center relative bg-base-100">
            <slot />
        </ion-content> -->
        <slot/>
    </ion-modal>
</template>
<script setup lang="ts">
import { IonModal, IonContent } from "@ionic/vue";
defineProps({
    ref: String,
    trigger: String,
    breakpoints: {
        type: Array,
        default: [0, .15, 0.25, 0.5, 0.75]
    }
});
</script>
