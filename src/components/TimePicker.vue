<template>
    <ion-popover keep-contents-mounted :trigger="trigger">
        <ion-datetime
            mode="ios"
            color="secondary"
            presentation="time"
            :id="`${trigger}-datetime`"
            @ion-change="(e) => onChange(e.detail.value ?? '')"
        ></ion-datetime>
    </ion-popover>
</template>
<script setup lang="ts">
import { IonDatetime, IonPopover } from "@ionic/vue";
import { defineComponent } from "vue";

defineComponent({ name: "TimePicker" });
defineProps({
    onChange: {
        type: Function,
        required: true,
    },
    trigger: String,
});
</script>
