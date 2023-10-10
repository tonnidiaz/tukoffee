<template>
    <div ref="el" class="ion-activatable relative br-6 p-2">
        <IonRippleEffect class="br-10"/>
        <slot />
    </div>
</template>
<script setup lang="ts">
import { GestureDetail, IonRippleEffect, createGesture } from '@ionic/vue';
import { onMounted, ref } from 'vue';
const el = ref<HTMLDivElement>()

const props= defineProps({
    onLongPress: Function
})

const TIMEOUT = 500;
let timeout: any;
const onStart = () => {
  clearGestureTimeout();
  
  timeout = setTimeout(() => {
    if (props.onLongPress){props.onLongPress()}
    timeout = undefined;
  }, TIMEOUT);
}

const onMove = (detail: GestureDetail) => {
  // Allow a little bit of movement
  if (detail.deltaX <= 10 && detail.deltaY <= 10) {
     return;
  }

  clearGestureTimeout();
}

const clearGestureTimeout = () => {
  if (timeout) {
    clearTimeout(timeout);
    timeout = undefined;
  }
}

onMounted(()=>{


})
</script>