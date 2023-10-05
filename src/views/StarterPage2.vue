<template>
    <ion-page>
        <Appbar title="Reviews" :show-cart="false" />
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="getReviews" />
            <div class="flex flex-col h-full">
                <div class="flex-auto relative" v-if="reviews">
                    <div v-if="reviews.length"></div>
                    <div class="bg-base-100 h-full flex flex-center" v-else>
                        <h3 class="text-center fs-20 fw-5">
                            No product reviews yet
                        </h3>
                    </div>
                </div>
                <div class="bg-base-100 flex-auto flex flex-center" v-else>
                    <ion-spinner class="w-55px h-55px" />
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonSpinner,
    IonItem,
    IonThumbnail,
    IonImg,
    IonLabel,
    IonNote,
    IonBadge,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { onMounted, ref } from "vue";
import { Obj } from "@/utils/classes";
import { errorHandler } from "@/utils/funcs";
import { apiAxios } from "@/utils/constants";
import Refresher from "@/components/Refresher.vue";

const reviews = ref<Obj[] | null>([]);

const getReviews = async () => {
    reviews.value = null;
    try {
        const res = await apiAxios.get("/products/reviews");
        console.log(res);
    } catch (e) {
        errorHandler(e, "Failed to fetch reviews", true);
        reviews.value = [];
    }
};

onMounted(() => {
    //getReviews()
});
</script>
