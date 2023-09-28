<template>
    <ion-page>
        <Appbar :title="product?.name" :loading="!product">
            <button
                @click="openPopover"
                id="open-action-sheet"
                class="btn btn-sm fs-20 btn-ghost p-0 w-35px h-35px rounded-full"
            >
                <ion-icon :md="ellipsisVertical"></ion-icon>
            </button>
            <ion-popover
                :event="popoverEvent"
                :is-open="popoverOpen"
                @did-dismiss="popoverOpen = false"
                class=""
            >
                <div class="bg-base-100">
                    <ul class="menu">
                        <li v-if="isAdmin()">
                            <a
                                @click="()=>{ hidePopover(); addProductStore.setForm(product!); ionRouter.push('/edit/product'); }"
                                >Edit</a
                            >
                        </li>
                        <li v-if="isAdmin()"><a>Delete</a></li>
                    </ul>
                </div>
            </ion-popover>
        </Appbar>
        <ion-content>
            <Refresher :on-refresh="init" />
            <div class="" v-if="product">
                <div class="mt-2">
                    <div
                        class="image-area bg-base-100 w-full relative flex flex-col items-center justify-center border-0"
                    >
                        <div
                            class="px-2 img-wrapper relative flex items-center"
                        >
                            <img
                                v-if="product.images?.length"
                                class="img"
                                :src="product.images[selectedImg].url"
                                alt=""
                            />
                            <i
                                v-else
                                class="fi fi-rr-image-slash fs-70 text-gray-600"
                            ></i>
                        </div>
                        <div
                            v-if="product.images?.length"
                            class="relative h-80px thumbnails flex overflow-scroll gap-2 items-center px-2 flex-shrink-0"
                        >
                            <div
                                @click="() => (selectedImg = i)"
                                class="flex-shrink-0 w-80px h-80px flex items-center justify-center"
                                v-for="(e, i) in product.images"
                            >
                                <img :src="e.url" alt="" />
                            </div>
                        </div>
                    </div>
                    <div class="p-">
                        <div class="p-3 mt-1 shadow-1 bg-base-100">
                            <h2 class="font- fw-6 fs-22">
                                {{ product.name }}
                            </h2>
                            <div class="mt-0">
                                <p>
                                    {{ product.description }}
                                </p>
                            </div>
                        </div>
                        <div
                            class="mt-2 m-auto w-full fle shadow-1 bg-base-100 p-3"
                        >
                            <h3>You may also like</h3>
                            <div class="mt-3 flex overflow-scroll gap-2">
                                <ProductCard
                                    v-if="related"
                                    class="flex-shrink-0 w-50p"
                                    v-for="e in related"
                                    :product="e"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div
                v-else
                class="p-2 flex flex-col w-full h-full justify-center items-center"
            >
                <h3>Failed to fetch product</h3>
            </div>
        </ion-content>
        <ion-footer v-if="product" class="bg-base-100">
            <ion-toolbar class="">
                <div class="p-3 flex flex-col items-center gap-2">
                    <div class="flex w-full items-center justify-between">
                        <span
                            v-if="product.quantity"
                            class="badge badge-primary"
                        >
                          {{ product.quantity}}  In stock
                        </span>
                        <span v-else class="badge badge-neutral">
                            Out of stock
                        </span>

                        <Rating v-model="form.rating" :cancel="false" c />
                    </div>
                    <div class="flex w-full items-center justify-between">
                        <span class="fw-8"
                            >R{{ product.price.toFixed(2) }}</span
                        >

                        <tu-button
                            :on-click="addRemoveCart"
                            :class="`rounded-full btn-sm h-30px flex items-center justify-center ${
                                inCart(product) ? 'btn-accent' : 'btn-danger'
                            }`"
                        >
                            <span
                                class="flex items-center gap-1"
                                v-if="!inCart(product)"
                            >
                                <span>
                                    <i
                                        class="fi fi-rr-shopping-cart-add fs-18"
                                    ></i>
                                </span>
                                <span>Add</span>
                            </span>

                            <span class="flex items-center gap-1" v-else>
                                <span>
                                    <i class="fi fi-rr-cart-minus fs-18"></i>
                                </span>
                                <span>Remove</span>
                            </span>
                        </tu-button>
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
import { onMounted, ref } from "vue";
import {
    IonPage,
    IonContent,
    IonFooter,
    IonToolbar,
    IonButton,
    IonToast,
    IonIcon,
    IonPopover,
    useIonRouter,
} from "@ionic/vue";
import { useRouter, useRoute } from "vue-router";
import { apiAxios, apiURL } from "@/utils/constants";
import axios from "axios";
const router = useRouter();
const route = useRoute();
const { id } = route.params;
import Appbar from "@/components/Appbar.vue";
import Refresher from "@/components/Refresher.vue";
import ProductCard from "@/components/ProductCard.vue";
import TuButton from "@/components/TuButton.vue";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import { ellipsisVertical } from "ionicons/icons";
import { useAddProductStore } from "@/stores/addProduct";
const userStore = useUserStore();
const { cart, user } = storeToRefs(userStore);

const addProductStore = useAddProductStore();

const related = ref<any[]>();
const product = ref<{ [key: string]: any }>();
const form = ref<{ [key: string]: any }>({ rating: 2 });
const menu = ref<any>();
const toastOpen = ref(false);
const selectedImg = ref(0);
const ionRouter = useIonRouter();
const popoverOpen = ref(false),
    popoverEvent = ref<Event>();

    const isAdmin = ()=> user.value?.permissions > 1
function openPopover(e: Event) {
    popoverEvent.value = e;
    popoverOpen.value = true;
}
function hidePopover() {
    popoverOpen.value = false;
}
function inCart(p: any) {
    return cart.value?.products.find((it: any) => it.product._id == p._id);
}

const toggle = (event: any) => {
    menu.value.toggle(event);
};

const addRemoveCart = async (e: any) => {
    try {
        const act = inCart(product.value) ? "remove" : "add";
        console.log(act);
        const fd = new FormData();
        fd.append("product", product.value?._id);
        const res = await apiAxios.post(`/user/cart?action=${act}`, fd);
        userStore.setCart(res.data.cart);
    } catch (error) {
        console.log(error);
    }
};
async function getRelated() {
    try {
        related.value = undefined;
        const res = await apiAxios.get(
            `/products?q=related&pid=${product.value?.pid}`
        );
        related.value = res.data.data;
    } catch (error) {
        console.log(error);
        related.value = [];
    }
}
async function getProduct() {
    product.value = undefined;
    const res = await axios.get(`${apiURL}/products?pid=${id}`);
    if (res.data.data) {
        product.value = res.data.data[0];
    }
    console.log(product.value);
}

const init = async () => {
    await getProduct();
    await getRelated();
};
onMounted(() => {
    init();
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
            object-fit: cover;
        }
    }

    img {
        object-fit: contain;
        height: 100%;
    }

    .thumbnails {
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.8);
        width: 100%;
    }
}

:root {
    --ion-toolbar-background: var(--bg-base-100);
}

.m-auto {
    margin-left: auto !important;
    margin-right: auto !important;
}
</style>
