<template>
     <refresher :on-refresh="getReviews"/>
    <div v-if="reviews" class="h-full">
        <ion-list class="bg-base-100 p-3 my-1" v-if="reviews.length">
            <ion-item
                :router-link="`/products/reviews/${review._id}`"
                v-for="review in reviews"
                color="clear"
            >
                <ion-thumbnail
                    class="h-45px shadow-lg card rounded-lg"
                    slot="start"
                >
                    <ion-img
                        v-if="review.product.images?.length"
                        class="rounded-lg"
                        :src="review.product.images[0].url"
                    ></ion-img>
                    <span v-else>
                        <i class="fi fi-rr-image-slash text-gray-600"></i>
                    </span>
                </ion-thumbnail>

                <ion-label>
                    <h3 class="fs-18 fw-5">{{ review.product.name }}</h3>
                    <div class="flex items-center gap-3">
                        <star-rating
                            :show-rating="false"
                            :star-size="15"
                            :padding="6"
                            :rating="review.rating"
                            :increment="0.5"
                        ></star-rating>
                        <ion-badge mode="ios" color="medium" class="py-1">{{
                            reviewStatuses[review.status]
                        }}</ion-badge>
                    </div>
                </ion-label>
            </ion-item>
        </ion-list>
        <div v-else class="p-3 h-full flex flex-center bg-base-100">
            <h3 class="fs-20 fw-5 text-center">
                You have not written any product reviews yet
            </h3>
        </div>
    </div>
    <div v-else class="p-3 h-full flex flex-center">
        <ion-spinner class="h-50px w-50px" />
    </div>
</template>
<script setup lang="ts">
import {
  
    IonLabel,
    IonItem,
    IonList,
    IonSpinner,
    IonThumbnail,
    IonImg,
    IonBadge,
} from "@ionic/vue";
import { Obj } from "@/utils/classes";
import { apiAxios, reviewStatuses } from "@/utils/constants";
import { onMounted, ref } from "vue";
import { errorHandler } from "@/utils/funcs";
import Refresher from "@/components/Refresher.vue";

const reviews = ref<Obj[] | null>([]);

async function getReviews() {
    try {
        reviews.value = null;
        const res = await apiAxios.get("/products/reviews");
        reviews.value = res.data.reviews;
    } catch (e) {
        console.log(e);
        errorHandler(e, "Failed to fetch reviews");
        reviews.value = [];
    }
}
onMounted(() => {
    getReviews();
});
</script>
