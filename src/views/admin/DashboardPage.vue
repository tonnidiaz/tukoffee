<template>
    <ion-page>
        <Appbar title="Dashboard" :show-cart="false" :loading="!data">
            <DropdownBtn
                :items="[{ label: 'Back to home', cmd: () => toHome() }]"
            />
        </Appbar>
        <ion-content :fullscreen="true">
            <refresher :on-refresh="setupDash"/>
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
                        {{ data?.products?.length ?? 0 }}
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
                        {{ data?.orders?.length ?? 0 }}
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
                        {{ data?.customers?.length ?? 0 }}
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
                        {{ data?.reviews?.length ?? 0 }}
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
import { onMounted, ref } from "vue";
import { storeToRefs } from "pinia";
import { Obj } from "@/utils/classes";
const dashStore = useDashStore();

const data = ref<Obj | null>()

const setupDash = async () => {
    try {
        data.value = null
        const res = await apiAxios.get("/admin/dash");
        
        data.value = res.data
    } catch (e) {
        console.log(e);

    }
};
onMounted(() => {
    console.log("setting up dash");
    setupDash();
});
</script>
