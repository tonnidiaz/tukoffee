<template>
    <div
        class="p-2 border-1 shadow-sm bg-base-100 ion-activatable relative product-card"
        @click="()=> router.push(`/product/${product.pid}`)"
    >
        <ion-ripple-effect />
        <div
            class="flex flex-wrap items-center justify-center gap-2"
        >
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
                <div v-else class="w-full shadow-2 rounded-lg h-70px flex items-center justify-center ">

                <div><i class="fi fi-rr-image-slash fs-25"></i></div>
                </div>
                <!-- <ion-text
                    class="text-lg fw-5 text-black-2 mt-2"
                   
                    >{{ product.name }}</ion-text
                > -->
                <h3 class="mt-3 fw-6"  style="white-space: nowrap; text-overflow: ellipsis">{{product.name}}</h3>
            </div>
            <div class="flex items-center justify-between w-full">
                
              <div class="badge badge-primary">{{ inStock(product) ? 'In stock' : 'Out of stock' }}</div>
                <span class="flex items-center jent-center">
                    <span>
                        <i class="fi fi-ss-star text-amber fs-18"></i>
                    </span>

                    <span class="fs-14 fw-6 text-gray-700">{{ product.rating ?? 0 }}</span>
                </span>
            </div>
            <div class="flex items-center justify-between w-full">
                <span class="text-md fw-6 text-gray-700"
                    >R{{ product.price.toFixed(2) }}</span
                >
                <span class="bg-primar p-1 rounded-full w-30px h-30px flex items-center justify-center"><i class="fi fi-rr-shopping-cart fs-18"></i></span>
            </div>
        </div>
    </div>
</template>
<script setup lang="ts">
import { IonRippleEffect } from "@ionic/vue";
import { useRouter } from "vue-router";

const router = useRouter()
function inStock(p: any) {
    return p.quantity > 0;
}
defineProps({
    product: {
        type: Object,
        required: true,
    },
});
</script>
<style lang="scss">
.product-card {
    img {
        object-fit: contain;
    }
}
</style>
