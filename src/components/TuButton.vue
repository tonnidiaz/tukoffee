<template>
    <ion-button expand="block" color="dark" @click="_onClick" :disabled="disabled" v-if="ionic">
        <slot /></ion-button>
    <button v-else @click="_onClick" :disabled="disabled" class="btn flex items-center gap-3">
        <span v-if="disabled" class="loading loading-spinner fs-14 hidden"></span>
        <slot />
    </button>
</template>
<script setup lang="ts">
import { IonButton } from "@ionic/vue";
import { ref } from "vue";
const disabled = ref(false)
const props = defineProps({
    onClick: Function,
    ionic: {type: Boolean, default: true}
})

const _onClick = async (e:any) => { 
    e.preventDefault()
    disabled.value = true
    if (props.onClick) await props.onClick(e)
    disabled.value = false
return false;
 }
</script>
