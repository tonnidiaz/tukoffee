<template>
    <ion-modal :can-dismiss='canDismiss' :ref="ref" :trigger="trigger" :initial-breakpoint="initialBreakpoint" :breakpoints="breakpoints" class="h-auto" mode="md">
        <slot/>
    </ion-modal>
</template>
<script setup lang="ts">
import { IonModal } from "@ionic/vue";
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
