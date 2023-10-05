<template>
    <ion-page>
        <Appbar title="Reviews" :show-cart="false" />
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="getReviews" />
            <div class="flex flex-col h-full">
                <div class="flex-auto relative" v-if="reviews">
                    <div v-if="reviews.length">
                        <div id="search-bar" class="my-1 bg-base-100 p-2">
                            <div
                                class="bg-base-200 rounded-md flex items-center px-4 h-45px gap-2"
                            >
                                <span class="mt-1"
                                    ><i
                                        class="fi fi-br-search fs-18 text-gray-500"
                                    ></i
                                ></span>

                                <ion-input
                                    color="clear"
                                    placeholder="Search"
                                    class=""
                                    router-link="/search"
                                ></ion-input>
                                <button
                                    class="mt-2"
                                    id="/shop-filter-sheet-trigger"
                                >
                                    <i
                                        class="fi fi-br-settings-sliders fs-18 text-gray-500"
                                    ></i>
                                </button>
                            </div>
                        </div>
                        <ion-list class="bg-base-100">
                            <ion-item
                                :router-link="`/products/reviews/${rev._id}`"
                                color="clear"
                                v-for="rev in reviews"
                            >
                                <ion-thumbnail
                                    class="h-45px shadow-lg card rounded-lg"
                                    slot="start"
                                >
                                    <ion-img
                                        v-if="rev.product.images?.length"
                                        class="rounded-lg"
                                        :src="rev.product.images[0].url"
                                    ></ion-img>
                                    <span v-else>
                                        <i
                                            class="fi fi-rr-image-slash text-gray-600"
                                        ></i>
                                    </span>
                                </ion-thumbnail>
                                <ion-label>
                                    <h3 class="fw-5 fs-16">{{ rev.title }}</h3>
                                    <ion-note>
                                        <span class="fw-6">{{ rev.name }}</span>
                                        &middot;
                                        {{
                                            new Date(
                                                rev.last_modified
                                            ).toLocaleDateString()
                                        }}
                                    </ion-note>
                                    <br />
                                    <ion-badge
                                        mode="ios"
                                        color="medium"
                                        class="py-1"
                                    >
                                        {{ reviewStatuses[rev.status] }}
                                    </ion-badge>
                                </ion-label>
                                <icon-btn
                                    
                                    @click="(e: Event)=>{e.preventDefault(); $('#btn-item-menu').trigger('click')}"
                                    class="w-30px"
                                    slot="end"
                                >
                                    <span
                                        ><i
                                            class="fi fi-br-menu-dots-vertical fs-20 text-gray-600"
                                        ></i
                                    ></span>
                                    <button id="btn-item-menu" class="hidden"></button>
                                </icon-btn>
                                <ion-popover
                                    trigger="btn-item-menu"
                                    trigger-action="click"
                                >
                                    <ion-content class="ion-padding"
                                        >Hello World!</ion-content
                                    >
                                </ion-popover>
                            </ion-item>
                        </ion-list>
                    </div>
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
    IonList,
    IonBadge,
    IonInput,
    IonPopover,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { onMounted, ref } from "vue";
import { Obj } from "@/utils/classes";
import { errorHandler } from "@/utils/funcs";
import { apiAxios, reviewStatuses } from "@/utils/constants";
import Refresher from "@/components/Refresher.vue";
import $ from 'jquery'
const reviews = ref<Obj[] | null>();

const getReviews = async () => {
    reviews.value = null;
    try {
        const res = await apiAxios.get("/products/reviews");
        reviews.value = res.data.reviews;
    } catch (e) {
        errorHandler(e, "Failed to fetch reviews", true);
        reviews.value = [];
    }
};

onMounted(() => {
    getReviews();
});
</script>
