<template>
    <ion-page>
        <Appbar title="Research Facility" />
        <ion-content :fullscreen="true">
            <div class="p-4">
                <div class="indicator">
                    <span class="indicator-item badge badge-secondary"
                        >99+</span
                    >
                    <button @click="pickMedia" class="btn btn-secondary">inbox</button>
                </div>

                <div class="my-5">
<ion-item router-link="/map"><ion-label>Map</ion-label></ion-item>

                    <audio controls :src="url"></audio>
                    <ion-list mode="ios">
                        <ion-item-sliding>
                            <ion-item mode="ios"
                            href="https://thabiso.vercel.app"
                            v-for="(e, i) in []"
                        >
                            <ion-avatar slot="start">
                                <ion-img :src="randomImg()"></ion-img>
                            </ion-avatar>
                            <ion-label> List item {{ i }} </ion-label>
                        </ion-item>
                        <ion-item-options slot="end">
                            <ion-item-option color="dark">
                                    <i class="fi fi-sr-trash text-white"></i>
                            </ion-item-option>
                        </ion-item-options>
                        </ion-item-sliding>
                        
                    </ion-list>
                    <ion-infinite-scroll mode="ios" @ionInfinite="ionInfinite">
                        <ion-infinite-scroll-content mode="ios"
                            loading-text="Hang on..."
                            loading-spinner="bubbles"
                        ></ion-infinite-scroll-content>
                    </ion-infinite-scroll>
                </div>
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
    IonButtons,
    IonInfiniteScrollContent,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Capacitor } from '@capacitor/core';

import { randomImg } from "@/utils/funcs";
import { ref } from "vue";
import { list } from "ionicons/icons";
import { FilePicker } from '@capawesome/capacitor-file-picker';

const url = ref("")
const items = ref(new Array(50).fill(0));
const testurl = "https://v3.cdnpk.net/videvo_files/video/free/2019-11/large_watermarked/190301_1_25_11_preview.mp4"
const generateItems = () => {
    for (let i = 0; i < 50; i++) {
        items.value.push(i);
    }
};
const ionInfinite = (e: any) => {
    generateItems();
    setTimeout(() => e.target.complete(), 500);
};

const pickMedia = async () => {
  const result = await FilePicker.pickFiles({
    types: ['audio/mpeg'],
    multiple: false,
  });
  const {files} = result
  if (files.length){
    const  {path} = files[0]
    if (!path) return;
    url.value = Capacitor.convertFileSrc( path)
    console.log(url.value)
  }
};
</script>
