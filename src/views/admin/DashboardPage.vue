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
                                    class="fi fi-sr-box-open-full text-coffee2"
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
                                    class="fi fi-sr-person-dolly text-orange"
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
                                    class="fi fi-sr-people-poll text-green"
                                ></i>
                            </span>
                        </ion-avatar>
                    </div>
                    <p class="text-center fw-6 text-gray-500">
                        {{ data?.reviews?.length ?? 0 }}
                    </p>
                    <h3 class="fs-15 fw-5 text-center">Product reviews</h3>
                </router-link>
                <a
                    target="_blank" href="https://dashboard.paystack.com/#/dashboard?period=30"
                    class="bg-base-100 cursor-pointer border-1 shadow-sm ion-activatable relative rounded-lg product-card p-1 flex flex-col  justify-center"
                >
                    <div class="my-2 flex flex-center">
                        <ion-avatar class="bg-base-200">
                            <span>
                                <i
                                    class="fi fi-sr-apps text-coffee3"
                                ></i>
                            </span>
                        </ion-avatar>
                    </div>
                 
                    <h3 class="fs-15 fw-5 text-center">Paystack Dashboard</h3>
                </a>
            </div>
            <div class="m-3 hidden">
                <ion-item class="bg-base-100" target="_blank" href="https://dashboard.paystack.com/#/dashboard?period=30">
                    <ion-label>
                        Paystack Dashboard
                    </ion-label>
                    <div slot="end">
                        <span class="mt-1">
                            <i class="fi fi-br-link-alt fs-18 text-gray-600"></i>
                        </span>
                    </div>
                </ion-item>
            </div>
            
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonContent, IonAvatar, IonItem, IonLabel } from "@ionic/vue";
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
<style lang="scss">
 $coffee: rgba(63, 35, 5, 1);
  $coffee1: rgba(108, 52, 40, 1);
  $coffee2: rgba(186, 112, 79, 1);
  $coffee3: rgba(223, 168, 120, 1);
$orange: rgba(255, 152, 0, 1);
$green: rgba(76, 175, 80, 1);
$yellow: rgba(255, 235, 59, 1);
$red: rgba(244, 67, 54, 1);


.text-coffee{
    color: $coffee
}
.text-coffee1{
    color: $coffee1
}
.text-coffee2{
    color: $coffee2
}
.text-coffee3{
    color: $coffee3
}
.text-orange{
    color: $orange
}
.text-green{
    color: $green
}
.text-yellow{
    color: $yellow
}
.text-red{
    color: $red
}


</style>