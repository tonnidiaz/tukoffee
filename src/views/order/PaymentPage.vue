<template>
    <ion-page>
        <Appbar title="Payment" :show-cart="false" />
        <ion-content :fullscreen="true">
            <iframe
                class="h-full w-full overflow-hidden"
                ref="frame"
                src="https://paystack.com/pay/iu0dre0s-o"
                frameborder="0"
            ></iframe>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonMenuToggle,
    IonButtons,
    IonRippleEffect,
    IonSearchbar,
    IonText,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { onMounted, ref } from "vue";

const frame = ref<HTMLIFrameElement>()
onMounted(()=>{
    const _frame = (frame.value)
    if (_frame)
    {_frame.onload = (e: any)=>{
        console.log(e.target.contentWindow.location.href)
        alert('ok')
    }}
})
</script>
