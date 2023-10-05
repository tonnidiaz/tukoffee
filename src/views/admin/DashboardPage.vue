<template>
    <ion-page>
        <Appbar title="Dashboard" :show-cart="false">
            <DropdownBtn
                :items="[{ label: 'Back to home', cmd: () => toHome() }]"
            />
        </Appbar>
        <ion-content :fullscreen="true">
            <div class="grid justify-center gap-1 p-3 grid-cols-3">
                <router-link
                    to="/admin/products"
                    class="bg-base-100 cursor-pointer border-1 shadow-sm ion-activatable relative rounded-lg product-card p-1"
                >
                    <div class="my-2 flex flex-center">
                        <ion-avatar class="bg-base-200">
                            <span>
                                <i
                                    class="fi fi-sr-box-open-full text-gray-500"
                                ></i>
                            </span>
                        </ion-avatar>
                    </div>
                    <p class="text-center fw-6 text-gray-500">
                        {{ products?.length ?? 0 }}
                    </p>
                    <h3 class="fs-15 fw-5 text-center">Products</h3>
                </router-link>
                <router-link
                    to="/admin/orders"
                    class="bg-base-100 cursor-pointer border-1 shadow-sm ion-activatable relative rounded-lg product-card p-1"
                >
                    <div class="my-2 flex flex-center">
                        <ion-avatar class="bg-base-200">
                            <span>
                                <i
                                    class="fi fi-sr-person-dolly text-gray-500"
                                ></i>
                            </span>
                        </ion-avatar>
                    </div>
                    <p class="text-center fw-6 text-gray-500">
                        {{ orders?.length ?? 0 }}
                    </p>
                    <h3 class="fs-15 fw-5 text-center">Orders</h3>
                </router-link>
                <router-link
                    to="/admin/accounts"
                    class="bg-base-100 cursor-pointer border-1 shadow-sm ion-activatable relative rounded-lg product-card p-1"
                >
                    <div class="my-2 flex flex-center">
                        <ion-avatar class="bg-base-200">
                            <span>
                                <i
                                    class="fi fi-sr-users text-gray-500"
                                ></i>
                            </span>
                        </ion-avatar>
                    </div>
                    <p class="text-center fw-6 text-gray-500">
                        {{ orders?.length ?? 0 }}
                    </p>
                    <h3 class="fs-15 fw-5 text-center">Accounts</h3>
                </router-link>
                <router-link
                    to="/admin/reviews"
                    class="bg-base-100 cursor-pointer border-1 shadow-sm ion-activatable relative rounded-lg product-card p-1"
                >
                    <div class="my-2 flex flex-center">
                        <ion-avatar class="bg-base-200">
                            <span>
                                <i
                                    class="fi fi-sr-people-poll text-gray-500"
                                ></i>
                            </span>
                        </ion-avatar>
                    </div>
                    <p class="text-center fw-6 text-gray-500">
                        {{ orders?.length ?? 0 }}
                    </p>
                    <h3 class="fs-15 fw-5 text-center">Product reviews</h3>
                </router-link>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonContent, IonAvatar } from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { toHome } from "@/utils/funcs";

import { useDashStore } from "@/stores/dash";
import { apiAxios } from "@/utils/constants";
import { onMounted } from "vue";
import { storeToRefs } from "pinia";
const dashStore = useDashStore();
const { products, accounts, orders } = storeToRefs(dashStore);
const setupDash = async () => {
    try {
        const res = await apiAxios.get("/admin/dash");
        const { data } = res;
        dashStore.setProducts(data.products);
        dashStore.setOrders(data.orders);
        dashStore.setAccounts(data.customers);
    } catch (e) {
        console.log(e);
    }
};
onMounted(() => {
    console.log("setting up dash");
    setupDash();
});
</script>
