<template>
    <ion-page>
        <Appbar title="Product review" :show-cart="false">
            <icon-btn  v-if="review" @click="delReview(review)"
                ><i class="fi fi-br-trash fs-18"></i
            ></icon-btn>

            <icon-btn v-if="review" id="trigger-edit-sheet"
                ><i class="fi fi-br-pencil fs-18"></i
            ></icon-btn>
        </Appbar>
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="getReview" />
            <div class="h-full flex flex-col">
                <div v-if="review">
                    <div class="my-1 bg-base-100 p-3">
                        <ion-item color="clear">
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
                                    <i
                                        class="fi fi-rr-image-slash text-gray-600"
                                    ></i>
                                </span>
                            </ion-thumbnail>

                            <ion-label>
                                <h3 class="fs-18 fw-5">
                                    {{ review.product.name }}
                                </h3>
                                <div class="flex items-center gap-x-3 flex-wrap">
                                    <star-rating
                                        read-only
                                        :show-rating="false"
                                        :star-size="15"
                                        :padding="6"
                                        :rating="review.rating"
                                        :increment="0.5"
                                    ></star-rating>
                                    <ion-badge
                                        mode="ios"
                                        :color=" review.status == 0 ? 'medium' : (review.status == 1 ? 'success' : 'danger')"
                                        class="py-1"
                                        >{{
                                            reviewStatuses[review.status]
                                        }}</ion-badge
                                    >
                                </div>
                            </ion-label>
                        </ion-item>
                    </div>
                    <!-- Edit sheet -->
                    <BottomSheet trigger="trigger-edit-sheet">
                        <div class="h-99vhh">
                            <div class="bg-base-100 p-3">
                                <h3 class="fs-20">Edit review</h3>
                            </div>

                            <ReviewView :review-id="review?._id" />
                        </div>
                    </BottomSheet>
                    <div class="my-1 bg-base-100 p-3">
                        <div class="flex items-center justify-between">
                            <div>
                                <h5 class="fw-5">Date added</h5>
                                <span class="helper-text">{{
                                    new Date(
                                        review.date_created
                                    ).toLocaleDateString()
                                }}</span>
                            </div>
                            <div>
                                <h5 class="fw-5">Last modified</h5>
                                <p class="helper-text">
                                    {{
                                        new Date(
                                            review.last_modified
                                        ).toLocaleDateString()
                                    }}
                                </p>
                            </div>
                        </div>
                        </div>
                    <div class="my-1 bg-base-100 p-3">
                        
                        <h3 class="fs-18">{{ review.title }}</h3>
                        <div class="mt-2">
                            <p class="helper-text">{{ review.name }}</p>
                        </div>
                        
                        <div class="mt">
                            <p class="">{{ review.body }}</p>
                        </div>
                    </div>
                </div>

                <div
                    class="my-1 bg-base-100 p-3 flex flex-center flex-auto"
                    v-else
                >
                    <ion-spinner class="w-50px h-50px"></ion-spinner>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonItem,
    IonLabel,
    IonSpinner,
    IonBadge,
    IonThumbnail,
    IonImg,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Obj } from "@/utils/classes";
import { onMounted, ref } from "vue";
import { apiAxios, reviewStatuses } from "@/utils/constants";
import { useRoute } from "vue-router";
import { errorHandler, hideLoader, showAlert, showLoading } from "@/utils/funcs";
import Refresher from "@/components/Refresher.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import ReviewView from "@/components/ReviewView.vue";
import router from "@/router";

const review = ref<Obj | null>();

const { id } = useRoute().params;
async function getReview() {
    try {
        review.value = null;
        const res = await apiAxios.get("/products/reviews?id=" + id);
        review.value = res.data.reviews[0];
    } catch (e) {
        console.log(e);
        errorHandler(e, "Failed to fetch reviews");
    }
}

async function delReview(rev: Obj) {
    showAlert({
        title: "Delete review",
        message: "Are you sure you want to delete the review?",
        buttons: [
            {
                text: "Cancel",
                role: "cancel",
            },
            {
                text: "Yes",
                handler: async () => {
                    try {
                        showLoading({ msg: "Deleting review..." });
                        const res = await apiAxios.post(
                            "/products/review?act=del",
                            { id: rev._id }
                        );
                       
                        hideLoader();
                        router.back()
                    } catch (e) {
                        errorHandler(e, "Failed to delete review");
                        hideLoader();
                    }
                },
            },
        ],
    });
}

onMounted(() => {
    getReview();
});
</script>
