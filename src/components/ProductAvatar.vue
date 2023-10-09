<template>
    <router-link v-if="item"
        :to="`/product/${item.pid}`"
        class="flex flex-col items-center flex-shrink-0 w-90px bg- relative overflow-hidden ion-activatable"
    >
        <ion-ripple-effect />
        <div class="flex flex-col w-full items-center overflow-hidden">
            <div class="avatar">
                <div
                    style="display: flex !important"
                    class="w-80px rounded-full bg-base-100 flex items-center justify-center"
                >
                    <img
                        v-if="item.images?.length"
                        alt=""
                        :src="item.images[0].url"
                    />

                    <span v-else>
                        <i class="fi fi-rr-image-slash"></i>
                    </span>
                </div>
            </div>

            <div v-if="sale">
                <h5 class="mt-2 text-black fs-12 fw-6 linethrough">
                    R{{ item.price.toFixed(2) }}
                </h5>
                <h5 class="text-black fs-12 fw-6" style="transform: scale(1.2)">
                    R{{ item.sale_price.toFixed(2) }}
                </h5>
            </div>
            <h5 v-else class="mt-2 text-black fs-12 fw-6">
                R{{ item.price.toFixed(2) }}
            </h5>
            <div class="overflow-hidden w-full">
                <h4
                    class="fs-14 fw-5 overflow-hidden text-center"
                    style="white-space: nowrap; text-overflow: ellipsis"
                >
                    {{ item.name }}
                </h4>
            </div>
        </div>
    </router-link>
    <div v-else
        class="flex flex-col items-center flex-shrink-0 w-90px bg- relative overflow-hidden ion-activatable"
    >
        <ion-ripple-effect />
        <div class="flex flex-col w-full items-center overflow-hidden">
            <div class="avatar">
                <div
                    style="display: flex !important"
                    class="w-80px rounded-full bg-base-100 flex items-center justify-center"
                >
                <ion-skeleton-text animated class="h-full w-full rounded-full"/>
                </div>
            </div>

            <ion-skeleton-text animated class="rounded-md h-13px w-70p my-1"/>
            <div class="overflow-hidden w-full">
                <ion-skeleton-text animated class="rounded-md h-13px"/>
            </div>
        </div>
    </div>
</template>
<script setup lang="ts">
import { IonRippleEffect, IonSkeletonText } from "@ionic/vue";
import { Obj } from "@/utils/classes";

defineProps<{
    item?: Obj;
    sale?: boolean;
    skeleton?: boolean
}>();
</script>
