<template>
    <div
        class="p-2 border-1 surface-border surface-card border-round ion-activatable relative product-card"
        @click="()=> router.push(`/product/${product.pid}`)"
    >
        <ion-ripple-effect />
        <div
            class="flex flex-wrap align-items-center justify-content-center gap-2"
        >
            <div
                class="flex align-items-center justify-content-center flex-column overflow-hidden w-full"
                style="white-space: nowrap; text-overflow: ellipsis"
            >
                <img
                    v-if="product.images.length"
                    class="w-full shadow-2 border-round h-70px"
                    :src="product.images[0].url"
                    alt="Gold Phone Case"
                />
                <div v-else class="w-full shadow-2 border-round h-70px flex align-items-center justify-content-center ">

                <div><i class="fi fi-rr-image-slash fs-25"></i></div>
                </div>
                <!-- <ion-text
                    class="text-lg fw-5 text-black-2 mt-2"
                   
                    >{{ product.name }}</ion-text
                > -->
                <h5 class="mt-3"  style="white-space: nowrap; text-overflow: ellipsis">{{product.name}}</h5>
            </div>
            <div class="flex align-items-center justify-content-between w-full">
                
                <Tag
                    :value="inStock(product) ? 'In stock' : 'Out of stock'"
                    severity="primary"
                    
                />
                <span class="flex align-items-center justify-content-center">
                    <span>
                        <i class="fi fi-ss-star text-amber fs-18"></i>
                    </span>

                    <span class="fs-14 fw-8">{{ product.rating ?? 0 }}</span>
                </span>
            </div>
            <div class="flex align-items-center justify-content-between w-full">
                <span class="text-md fw-6 text-gray-700"
                    >R{{ product.price.toFixed(2) }}</span
                >
                <Button
                    icon="fi fi-rr-shopping-cart"
                    rounded
                    class="w-34px h-34px"
                />
            </div>
        </div>
    </div>
</template>
<script setup lang="ts">
import Tag from "primevue/tag";
import Button from "primevue/button";
import { IonRippleEffect, IonText } from "@ionic/vue";
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
