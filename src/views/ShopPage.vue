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
                                ></ion-input>
                                <button
                                    class="mt-2"
                                    id="/shop-filter-sheet-trigger"
                                >
                                    <i
                                        class="fi fi-rr-settings-sliders fs-18 text-gray-700"
                                    ></i>
                                </button>
                            </div>
                        </div>

                        <BottomSheet
                            trigger="/shop-filter-sheet-trigger"
                            id="filter-sheet"
                        >
                            <div
                                class="p-3 bg-base-100 flex flex-col justify-center"
                            >
                                <div
                                    class="flex w-full justify-between my-3 items-center"
                                >
                                    <h3 class="">FILTER</h3>
                                    <button
                                        @click="() => toggleOrder()"
                                        class="btn btn-sm btn-ghost p- rounded-full"
                                    >
                                        <i
                                            v-if="
                                                sortOrder == SortOrder.ascending
                                            "
                                            class="fi fi-rr-sort-amount-down-alt fs-20 text-gray-600"
                                        ></i>
                                        <i
                                            v-else
                                            class="fi fi-rr-sort-amount-up-alt fs-20 text-gray-600"
                                        ></i>
                                    </button>
                                </div>

                                <ion-item lines="none">
                                    <ion-select
                                        interface="popover"
                                        @ion-change="
                                            setSortBy($event.target.value)
                                        "
                                        :value="sortBy"
                                        mode="md"
                                        label="Sort by"
                                        label-placement="floating"
                                    >
                                        <ion-select-option :value="SortBy.price"
                                            >Price</ion-select-option
                                        >
                                        <ion-select-option
                                            :value="SortBy.created"
                                            >Date added</ion-select-option
                                        >
                                        <ion-select-option
                                            :value="SortBy.modified"
                                            >Last modified</ion-select-option
                                        >
                                    </ion-select>
                                </ion-item>
                                <ion-item class="my-1" lines="none">
                                    <ion-select
                                        interface="popover"
                                        @ion-change="
                                            setStatus($event.target.value)
                                        "
                                        :value="status"
                                        mode="md"
                                        label="Status"
                                        label-placement="floating"
                                    >
                                        <ion-select-option :value="Status.all"
                                            >All</ion-select-option>
                                        <ion-select-option :value="Status.topSelling"
                                            >Top selling</ion-select-option>
                                        <ion-select-option :value="Status.onSale"
                                            >Today's special</ion-select-option>
                                        <ion-select-option :value="Status.onSale"
                                            >On sale</ion-select-option>
                                        <ion-select-option :value="Status.in"
                                            >In stock</ion-select-option
                                        >
                                        <ion-select-option :value="Status.out"
                                            >Out of stock</ion-select-option
                                        >
                                    </ion-select>
                                </ion-item>
                            </div>
                        </BottomSheet>
                    </div>
                </div>
                <div
                    style="flex: auto"
                    class="w-full flex items-center justify-center"
                    v-if="!sortedProducts"
                >
                    <ion-spinner class="w-75px h75px"></ion-spinner>
                </div>
                <div
                    v-else-if="sortedProducts.length"
                    class="my-0 grid justify-center gap-1 grid-cols-2"
                >
                    <ProductCard
                        v-for="(e, i) in sortedProducts"
                        :product="e"
                    />
                </div>
                <div
                    style="flex: auto"
                    class="w-full flex items-center justify-center"
                    v-else
                >
                    <h3 class="fs-20">Nothing to show</h3>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonInput,
    IonItem,
    IonSelect,
    IonSelectOption,
    IonSpinner
} from "@ionic/vue";
import { ref, onMounted } from "vue";
import Appbar from "@/components/Appbar.vue";
import ProductCard from "@/components/ProductCard.vue";
import { apiAxios } from "@/utils/constants";
import Refresher from "@/components/Refresher.vue";
import { sleep } from "@/utils/funcs";
import { Obj, SortOrder } from "@/utils/classes";
import { useShopStore, SortBy, Status } from "@/stores/shop";
import { storeToRefs } from "pinia";
import BottomSheet from "@/components/BottomSheet.vue";

const shopStore = useShopStore();
const {
    sortBy,
    sortOrder,
    sortedItems: sortedProducts,
    items: products,
    status,
} = storeToRefs(shopStore);
const { setItems, setSortBy, toggleOrder, setSortedItems, setStatus } =
    shopStore;

async function getProducts() {
    try {
        setItems(null);
        setStatus(Status.all)
        const res = await apiAxios.get("/products");
        setItems(res.data.data);
    } catch (error) {
        console.log(error);
        setItems([]);
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
