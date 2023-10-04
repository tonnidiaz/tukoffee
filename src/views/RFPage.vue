<template>
    <ion-page>
        <Appbar title="Research Facility" />
        <ion-content :fullscreen="true">
            <div class="p-4 bg-base-100">
                    <tu-form :on-submit="submitForm">
                        <div class="my-1">
                            <tu-field :validator="(val: any)=> {if (val?.length < 3) return 'Name is required'}" autocomplete="name" label="Name:" required/>
                        </div>
                        <div class="my-1">
                            <tu-field auto="email" label="Email:" required type="email"/>
                        </div>
                        <div class="mt-2">
                            <tu-btn color="dark" type="submit" expand="block">Submit</tu-btn>
                        </div>
                    </tu-form>

            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonList,
    IonItem,
    IonImg,
    IonLabel,
    IonContent,
    IonItemSliding,
    IonItemOptions,
    IonItemOption,
    IonModal,
    IonInfiniteScrollContent,
    IonAvatar,
    IonButton,
    IonInfiniteScroll,
modalController,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Capacitor } from "@capacitor/core";

import { randomImg, sleep } from "@/utils/funcs";
import { ref } from "vue";
import { list } from "ionicons/icons";
import { FilePicker } from "@capawesome/capacitor-file-picker";

const url = ref("");
const items = ref(new Array(50).fill(0));
const testurl =
    "https://v3.cdnpk.net/videvo_files/video/free/2019-11/large_watermarked/190301_1_25_11_preview.mp4";
const generateItems = () => {
    for (let i = 0; i < 50; i++) {
        items.value.push(i);
    }
};
const ionInfinite = (e: any) => {
    generateItems();
    setTimeout(() => e.target.complete(), 500);
};

const submitForm = async (e: any) =>{
    await sleep(1500)
    console.log('slept')
}
const pickMedia = async () => {
    const result = await FilePicker.pickFiles({
        types: ["audio/mpeg"],
        multiple: false,
    });
    const { files } = result;
    if (files.length) {
        const { path } = files[0];
        if (!path) return;
        url.value = Capacitor.convertFileSrc(path);
        console.log(url.value);
    }
};

const closeModal = async ()=>{
    console.log('Closing modal')
modalController.dismiss(null, 'close')
}
</script>
