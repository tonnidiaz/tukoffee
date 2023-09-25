<template>
    <ion-page>
        <Appbar :title="product?.name">
            <ion-button @click="toggle"
                    aria-haspopup="true"
                    aria-controls="overlay_menu" shape="round" slot="icon-only">
                <i class="fi fi-br-menu-dots-vertical fs-20"></i>
            </ion-button>
            <Menu
                    ref="menu"
                    id="overlay_menu"
                    :model="[
                        {
                            label: 'Edit',
                            icon: 'fi fi-rr-edit',
                        },
                        {
                            label: 'Delete',
                            icon: 'fi fi-rr-trash',
                            command: ()=>{ toastOpen = true  }
                        
                        },
                    ]"
                    :popup="true"
                />
        </Appbar>
        <ion-content>
 
            <div class="" v-if="product">
                <div class="">
                    <div
                        class="image-area surface-card w-full relative flex flex-column align-items-center justify-content-center border-0"
                    >
                        <div class="px-2 img-wrapper relative">
                            <img
                                class="img"
                                :src="product.images[selectedImg].url"
                                alt=""
                            />
                        </div>
                        <div
                            class="relative h-82px thumbnails flex overflow-scroll gap-2 align-items-center px-2 flex-shrink-0"
                        >
                            <ion-thumbnail
                                @click="() => (selectedImg = i)"
                                class="flex-shrink-0"
                                v-for="(e, i) in product.images"
                            >
                                <img :src="e.url" alt="" />
                            </ion-thumbnail>
                        </div>
                    </div>
                    <div class="p-2">
                        <div class="p-3 mt-1 card shadow-1 surface-card br-10">
                            <h2 class="font-poppins fs-22">
                                {{ product.name }}
                            </h2>
                            <div class="mt-2">
                                <p>
                                    {{ product.description }}
                                </p>
                            </div>
                            <div class="mt-2 m-auto w-full flex">
                                <Button
                                    severity="secondary"
                                    label="Continue shopping"
                                    class="m-auto"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div v-else class="p-2 flex flex-column w-full h-full justify-content-center align-items-center">
                    <h3>Failed to fetch product</h3>
            </div>
        </ion-content>
        <ion-footer v-if="product" class="surface-card">
            <ion-toolbar class="">
                <div class="p-3 flex flex-column align-items-center gap-2">
                    <div
                        class="flex w-full align-items-center justify-content-between"
                    >
                        <Badge v-if="product.quantity" value="In stock" />
                        <Badge v-else value="Out of stock" severity="danger" />
                        <Rating v-model="form.rating" :cancel="false" c />
                    </div>
                    <div
                        class="flex w-full align-items-center justify-content-between"
                    >
                        <span class="fw-8"
                            >R{{ product.price.toFixed(2) }}</span
                        >
                        <Button
                            v-if="false"
                            icon="fi fi-rr-shopping-cart-add"
                            size="small"
                            label="Add"
                        />
                        <Button
                            v-else
                            icon="fi fi-rr-cart-minus"
                            size="small"
                            label="Remove"
                            severity="secondary"
                        />
                    </div>
                </div>
            </ion-toolbar>
        </ion-footer>

        <!-- Toasts -->
        <ion-toast
      :is-open="toastOpen"
      message="This toast will close in 5 seconds"
      :duration="5000"
      @didDismiss="toastOpen = false"
    ></ion-toast>
    </ion-page>
</template>
<script setup lang="ts">
import { onBeforeMount, ref } from "vue";
import {
    IonPage,
    IonContent,
    IonThumbnail,
    IonFooter,
    IonToolbar,
    IonButton,
    IonToast,
} from "@ionic/vue";
import { useRouter, useRoute } from "vue-router";
import { apiURL, localhost } from "@/utils/constants";
import axios from "axios";
import Button from "primevue/button";
import Rating from "primevue/rating";
import Badge from "primevue/badge";
import Menu from "primevue/menu";
const router = useRouter();
const route = useRoute();
const { id } = route.params;
import Appbar from "@/components/Appbar.vue";
const product = ref<{ [key: string]: any }>();
const form = ref<{ [key: string]: any }>({ rating: 2 });
const menu = ref<any>();
const toastOpen = ref(false);
const selectedImg = ref(0);

const toggle = (event: any) => {
    menu.value.toggle(event);
};

async function getProduct() {
    const res = await axios.get(`${apiURL}/products?pid=${id}`);
    if (res.data.data) {
        product.value = res.data.data[0];
    }
    console.log(product.value);
}
onBeforeMount(() => {
    getProduct();
});
</script>
<style lang="scss">
.image-area {
    height: calc(35vh + 80px);
    overflow: hidden;
    .img-wrapper {
        flex: auto;
        overflow: hidden;
        position: relative;

        img {
            height: 100%;
        }
    }
    img,
    .img {
        object-fit: contain;
    }
    .thumbnails {
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.8);
        width: 100%;
    }
}
:root {
    --ion-toolbar-background: var(--surface-card);
}

.m-auto {
    margin-left: auto !important;
    margin-right: auto !important;
}
</style>
