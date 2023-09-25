<template>
    <ion-item color="clear" :router-link="`/product/${item.product.pid}`">
        <ion-thumbnail class="h-45px shadow-lg card rounded-lg" slot="start">
            <ion-img
                v-if="item.product.images?.length"
                class="rounded-lg"
                :src="item.product.images[0].url"
            ></ion-img>
            <span v-else>
                <i class="fi fi-rr-image-slash text-gray-600"></i>
            </span>
        </ion-thumbnail>
        <ion-label>
            <h3>{{ item.product.name }}</h3>
            <ion-note>R{{ item.product.price.toFixed(2) }}</ion-note>
        </ion-label>
        <div class="flex flex-col" slot="end">
            <span class="relative" @click="console.log('Edit')">
                <i class="fi fi-br-pencil fs-13 text-gray-600"></i
            ></span>
            <span class="relative" @click="console.log('Remove')">
                <i class="fi fi-br-cross fs-12 text-gray-600"></i
            ></span>
        </div>
    </ion-item>
</template>
<script setup lang="ts">
import {
    IonNote,
    IonItem,
    IonImg,
    IonLabel,
    IonThumbnail,
} from "@ionic/vue";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
const userStore = useUserStore();
const { cart } = storeToRefs(userStore);

const props = defineProps({
    item: {
        type: Object,
        required: true,
    },
});


</script>
