<template>
    <ion-page>
       <appbar :show-back="false"/>
        <ion-content :fullscreen="true">
            <ion-refresher slot="fixed" @ion-refresh="onRefresh">
                <ion-refresher-content />
            </ion-refresher>
            <div class="m-3 flex flex-col">
                <IonText>The best coffee in town!</IonText>
                <IonText class="text-xl my-2 font-pacifico fs-30 fw-8"
                    >Grab yours now!</IonText
                >
                <ion-searchbar class="rounded"></ion-searchbar>
                <div class="my-2">
                    <!-- Top selling section -->
                    <ion-text class="fs-18">Top selling</ion-text>
                    <div class="mt-2 flex overflow-scroll">
                        <InkWell
                            v-if="topSelling"
                            @click="() => router.push(`/product/${e.pid}`)"
                            v-for="(e, i) in topSelling"
                            class="flex flex-col items-center flex-shrink-0"
                        >
                            <div class="flex flex-col items-center">
                                <div class="avatar">
                                    <div style="display: flex !important;"
                                    class="w-80px rounded-full bg-base-300 flex items-center justify-center"
                                >
                                    <img
                                        v-if="e.images?.length"
                                        alt=""
                                        :src="e.images[0].url"
                                    />

                                    <span v-else>
                                        <i class="fi fi-rr-image-slash"></i>
                                    </span>
                                    </div>
                                </div>
                                <h5 class="mt-2 text-black fs-12 fw-6">
                                    R{{ e.price.toFixed(2) }}
                                </h5>
                                <h4 class="fs-14 fw-5">{{ e.name }}</h4>
                            </div>
                        </InkWell>
                    </div>
                </div>
                <div class="my-2">
                    <!-- Special section -->
                    <ion-text class="fs-18">Today's special</ion-text>
                    <div class="mt-2 flex gap- overflow-scroll">
                        <InkWell
                            @click="() => router.push(`/product/${e.pid}`)"
                            v-if="special"
                            v-for="(e, i) in special"
                            class="flex flex-col items-center flex-shrink-0"
                        >
                            <div class="avatar">
                                <div style="display: flex !important;"
                                    class="w-80px rounded-full bg-base-300 flex items-center justify-center"
                                >
                                    <img
                                        v-if="e.images?.length"
                                        alt=""
                                        :src="e.images[0].url"
                                    />

                                    <span v-else>
                                        <i class="fi fi-rr-image-slash"></i>
                                    </span>
                                </div>
                            </div>
                            <h5 class="mt-2 text-black fs-12 fw-6">
                                R{{ e.price.toFixed(2) }}
                            </h5>
                        </InkWell>
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
} from "@ionic/vue";
import { onMounted, ref } from "vue";
import InkWell from "@/components/InkWell.vue";
import { useRouter } from "vue-router";
import axios from "axios";
import { apiURL } from "@/utils/constants";
const special = ref<any[]>(),
    topSelling = ref<any[]>();
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
async function getTopSelling() {
    topSelling.value = undefined;
    topSelling.value = await getProducts("top-selling");
}

const init = async () => {
    await getTopSelling();
    await getSpecial();
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
