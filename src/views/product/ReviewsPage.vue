<template>
    <ion-page>
        <Appbar title="Product reviews" :show-cart="false" />
        
        <ion-content :fullscreen="true">
            <div class="h-full" v-if="product">
                <div class="my-1 p-3 bg-base-100">
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

                <div class="my-1 p-3 bg-base-100"></div>
            </div>

            <ion-fab vertical="bottom" horizontal="end">
                <ion-fab-button router-link="/products/reviews" color="dark">
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
   
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Obj } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { onMounted, ref } from "vue";
import { useRoute } from "vue-router";

const product = ref<Obj>();

const { id } = useRoute().params;
async function getProduct() {
    try {
        product.value = undefined;
        const res = await apiAxios.get(`/products?pid=${id}`);
        if (res.data.data) {
            product.value = res.data.data[0];
        }
    } catch (e) {
        console.log(e);
    }
}
onMounted(() => {
    getProduct();
});
</script>
