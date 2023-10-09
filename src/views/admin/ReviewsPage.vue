<template>
    <ion-page>
        <Appbar title="Reviews" :show-cart="false" >
            <DropdownBtn v-if="reviews"
                :items="[
                    reviews && !selectedItems.length
                        ? { label: 'Select all', cmd: ()=> selectedItems = reviews! }
                        : null,
                    selectedItems.length
                        ? {
                              label: 'Deselect all',
                              cmd: () => (selectedItems = []),
                          }
                        : null,

                    selectedItems.length
                        ? {
                              label: 'Delete selected',
                              cmd: ()=> delReviews(selectedItems),
                          }
                        : null,
                ]"
            />
        </Appbar>
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
                                    disabled
                                    id="/shop-filter-sheet-trigger"
                                >
                                    <i
                                        class="fi fi-br-settings-sliders fs-18 text-gray-500"
                                    ></i>
                                </button>
                            </div>
                        </div>
                        <ion-list class="bg-base-100">
                             <ReviewItem v-for="rev in reviews" :rev="rev" :set-reviews="(val : Obj[])=>reviews = val"/>
                        </ion-list>
                    </div>
                    <div class="bg-base-100 h-full flex flex-center" v-else>
                        <h3 class="text-center fs-20 fw-5">
                            No product reviews yet
                        </h3>
                    </div>
                </div>
                <div class="bg-base-100 flex-auto flex flex-center" v-else>
                    <ion-spinner color="medium" class="w-55px h-55px" />
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
    
    IonList,
    IonBadge,
    IonInput,
    IonPopover,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { onMounted, ref } from "vue";
import { Obj } from "@/utils/classes";
import { errorHandler, hideLoader, hidePopover, showAlert, showLoading } from "@/utils/funcs";
import { apiAxios, reviewStatuses } from "@/utils/constants";
import Refresher from "@/components/Refresher.vue";
import ReviewItem from "./ReviewItem.vue";
import { useAppStore } from "@/stores/app";
import { storeToRefs } from "pinia";
import DropdownBtn from "@/components/DropdownBtn.vue";
const appStore = useAppStore();
const { selectedItems } = storeToRefs(appStore);

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

async function delReviews(revs: Obj[]) {
    const ids = revs.map(it=> it._id)
    selectedItems.value = []
    showAlert({
        title: "Delete review",
        message: "Are you sure you want to delete the selected reviews?",
        buttons: [
            {
                text: "Cancel",
                role: "cancel",
            },
            {
                text: "Yes",
                handler: async () => {
                    try {
                        
                        showLoading({ msg: "Deleting reviews..." });
                        const res = await apiAxios.post(
                            "/products/review?act=del",
                            { ids}
                        );
                            reviews.value = res.data.reviews;
                        hideLoader();
                    } catch (e) {
                        errorHandler(e, "Failed to delete reviews");
                        hideLoader();
                    }
                },
            },
        ],
    });
}

onMounted(() => {
    getReviews();
});
</script>
