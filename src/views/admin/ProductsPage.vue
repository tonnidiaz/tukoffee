<template>
    <ion-page>
        <Appbar title="Products" :show-cart="false">
            <DropdownBtn
                :items="[
                    {
                        label: 'Select all',
                        cmd: () => {
                            console.log('selected all');
                        },
                    },
                ]"
            />
        </Appbar>

        <ion-fab vertical="bottom" horizontal="end">
            <ion-fab-button @click="router.push('/add/product')" color="dark">
                <span class="mt-1"><i class="fi fi-rr-plus"></i></span>
            </ion-fab-button>
        </ion-fab>
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="getProducts" />
            <div class="my-2 bg-base-100 p-3">
                <div
                    class="bg-base-200 rounded-md flex items-center px-4 h-45px gap-2"
                >
                    <span class="mt-1"
                        ><i class="fi fi-rr-search fs-18 text-gray-700"></i
                    ></span>

                    <ion-input
                        color="clear"
                        placeholder="Search"
                        class="tu bg-primar"
                        @ion-input="onSearchInput"
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
            <div
                v-if="!products"
                class="bg-base-100 h-full w-full flex items-center justify-center"
            >
                <ion-spinner class="w-45px h-45px" color="medium"></ion-spinner>
            </div>
            <div v-else class="bg-base-100 pb-4 my-2">
                <ProductItem
                    :reload="getProducts"
                    v-for="it in sortedProducts"
                    :item="it"
                />
            </div>
        </ion-content>
        <!-- New product sheet -->
        <BottomSheet
            @did-dismiss="newProductSheetOpen = false"
            :is-open="newProductSheetOpen"
        >
            <AddProductView />
        </BottomSheet>

        <!-- Filter sheet -->
        <BottomSheet trigger="filter-sheet-trigger" id="filter-sheet">
            <div class="p-3 bg-base-100 flex flex-col justify-center">
                <div class="flex w-full justify-between my-3 items-center">
                    <h3 class="">FILTER</h3>
                    <button @click="()=>toggleOrder()" class="btn btn-sm btn-ghost p- rounded-full">
                            <i v-if="sortOrder == SortOrder.ascending" class="fi fi-rr-sort-amount-down-alt fs-20 text-gray-600"></i>
                            <i v-else class="fi fi-rr-sort-amount-up-alt fs-20 text-gray-600"></i>
                        </button>
                </div>

                <ion-item lines="none">
                    <ion-select
                        interface="popover"
                        @ion-change="setSortBy($event.target.value)"
                        :value="sortBy"
                        mode="md"
                        label="Sort by"
                        label-placement="floating"
                    >
                        <ion-select-option :value="SortBy.name"
                            >Name</ion-select-option
                        >
                        <ion-select-option :value="SortBy.created"
                            >Date created</ion-select-option
                        >
                        <ion-select-option :value="SortBy.modified"
                            >Last modified</ion-select-option
                        >
                    </ion-select>
                </ion-item>
                <ion-item class="my-1" lines="none">
                    <ion-select
                        interface="popover"
                        @ion-change="setStatus($event.target.value)"
                        :value="status"
                        mode="md"
                        label="Status"
                        label-placement="floating"
                    >
                        <ion-select-option :value="Status.all"
                            >All</ion-select-option
                        >
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
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonIcon,
    IonToolbar,
    IonItem,
    IonContent,
    IonSelect,
    IonFab,
    IonFabButton,
    IonSpinner,
    IonInput,
    IonText,
    IonSelectOption,
    IonInfiniteScroll,
} from "@ionic/vue";

import Appbar from "@/components/Appbar.vue";
import ProductItem from "@/components/ProductItem.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import Refresher from "@/components/Refresher.vue";

import { useDashStore } from "@/stores/dash";
import AddProductView from "@/components/AddProductView.vue";
import { onMounted, ref, watch } from "vue";
import { Obj, SortOrder } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { useRouter } from "vue-router";
import { ellipsisVertical } from "ionicons/icons";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { useProductsStore, Status, SortBy } from "@/stores/products";
import { storeToRefs } from "pinia";

const productsStore = useProductsStore()
const { sortBy, sortOrder, sortedItems: sortedProducts, items: products, status} = storeToRefs(productsStore)
const { setItems, setSortBy, toggleOrder, setSortedItems, setStatus} = productsStore
const newProductSheetOpen = ref(false);

const router = useRouter();

const onSearchInput = (e: any) => {
    let _prods = products.value,
        _sorted = sortedProducts.value;
    const q = e.target.value;
    const regQ = new RegExp(q, "i");

    const filt = (it: Obj) => {
        return regQ.exec(it.name) ?? regQ.exec(`${it.pid}`);
    };
    if (_prods) {
        setSortedItems(_prods.filter(filt));
    }
};

const getProducts = async () => {
    try {
        setItems(null)
        const res = await apiAxios.get("/products");
        setItems(res.data.data);
    } catch (e) {
        console.log(e);
        setItems([])
    }
};

onMounted(() => {
    getProducts();
});
</script>
