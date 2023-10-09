<template>
    <div
        class="cursor-pointer border-1 shadow-sm bg-base-100 ion-activatable relative p-0 product-card"
        @click="(e: Event)=>{ if (!e.defaultPrevented) $router.push(`/product/${product.pid}`)}"
    >
        <div>
            <div class="py-2 flex flex-wrap items-center justify-center">
                <div
                    class="flex items-center justify-center flex-col overflow-hidden w-full relative"
                    style="white-space: nowrap; text-overflow: ellipsis"
                >
                <tu-button
                        :on-click="addRemoveCart"
                        :ionic="false"
                        v-if="product.quantity > 0"
                        :class="`btn-sm btn-circle h-45px w-45px absolute right-0 top-0 flex items-center justify-center shadow-md ${inCart(product) ? 'bg-primary' : 'btn-danger'}`"
                        ><i v-if="!inCart(product)" class="fi fi-rr-shopping-cart-add fs-23"></i>
                    <i v-else class="fi fi-rr-cart-minus fs-23 text-"></i></tu-button
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
                        class="mt-2 px-1 fw-6 font-body overflow-hidden w-full text-center"
                        style="white-space: nowrap; text-overflow: ellipsis"
                    >
                        {{ product.name }}
                    </h3>
                </div>
                <div class="flex items-center justify-between w-full px-2">
                    <ion-badge mode="ios" :color="inStock(product) ? 'primary' : 'medium'" class="fs-10 fw-6">
                        {{ inStock(product) ? "In stock" : "Out of stock" }}
                    </ion-badge>
                    <span class="flex items-center jent-center">
                        <span>
                            <i class="fi fi-ss-star text-amber fs-18"></i>
                        </span>

                        <span class="fs-14 fw-6 text-gray-700">{{
                            product.rating ?? 0
                        }}</span>
                    </span>
                </div>
                <div class="flex flex-center w-full px-2 mt-1">
                  
                    <span v-if="!product.on_sale" class="text-md fw-6 fs-14 text-gray-700"
                            >R{{ product.price.toFixed(2) }}</span
                        >
                        <div v-else class="flex items-center gap-4">
                             <span class="text-md fw-5 fs-14 text-gray-700 linethrough"
                            >R{{ product.price}}</span
                        >
                             <span class="text-md fw-6 fs-14 text-gray-700" style="transform: scale(1.1);"
                            >R{{product.sale_price? product.sale_price.toFixed(2) :0.00}}</span
                        >
                        </div>
                    
                </div>
            </div>
        </div>
    </div>
</template>
<script setup lang="ts">
import { useUserStore } from "@/stores/user";
import { apiAxios } from "@/utils/constants";
import { storeToRefs } from "pinia";
import TuButton from "./TuButton.vue";
import { showAlert } from "@/utils/funcs";
import router from "@/router";
import { useRoute } from "vue-router";
const userStore = useUserStore();
const { cart, user } = storeToRefs(userStore);
import {IonBadge} from '@ionic/vue';
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

const route = useRoute()
const addRemoveCart = async (e: any) => {
    e.preventDefault()
    try {
        if (!user.value?._id){
            router.push(`/auth/login?red=${route.path}`)
            return 
        }
        const act = inCart(props.product) ? "remove" : "add";
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
