<template>
    <ion-modal :can-dismiss='canDismiss' :ref="ref" :trigger="trigger" :initial-breakpoint="initialBreakpoint" :breakpoints="breakpoints" class="h-auto">
       <!--  <ion-content class="ion-padding flex flex-col justify-center items-center relative bg-base-100">
            <slot />
        </ion-content> -->
        <slot/>
    </ion-modal>
</template>
<script setup lang="ts">
import { IonModal, IonContent } from "@ionic/vue";
const props = defineProps({
    ref: String,
    noSwipeDismiss: Boolean,
    trigger: String,
    breakpoints: {
        type: Array,
        default: [0, 1]
    },
    initialBreakpoint: {
        type: Number,
        default: 1
    }
});

async function canDismiss(data?: any, role?: string) {
    return !props.noSwipeDismiss ? true : role !== 'gesture';
  }
</script>
