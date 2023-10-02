<template>
    <ion-button class="ic-btn">
        <slot />
    </ion-button>
    <!-- 
         class="btn btn-ghost btn-sm rounded-full p-0 w-35px h-35px">
     -->
</template>
<script setup lang="ts">

import {IonButton} from '@ionic/vue';
</script>
<style lang="scss">
ion-button.ic-btn{
    --color: initial;
    --background: transparent;
 /*    --background-activated: transparent;
    --background-focused: currentColor;
    --background-hover: currentColor; */
    --background-activated-opacity: 0;
    --background-focused-opacity: .12;
    --background-hover-opacity: .04;
    --box-shadow: none
    .button-native{
    }
}
</style>