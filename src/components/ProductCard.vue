<template>
    <a
        lines="none"
        class="cursor-pointer border-1 shadow-sm bg-base-100 ion-activatable relative p-0 product-card"
        :href="`/product/${product.pid}`"
    >
        <div>
            <div class="py-2 flex flex-wrap items-center justify-center">
                <div
                    class="flex items-center justify-center flex-col overflow-hidden w-full"
                    style="white-space: nowrap; text-overflow: ellipsis"
                >
                    <img
                        v-if="product.images.length"
                        class="w-full shadow-2 rounded-lg h-70px"
                        :src="product.images[0].url"
                        alt="Gold Phone Case"
                    />
                    <div
                        v-else
                        class="w-full shadow-2 rounded-lg h-70px flex items-center justify-center"
                    >
                        <div><i class="fi fi-rr-image-slash fs-25"></i></div>
                    </div>
          
                    <h3
                        class="mt-2 fw-6 font-body"
                        style="white-space: nowrap; text-overflow: ellipsis"
                    >
                        {{ product.name }}
                    </h3>
                </div>
                <div class="flex items-center justify-between w-full px-2">
                    <div class="badge badge-primary fs-10 fw-6">
                        {{ inStock(product) ? "In stock" : "Out of stock" }}
                    </div>
                    <span class="flex items-center jent-center">
                        <span>
                            <i class="fi fi-ss-star text-amber fs-18"></i>
                        </span>

                        <span class="fs-14 fw-6 text-gray-700">{{
                            product.rating ?? 0
                        }}</span>
                    </span>
                </div>
                <div class="flex items-center justify-between w-full px-2">
                    <span class="text-md fw-6 fs-14 text-gray-700"
                        >R{{ product.price }}</span
                    >

                    <tu-button
                        :on-click="addRemoveCart"
                        :class="`rounded-full btn-sm h-30px flex items-center justify-center ${inCart(product) ? 'btn-danger' : 'btn-danger'}`"
                        ><i v-if="!inCart(product)" class="fi fi-rr-shopping-cart-add fs-18"></i>
                    <i v-else class="fi fi-rr-cart-minus fs-18 text-"></i></tu-button
                    >
                </div>
            </div>
        </div>
    </a>
</template>
<script setup lang="ts">
import { useUserStore } from "@/stores/user";
import { apiAxios } from "@/utils/constants";
import { IonRippleEffect, IonButton, IonItem } from "@ionic/vue";
import { storeToRefs } from "pinia";
import { useRouter } from "vue-router";
import TuButton from "./TuButton.vue";
import { sleep } from "@/utils/funcs";
import { add } from "ionicons/icons";
const userStore = useUserStore();
const { cart } = storeToRefs(userStore);
const router = useRouter();

function inCart(p: any) {
    return cart.value?.products?.find((it: any) => it.product._id == p._id);
}
function inStock(p: any) {
    return p.quantity > 0;
}
const props = defineProps({
    product: {
        type: Object,
        required: true,
    },
});

const addRemoveCart = async (e: any) => {
    try {
        const act = inCart(props.product) ? "remove" : "add";
        console.log(act);
        const fd = new FormData();
        fd.append("product", props.product._id);
        const res = await apiAxios.post(`/user/cart?action=${act}`, fd);
        userStore.setCart(res.data.cart);
    } catch (error) {
        console.log(error);
    }

};
</script>
<style lang="scss">
.product-card {
    img {
        object-fit: contain;
    }
}
</style>
