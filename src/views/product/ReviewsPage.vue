<template>
    <ion-page>
        <Appbar :title="product?.name" :show-cart="false" />

        <ion-content :fullscreen="true">
            <Refresher :on-refresh="getProduct" />
            <div class="h-full flex flex-col" v-if="product">
                <div class=" p-3 bg-base-100">
                    <ion-item color="clear">
                        <ion-thumbnail
                            class="h-45px shadow-lg card rounded-lg"
                            slot="start"
                        >
                            <ion-img
                                v-if="product.images?.length"
                                class="rounded-lg"
                                :src="product.images[0].url"
                            ></ion-img>
                            <span v-else>
                                <i
                                    class="fi fi-rr-image-slash text-gray-600"
                                ></i>
                            </span>
                        </ion-thumbnail>

                        <ion-label>
                            <h3 class="fs-18 fw-5">{{ product.name }}</h3>
                        </ion-label>
                    </ion-item>
                </div>

                <div class="flex-auto" v-if="reviews">
                    <ion-list
                        class="bg-base-10 px-2 py-1"
                        v-if="reviews.length"
                    >
                    <div class="border-1 w-full p-3 bg-base-100" v-for='rev in reviews'>
                        <star-rating read-only :star-size="16" :padding="4" :show-rating="false" :rating="rev.rating"/>
                       <div class="flex items-center justify-between">
                         <h3 class='fs-18 fw-5'>{{ rev.title }}</h3>
                         <icon-btn class="rounded-lg w-30px h-30px hidden"><i class="fi fi-br-menu-dots-vertical fs-18 fw-8"></i></icon-btn>
                       </div>
                       
                        <p class="helper-text">{{ rev.name }} - {{ new Date(rev.date_created).toLocaleDateString() }}</p>
                        <p class="mt-2">
                            {{ rev.body }}
                        </p>
                    </div>
                </ion-list>
                    <div v-else class="p-3 bg-base-100 h-full flex flex-center">
                        <h3 class="fs-20">This product has no reviews yet</h3>
                    </div>
                </div>
                <div v-else class="bg-base-100 flex-auto flex flex-center">
                    <ion-spinner class="w-55px h-55px "></ion-spinner>
                </div>
            </div>

            <ion-fab vertical="bottom" horizontal="end">
                <ion-fab-button @click="if (user?.first_name) $router.push('/products/reviews'); else $router.push('/auth/login?red=' + $route.fullPath)" color="dark">
                    <span><i class="fi fi-rr-plus"></i></span>
                </ion-fab-button>
            </ion-fab>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonFab,
    IonFabButton,
    IonContent,
    IonLabel,
    IonItem,
    IonThumbnail,
    IonImg,
    IonSpinner,
    IonList
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Obj } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import { errorHandler } from "@/utils/funcs";
import Refresher from "@/components/Refresher.vue";
import { storeToRefs } from "pinia";
import { useUserStore } from "@/stores/user";
const { user } = storeToRefs(useUserStore())
const product = ref<Obj>(),
    reviews = ref<Obj[] | null>();

const { id } = useRoute().params;
async function getProduct() {
    try {
        product.value = undefined;
        const res = await apiAxios.get(`/products?pid=${id}`);
        if (res.data.data) {
            product.value = res.data.data[0];
            getReviews(res.data.data[0]._id);
        }
    } catch (e) {
        console.log(e);
        errorHandler(e, "Failed to fetch product");
    }
}
async function getReviews(pid: string) {
    reviews.value = null;
    try {
        const res = await apiAxios.get("/products/reviews?pid=" + pid);
        reviews.value = res.data.reviews.filter((it : Obj)=> it.status == 1);
    } catch (e) {
        console.log(e);
        reviews.value = [];
        errorHandler(e, "Failed to fetch product");
    }
}
onMounted(() => {
    getProduct();
});
</script>
