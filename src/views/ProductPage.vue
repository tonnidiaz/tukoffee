<template>
    <ion-page>
        <Appbar :title="product?.name" :loading="!product">
            <DropdownBtn
                :items="[
                isAdmin() ? {
                    label: 'Edit',
                    cmd: ()=> {
                        $('#edit-opt').trigger('click')
                        /* formStore.setForm({...product!}); ionRouter.push('/edit/product') */}
                }: null,
       
            ]"
            />
        </Appbar>
        <ion-content>
            <Refresher :on-refresh="init" />
            <div class="" v-if="product">
                <div class="mt-1">
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
                            <h2 class="fw-6 fs-18">
                                {{ product.name }}
                            </h2>
                            <div class="mt-0">
                                <div
                                    class="flex items center gap-3 mb-2 my-3 flex-wrap"
                                >
                                    <ion-text
                                        v-if="product.top_selling"
                                        router-link="/shop/top-selling"
                                        class="badge ion-bg-medium py-3 fs-12"
                                    >
                                        Top selling
                                    </ion-text>
                                    <ion-text
                                        v-if="product.on_sale"
                                        router-link="/shop/sale"
                                        class="badge badge-primary py-3 fs-12"
                                    >
                                        On sale
                                    </ion-text>
                                    <ion-text
                                        v-if="product.on_sale"
                                        router-link="/shop/special"
                                        class="badge ion-bg-medium py-3 fs-12"
                                    >
                                        Special
                                    </ion-text>
                                </div>
                                <p>
                                    {{ product.description }}
                                </p>
                            </div>
                        </div>
                        <div
                            class="my-1 p-3 bg-base-100 flex items-center gap-2"
                        >
                            <span class="relative" style="top: 2px"
                                ><i class="fi fi-ss-star amber fs-16"></i
                            ></span>
                            <span class="fw-6">{{
                                product.rating ?? (0).toFixed(1)
                            }}</span>
                            <ion-text
                                :router-link="`/product/${product.pid}/reviews`"
                                class="ml-2 fw-6 ion-primary"
                                >{{ product.reviews.length }} REVIEWS</ion-text
                            >
                        </div>
                        <div
                            class="my-1 p- bg-base-100"
                        >
                            <table class="table">
                                <tr>
                                    <th colspan="2" class="pt-2 pb-0">
                                        <h3 class="fs-16">SPECIFICATIONS</h3>
                                    </th>
                                </tr>
                                <tbody>
                                    <tr>
                                        <td class="fw-5 py-2">Weight</td>
                                        <td  class=" py-2">{{ product.weight }} KG</td>
                                    </tr>
                                </tbody>
                            </table>
                    </div>
                        <div
                            class="my-1 m-auto w-full fle shadow-1 bg-base-100 p-3"
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
            <button class="hidden" id="edit-opt"></button>
                <BottomSheet trigger="edit-opt" >
                <div class="h-100vh">
                    <AddProductView mode="edit" :product="product" />
                </div>
            </BottomSheet>
            </div>
            <div
                v-else
                class="p-2 flex flex-col w-full h-full justify-center items-center"
            >
                <ion-spinner />
            </div>
        </ion-content>
        <ion-footer v-if="product" class="bg-base-100">
            <ion-toolbar class="">
                <div class="p-3 flex flex-col items-center gap-2">
                    <div class="flex w-full items-center justify-between">
                        <span
                            v-if="product.quantity > 0"
                            class="badge ion-bg-medium py-3"
                        >
                            {{ product.quantity }} In stock
                        </span>
                        <span v-else class="badge ion-bg-medium py-3">
                            Out of stock
                        </span>

                    </div>
                    <div class="flex w-full items-center justify-between">
                        <span v-if="!product.on_sale" class="fw-8"
                            >R{{ product.price.toFixed(2) }}</span
                        >
                        <div v-else class="flex items-center gap-5">
                            <span class="fw-8 linethrough"
                                >R{{ product.price.toFixed(2) }}</span
                            >
                            <span class="fw-8" style="transform: scale(1.2)"
                                >R{{
                                    product.sale_price
                                        ? product.sale_price.toFixed(2)
                                        : 0.0
                                }}</span>
                        </div>

                        <tu-button
                            :disabled="product.quantity < 1"
                            :ionic="false"
                            :on-click="addRemoveCart"
                            :class="`rounded-full btn-sm h-30px flex items-center justify-center ${
                                inCart(product) ? 'btn-error' : 'btn-primary'
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
import { onMounted, ref, watch } from "vue";
import {
    IonPage,
    IonContent,
    IonFooter,
    IonToolbar,
    IonToast,
    useIonRouter,
    IonSpinner,
    IonText,
} from "@ionic/vue";
import { useRouter, useRoute } from "vue-router";
import { apiAxios, apiURL } from "@/utils/constants";
import $ from "jquery";
const route = useRoute();

const { id } = route.params;
import Appbar from "@/components/Appbar.vue";
import Refresher from "@/components/Refresher.vue";
import ProductCard from "@/components/ProductCard.vue";
import TuButton from "@/components/TuButton.vue";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { useFormStore } from "@/stores/form";
import AddProductView from "@/components/AddProductView.vue";
import BottomSheet from "@/components/BottomSheet.vue";

const userStore = useUserStore();
const { cart, user } = storeToRefs(userStore);

const formStore = useFormStore();

const related = ref<any[]>();
const product = ref<{ [key: string]: any }>();
const form = ref<{ [key: string]: any }>({ rating: 2 });
const menu = ref<any>();
const toastOpen = ref(false);
const selectedImg = ref(0);
const ionRouter = useIonRouter();

const isAdmin = () => user.value?.permissions > 0;

function inCart(p: any) {
    return !cart.value?.products
        ? false
        : cart.value?.products?.find((it: any) => it.product._id == p._id);
}

const addRemoveCart = async (e: any) => {
    try {
        const act = inCart(product.value) ? "remove" : "add";
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
    try {
        product.value = undefined;
        const res = await apiAxios.get(`/products?pid=${id}`);
        if (res.data.data) {
            product.value = res.data.data[0];
        }
    } catch (e) {
        console.log(e);
    }
}

const init = async () => {
    await getProduct();
    await getRelated();
};
onMounted(() => {
    init();
});

watch(product, val=>{
}, {deep: true})
</script>
<style lang="scss"></style>
