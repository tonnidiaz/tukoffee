<template>
    <ion-page>
        <Appbar title="Products" :show-cart="false">
            <DropdownBtn
                :items="[{ label: 'Back to home', cmd: () => toHome() }]"
            />
        </Appbar>

        <ion-fab vertical="bottom" horizontal="end">
            <ion-fab-button id="add-fab" color="dark">
                <span class="mt-1"><i class="fi fi-rr-plus"></i></span>
            </ion-fab-button>

            <BottomSheet trigger="add-fab">
                <div class="h-100vh">
                    <AddProductView />
                </div>
            </BottomSheet>
        </ion-fab>
        <ion-content :fullscreen="true">
            <div class="h-full flex flex-col">
                <Refresher :on-refresh="getProducts" />
                <div class="my-1 bg-base-100 p-3">
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
                            id="/products-filter-sheet-trigger"
                            @click="console.log('click')"
                        >
                            <i
                                class="fi fi-rr-settings-sliders fs-18 text-gray-700"
                            ></i>
                        </button>
                    </div>
                </div>
                <div
                    v-if="!sortedProducts"
                    class="bg-base-100 h-full w-full flex items-center justify-center"
                >
                    <ion-spinner
                        class="w-45px h-45px"
                        color="medium"
                    ></ion-spinner>
                </div>
                <div
                    v-else-if="sortedProducts.length"
                    class="bg-base-100 pb-4 my-0"
                >
                    <ProductItem
                        :reload="getProducts"
                        v-for="it in sortedProducts"
                        :item="it"
                    />
                </div>
                <div v-else class="bg-base-100 my- flex-auto flex-center flex">
                    <h3>Nothing to show</h3>
                </div>
            </div>
        </ion-content>
        <!-- New product sheet -->

        <!-- Filter sheet -->
        <BottomSheet trigger="/products-filter-sheet-trigger" id="filter-sheet">
            <div class="p-3 bg-base-100 flex flex-col justify-center">
                <div class="flex w-full justify-between my-3 items-center">
                    <h3 class="">FILTER</h3>
                    <button
                        @click="() => toggleOrder()"
                        class="btn btn-sm btn-ghost p- rounded-full"
                    >
                        <i
                            v-if="sortOrder == SortOrder.ascending"
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
                            >Date added</ion-select-option
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

        <!-- Loading -->
        <ion-loading
            color="dark"
            message="Please wait..."
            :is-open="isLoading"
            @didDismiss="isLoading = false"
        />
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonAlert,
    IonItem,
    IonContent,
    IonSelect,
    IonFab,
    IonFabButton,
    IonSpinner,
    IonInput,
    IonLoading,
    IonSelectOption,
} from "@ionic/vue";

import Appbar from "@/components/Appbar.vue";
import ProductItem from "@/components/ProductItem.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import Refresher from "@/components/Refresher.vue";

import { onMounted, ref } from "vue";
import { Obj, SortOrder } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { useRouter } from "vue-router";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { useProductsStore, Status, SortBy } from "@/stores/products";
import { storeToRefs } from "pinia";
import { useAppStore } from "@/stores/app";
import { sleep, toHome } from "@/utils/funcs";
import AddProductView from "@/components/AddProductView.vue";

const productsStore = useProductsStore();
const appStore = useAppStore();

const {
    sortBy,
    sortOrder,
    sortedItems: sortedProducts,
    items: products,
    status,
} = storeToRefs(productsStore);
const { selectedItems } = storeToRefs(appStore);
const { setItems, setSortBy, toggleOrder, setSortedItems, setStatus } =
    productsStore;

const newProductSheetOpen = ref(false);
const delAlertOpen = ref(false),
    isLoading = ref(false);

const router = useRouter();

const onSearchInput = (e: any) => {
    let _prods = products.value;
    const q = e.target.value;
    const regQ = new RegExp(q, "i");

    const filt = (it: Obj) => {
        console.log(it.name);
        return regQ.exec(it.name) ?? regQ.exec(`${it.pid}`);
    };
    if (_prods) {
        setSortedItems(_prods.filter(filt));
    }
};

const getProducts = async () => {
    try {
        setItems(null);
        const res = await apiAxios.get("/products");
        setItems(res.data.data);
    } catch (e) {
        console.log(e);
        setItems([]);
    }
};

onMounted(() => {
    getProducts();
});
</script>
