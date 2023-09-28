<template>
    <div class="p-3 bg-base-100">
        <h3>New Product</h3>
        <form action="#" class="mt-3">
            <div class="form-control my-1">
                <ion-input
                    label="Product name:"
                    label-placement="floating"
                    color="dark"
                    fill="solid"
                    :required="true"
                    v-model="form.name"
                />
            </div>
            <div class="form-control my-1">
                <ion-input
                    label="Description:"
                    label-placement="floating"
                    color="dark"
                    fill="solid"
                    :required="true"
                    v-model="form.description"
                />
            </div>
            <div class="form-control my-1">
                <ion-input
                    label="Price:"
                    label-placement="floating"
                    color="dark"
                    type="number"
                    fill="solid"
                    :required="true"
                    v-model="form.price"
                />
            </div>
            <div class="form-control my-1">
                <ion-input
                    label="Quantity:"
                    label-placement="floating"
                    color="dark"
                    fill="solid"
                    type="number"
                    :required="true"
                    v-model="form.quantity"
                />
            </div>

            <div class="my-2">
                <div class="flex justify-between">
                    <ion-text>Images</ion-text>
                    <button
                        @click="importImg"
                        type="button"
                        class="btn btn-sm btn-ghost"
                    >
                        <i class="fi fi-br-plus fs-18"></i>
                    </button>
                </div>
                <div class="mt-2 mb-4 flex gap-2 overflow-scroll">
                    <ion-thumbnail class="relative w-65px h-65px" v-for="img in tempImgs">
                        <ion-img :src="img.url ?? img.file"></ion-img>
                        <div v-if="!img.loading" class="thumb-overlay">
                            <button type="button" class="btn btn-sm btn-ghost">
                                <i
                                    class="fi fi-br-cross fs-18 text-gray-300"
                                ></i>
                            </button>
                        </div>
                        <div v-if="img.loading" class="thumb-overlay">
                            <ion-spinner color="light"></ion-spinner>
                        </div>
                    </ion-thumbnail>
                </div>
            </div>
            <div class="my-2 flex gap-2 flex-wrap items-center justify-center">
                <ion-checkbox
                    mode="ios"
                    color="secondary"
                    v-model="form.top_selling"
                    label-placement="end"
                    >Top selling</ion-checkbox
                >
                <ion-checkbox
                    mode="ios"
                    color="secondary"
                    v-model="form.on_special"
                    label-placement="end"
                    >On special</ion-checkbox
                >
                <ion-checkbox
                    mode="ios"
                    color="secondary"
                    v-model="form.on_sale"
                    label-placement="end"
                    >On sale</ion-checkbox
                >
            </div>
            <div class="form-control">
                <ion-button type="submit" color="dark" class="w-full"
                    >Add product</ion-button
                >
            </div>
        </form>
    </div>
</template>

<script setup lang="ts">
import { Obj } from "@/utils/classes";
import { randomImg } from "@/utils/funcs";
import { FilePicker } from "@capawesome/capacitor-file-picker";
import {
    IonPage,
    IonHeader,
    IonThumbnail,
    IonInput,
    IonCheckbox,
    IonButton,
    IonImg,
    IonSpinner,
    IonRippleEffect,
    IonSearchbar,
    IonText,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import { ref } from "vue";
import { Capacitor } from "@capacitor/core";
import { TypeImgs, useAddProductStore } from "@/stores/addProduct";
import { storeToRefs } from "pinia";
const form = ref<Obj>({ top_selling: true });

const addProductStore = useAddProductStore()
const {tempImgs} = storeToRefs(addProductStore)
const { setTempImgs } = addProductStore

const uploadImg = async ()=>{
    
}

const importImg = async () => {
    const res = await FilePicker.pickImages({
        multiple: true
    });
    console.log(res.files);
    const _imgs: TypeImgs[] = res.files.map((it) => {
            return {
                loading: true,
                file: Capacitor.convertFileSrc(it.path!),
            };
        })
        console.log(_imgs)
    setTempImgs([...tempImgs.value, ..._imgs]
    );
};
</script>

<style>
.thumb-overlay {
    height: 100%;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: rgba(0, 0, 0, 0.5);
    position: absolute;
}
</style>
