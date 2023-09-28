<template>
    <div class="p-3 bg-base-100">
        <form action="#" class="mt-3" @submit="onFormSubmit">
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
                    <ion-thumbnail
                        class="relative w-65px h-65px"
                        v-for="img in tempImgs"
                    >
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
import { saveProduct, uploadImage } from "@/utils/funcs";
import { FilePicker } from "@capawesome/capacitor-file-picker";
import {
    IonThumbnail,
    IonInput,
    IonCheckbox,
    IonButton,
    IonImg,
    IonSpinner,
    IonText,
} from "@ionic/vue";
import { onMounted } from "vue";
import { Capacitor } from "@capacitor/core";
import { TypeImgs, useAddProductStore } from "@/stores/addProduct";
import { storeToRefs } from "pinia";
import { Cloudinary } from "@capawesome/capacitor-cloudinary";

import { useAppStore } from "@/stores/app";
import { useRouter } from "vue-router";

const appStore = useAppStore();
const addProductStore = useAddProductStore();
const { tempImgs, form } = storeToRefs(addProductStore);
const { setTempImgs } = addProductStore;

const router = useRouter()

const initialize = async () => {
    await Cloudinary.initialize({ cloudName: "sketchi" });
    console.log("Cloudinary initialized");
};
const importImg = async () => {
    const res = await FilePicker.pickFiles({
        multiple: true,
        types: ["image/*"],
    });

    const _imgs: TypeImgs[] = res.files.map((it) => {
        return {
            loading: true,
            file: Capacitor.convertFileSrc(it.path!),
        };
    });
    console.log(_imgs);
   const existingImgs = form.value.images ?? []
    setTempImgs([...tempImgs.value, ..._imgs]);
     res.files.forEach(async (it, i) => {
        const res = await uploadImage(it.path, appStore.title);
        console.log(res);
        const data = {url: res.secureUrl, publicId: res.publicId}
        form.value.images = [...existingImgs, data]
        tempImgs.value[i].loading = false
        console.log('Uploaded')
    });
};

const onFormSubmit = async (e: any)=>{
    e.preventDefault()
    console.log(form.value)
    const res = await saveProduct(form.value, 'add')
    if (res){
        router.push(`/product/${res}`)
    }else{
        console.log('Failed to add product')
    }
}
onMounted(() => {
    initialize();
});
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
