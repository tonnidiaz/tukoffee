<template>
    <ion-textarea v-if="textarea" label-placement="floating" fill="solid" color="dark"/>
    <ion-input v-else
        label-placement="floating"
        fill="solid"
        color="dark"
    />
</template>
<script setup lang="ts">
import { IonInput, IonTextarea } from "@ionic/vue";
defineProps({
    textarea: Boolean
})
</script>
