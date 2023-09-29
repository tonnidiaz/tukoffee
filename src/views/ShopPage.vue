<template>
    <ion-page>
        <Appbar title="Shop" />
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init" />
            <div class="h-full w-full flex flex-col px-3">
                <div class="flex justify-center w-ful">
                    <div class="flex justify-center w-full flex-col">
                        <div id="search-bar" class="my-1 bg-base-100 p-3">
                            <div
                                class="bg-base-200 rounded-md flex items-center px-4 h-45px gap-2"
                            >
                                <span class="mt-1"
                                    ><i
                                        class="fi fi-rr-search fs-18 text-gray-700"
                                    ></i
                                ></span>

                                <ion-input
                                    color="clear"
                                    placeholder="Search"
                                    class="tu bg-primar"
                                    router-link="/search"
                                    @ion-focus="console.log('object');"
                                ></ion-input>
                                <button
                                    class="mt-2"
                                    id="filter-sheet-trigger"
                                    @click="console.log('click')"
                                >
                                    <i
                                        class="fi fi-rr-settings-sliders fs-18 text-gray-700"
                                    ></i>
                                </button>
                            </div>
                        </div>

                        <ion-modal
                            ref="modal"
                            trigger="open-modal"
                            :initial-breakpoint="0.25"
                            :breakpoints="[0, 0.25, 0.5, 0.75]"
                        >
                            <ion-content
                                class="ion-padding flex flex-col justify-center items-center relative"
                            >
                                <div
                                    class="w-full h-fu my-3 flex flex-col justify-start items-start"
                                >
                                    <div class="flex gap-2 w-full">
                                        <Dropdown
                                            v-model="sortBy"
                                            :options="sorts"
                                            optionLabel="name"
                                            placeholder="Sort by"
                                            class="w-full md:w-14rem"
                                        />
                                        <Dropdown
                                            v-model="sortBy"
                                            :options="sorts"
                                            optionLabel="name"
                                            placeholder="Status"
                                            class="w-full md:w-14rem"
                                        />
                                    </div>
                                </div>
                            </ion-content>
                        </ion-modal>

                        <!-- 
 -->
                    </div>
                </div>
                <div
                    v-if="products"
                    class="my-0 grid justify-center gap-1 grid-cols-2"
                >
                    <ProductCard v-for="(e, i) in products" :product="e" />
                </div>
                <div
                    style="flex: auto"
                    class="w-full flex items-center justify-center"
                    v-else
                >
                    <h3 class="fs-20">Loading...</h3>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonModal, IonContent, IonInput, IonItem } from "@ionic/vue";
import { ref, onMounted } from "vue";
import Appbar from "@/components/Appbar.vue";
import ProductCard from "@/components/ProductCard.vue";
import TuFormField from "@/components/TuFormField.vue";
import TuButton from "@/components/TuButton.vue";

import { apiAxios } from "@/utils/constants";
import Refresher from "@/components/Refresher.vue";
import { sleep } from "@/utils/funcs";

const products = ref();
const sortBy = ref();
const sorts = [
    {
        name: "Name",
        value: "name",
    },
    {
        name: "Price",
        value: "price",
    },
    {
        name: "Date new to old",
        value: "date1",
    },
    {
        name: "Date old to new",
        value: "date2",
    },
];

const handleClick = async () => {
    await sleep(2000);
    console.log("Slept");
};
async function getProducts() {
    try {
        products.value = undefined;
        const res = await apiAxios.get("/products");
        products.value = res.data.data;
    } catch (error) {
        console.log(error);
    }
}
const init = async () => {
    await getProducts();
};

onMounted(() => {
    init();
});
</script>
<style lang="scss">
.inp-suffix {
    position: relative;

    input {
        padding-right: 2rem !important;
    }
    .suffix-icon {
        position: absolute;
        top: 0;
        right: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        height: 100%;
        padding: 0.7rem;
        background-color: yellowgreen;
        pointer-events: all;
    }
}
</style>
