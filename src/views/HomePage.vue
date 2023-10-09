<template>
    <ion-page>
        <appbar :show-back="false" />
        <ion-content :fullscreen="true">
            <ion-refresher slot="fixed" @ion-refresh="onRefresh">
                <ion-refresher-content />
            </ion-refresher>
            <div class="m-3 flex flex-col">
                <IonText>The best coffee in town!</IonText>
                <IonText class="text-xl my-2 font-pacifico fs-30 fw-8"
                    >Grab yours now!</IonText
                >
                <ion-searchbar
                    router-link="/search"
                    class="rounded"
                ></ion-searchbar>
                <div class="my-2" v-if="(topSelling && topSelling.length) || !topSelling">
                    <!-- Top selling section -->
                    <h3 class="fs-20 fw-5 my-3">Top selling</h3>
                    <div class="mt-2 flex overflow-scroll gap-x-3">
                        <ProductAvatar
                            v-if="topSelling"
                            v-for="(e, i) in topSelling"
                            :item="e"
                        />
                        <ProductAvatar v-else v-for="i in 20" />
                    </div>
                </div>
                <div v-if="(special && special.length) || !special" class="my-2">
                    <!-- Special section -->
                        <h3 class="fs-20 fw-5 my-3">Today's special</h3>
                        <div class="mt-2 flex gap-x-3 overflow-scroll">
                            <ProductAvatar
                                v-if="special"
                                v-for="(e, i) in special"
                                :item="e"
                            />
                            <ProductAvatar v-else v-for="i in 20" />
                        </div>
                </div>
                <div class="my-2" v-if="(sale && sale.length) || !sale">
                    <!-- Special section -->
                    <h3 class="fs-20 fw-5 my-3">On sale</h3>
                    <div class="mt-2 flex gap-x-3 overflow-scroll">
                        <ProductAvatar
                            v-if="sale"
                            v-for="(e, i) in sale"
                            :item="e"
                            sale
                        />
                        <ProductAvatar v-else v-for="i in 20" />
                    </div>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>

<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonSearchbar,
    IonText,
    IonRefresher,
    IonRefresherContent,
    IonRippleEffect,
} from "@ionic/vue";
import { onMounted, ref } from "vue";
import InkWell from "@/components/InkWell.vue";
import { useRouter } from "vue-router";
import axios from "axios";
import { apiURL } from "@/utils/constants";
import ProductAvatar from "@/components/ProductAvatar.vue";
import { sleep } from "@/utils/funcs";
const special = ref<any[]>(),
    topSelling = ref<any[]>(),
    sale = ref<any[]>();
const router = useRouter();

const getProducts = async (q: string) => {
    try {
        const res = await axios.get(`${apiURL}/products?q=${q}`);
        return res.data.data;
    } catch (error) {
        console.log(error);
        return [];
    }
};

async function getSpecial() {
    special.value = undefined;
    special.value = await getProducts("special");
}
async function getSale() {
    sale.value = undefined;
    sale.value = await getProducts("sale");
}
async function getTopSelling() {
    topSelling.value = undefined;
    topSelling.value = await getProducts("top-selling");
}

const init = async () => {
    await getTopSelling();
    await getSpecial();
    await getSale();
};
const onRefresh = async (e: any) => {
    await init();
    e.target.complete();
};

onMounted(() => {
    init();
});
</script>

<style scoped>
.ripple-parent {
    position: relative;
    overflow: hidden;

    border: 1px solid #ddd;
}
.rectangle {
    width: 300px;
    height: 150px;
}

img {
    object-fit: contain;
}
</style>
