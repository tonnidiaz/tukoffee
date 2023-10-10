<template>
    <ion-page>
        <Appbar
            :title="mode == 'add' ? 'New product' : 'Edit product'"
            :show-cart="false"
            :show-back="false"
        />
        <ion-content :fullscreen="true">
            <div class="px-3 py-1 bg-base-100 h-full">
                <tu-form id="form" :onSubmit="onFormSubmit"  class="mt-3">
                    <div class="form-control my-1">
                        <tu-field
                            label="Product name:"
                            required
                            v-model="form.name"
                        />
                    </div>
                    <div class="form-control my-1">
                        <tu-field
                            label="Description:"
                            required
                            v-model="form.description"
                        />
                    </div>
                    <div class="form-control my-1">
                        <tu-field
                            label="Price:"
                            type="number"
                            placeholder="In rands"
                            required
                            v-model="form.price"
                        />
                    </div>
                    <div v-if="form.on_sale" class="form-control my-1">
                        <tu-field
                            label="Sale price:"
                            placeholder="In rands"
                            type="number"
                            required
                            v-model="form.sale_price"
                        />
                    </div>
                    <div class="form-control my-1">
                        <tu-field
                            label="Quantity:"
                            type="number"
                            required
                            v-model="form.quantity"
                        />
                    </div>
                    <div class="form-control my-1">
                        <tu-field
                            label="Weight (KG):"
                            type="number"
                            
                            v-model="form.weight"
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
                                v-for="(img, i) in tempImgs"
                            >
                                <ion-img :src="img.url ?? img.file"></ion-img>
                                <div v-if="!img.loading" class="thumb-overlay">
                                    <tu-btn
                                    :ionic="false"
                                        :on-click="() => delImg(i)"
                                        type="button"
                                        class="btn btn-sm btn-ghost btn-circle"
                                    >
                                        <i
                                            class="fi fi-br-cross fs-18 text-gray-300"
                                        ></i>
                                    </tu-btn>
                                </div>
                                <div v-if="img.loading" class="thumb-overlay">
                                    <ion-spinner color="light"></ion-spinner>
                                </div>
                            </ion-thumbnail>
                        </div>
                    </div>
                    <div
                        class="my-2 flex gap-2 flex-wrap items-center justify-center"
                    >
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
                <div class="form-control  bg-base-100">
                    <tu-btn
                        :ionic="true"
                        type="submit"
                        color="dark"
                        class="w-full"
                        >{{
                            mode == "add" ? "Add product" : "Save changes"
                        }}</tu-btn
                    >
                </div>
                </tu-form>

                <!-- Loading -->
                <ion-loading
                    :is-open="loading"
                    @did-dismiss="loading = false"
                    message="Please wait..."
                    class="tu"
                />
            </div>
        </ion-content>
       
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonContent, IonFooter, IonToolbar,
    IonThumbnail,
    IonInput,
    IonCheckbox,
    IonImg,
    IonSpinner,
    IonText,
    IonLoading,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { onBeforeMount, onBeforeUnmount, onMounted, onUnmounted, ref } from "vue";
import { Capacitor } from "@capacitor/core";
import { TypeImgs } from "@/stores/addProduct";
import { storeToRefs } from "pinia";
import { Cloudinary } from "@capawesome/capacitor-cloudinary";

import { useAppStore } from "@/stores/app";
import { useRoute, useRouter } from "vue-router";
import { apiAxios } from "@/utils/constants";
import { useFormStore } from "@/stores/form";
import { errorHandler, hideModal, saveProduct, uploadImage } from "@/utils/funcs";
import { FilePicker } from "@capawesome/capacitor-file-picker";

const appStore = useAppStore();
const formStore = useFormStore();
const { tempImgs, form } = storeToRefs(formStore);
const { setTempImgs } = formStore;

const loading = ref(false);
const router = useRouter();
const route = useRoute();

const props = defineProps({
    mode: {
        type: String,
        default: 'add'
    },
    product: Object
})
const delImg = async (i: number) => {


    const _form = form.value;
    try {
        loading.value = true;
        //Delete image from clud
        const { publicId } = _form.images[i];
        const res = await apiAxios.post(`/cloudinary`, {
            act: "del",
            publicId,
            product: _form._id,
        });
        console.log(res.data);
        form.value.images.splice(i, 1);
        tempImgs.value.splice(i, 1);
        loading.value = false;
    } catch (e) {
        console.log(e);
        errorHandler(e, "Failed to delete image", true);
    }
};
const initialize = async () => {
    await Cloudinary.initialize({ cloudName: "sketchi" });
};
const importImg = async () => {
    const res = await FilePicker.pickFiles({
        multiple: false,
        types: ["image/*"],
    });

    const _imgs: TypeImgs[] = res.files.map((it) => {
        return {
            loading: true,
            file: Capacitor.convertFileSrc(it.path!),
        };
    });
    const existingImgs = form.value.images ?? [];
    const oldTempImgs = tempImgs.value;
    setTempImgs([...tempImgs.value, ..._imgs]);
    res.files.forEach(async (it, index) => {
        const i = oldTempImgs.length + index;
        const res = await uploadImage(it.path, appStore.title);
        const data = { url: res.secureUrl, publicId: res.publicId };
        const newImgs = [...existingImgs, data];

        if (props.mode == "edit") {
            try {
                const res = await apiAxios.post("/products/edit", {
                    pid: form.value.pid,
                    images: newImgs,
                });
                form.value.images = newImgs;
                tempImgs.value[i].loading = false;
            } catch (error) {
                console.log(error);
                errorHandler(error);
                formStore.setTempImgs(
                    tempImgs.value.filter((el, index) => index !== i)
                );
            }
        } else {
            form.value.images = newImgs;
            tempImgs.value[i].loading = false;
        }

        console.log("Uploaded");
    });
};

const onFormSubmit = async (e: any) => {
/*     console.log(e)
   const frm  = document.getElementById(e.target.form) as HTMLFormElement | null;
   if (!frm?.checkValidity()) return; */

    const res = await saveProduct(form.value, props.mode);
    if (res) {
         hideModal()
        router.replace(`/product/${res}`);
    } else {
        console.log("Failed to add product");
    }
};
onMounted(() => {
    initialize();
    
    if (props.mode == "edit" && props.product) {
        const formImgs = props.product.images;
        formStore.setTempImgs(formImgs);
        formStore.setForm(props.product)
    }
});
onBeforeUnmount(()=>{
    formStore.setForm({})
    formStore.setTempImgs([])
})
</script>

<style>
.thumb-overlay {
    height: 100%;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: rgba(0, 0, 0, 0.3);
    position: absolute;
}
</style>
