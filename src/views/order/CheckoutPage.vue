<template>
    <ion-page>
        <Appbar title="Checkout" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div class="p-3">
                <div class="bg-base-100">
                    <ion-item lines="none" color="clear">
                        <ion-select v-model="checkoutStore.orderMode" label="Method" label-placement="floating">
                            <ion-select-option :value="OrderMode.deliver">Deliver</ion-select-option>
                            <ion-select-option :value="OrderMode.collect">Collect</ion-select-option>
                        </ion-select>
                    </ion-item>
                </div>

                <div class="my-3">
                    <h3 class="text-gray-500 ml-2">Order summary</h3>
                    <table class="table my-2">
                        <tbody>
                            <tr class="border-b bg-base-100 ">
                                <td>Items</td>
                                <td>{{ cart?.products.length ?? 0 }}</td>
                            </tr>
                            <tr class="border-b bg-base-100 ">
                                <td>Subtotal</td>
                                <td class="f">R{{ getTotal(cart?.products) }}</td>
                            </tr>
                            <tr class="border-b bg-base-100 ">
                                <td>Delivery fee</td>
                                <td>R{{ cart?.delivery_fee ?? 0 }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div v-if="orderMode == OrderMode.deliver" class="my-3">
                    <div class="flex w-full items-center justify-between px-2">
                        <h3>Delivery address</h3>
                        <button class="btn-sm btn p-0 rounded-full">
                            <ion-icon class="w-25px h-25px" :md="add"></ion-icon>
                        </button>
                    </div>

                    <div class="my-2 bg-base-100">
                        <ion-item-sliding v-for="(addr, i) in user?.delivery_addresses">
                            <ion-item color="clear">
                                <ion-label>
                                    <h4>{{ addr.name }}</h4>
                                    <ion-note>
                                        {{ addr.location.name }}
                                    </ion-note>
                                    <br>
                                    <ion-note class="fw-7 text-accent">
                                        {{ addr.phone }}
                                    </ion-note>
                                </ion-label>
                            </ion-item>
                            <ion-item-options slot="end">
                                <ion-item-option color="secondary">
                                    <i class="fi fi-sr-trash text-white"></i>
                                </ion-item-option>
                            </ion-item-options>
                        </ion-item-sliding>
                    </div>
                </div>
            </div>
        </ion-content>
        <ion-footer class="ion-no-border">
            <ion-toolbar>
                <div class="p-3">
                    <div class="flex items-center justify-between">
                        <span class="fw-7">Total:</span>
                        <span class="fw-6">R{{ getTotal(cart?.products) }}</span>
                    </div>
                    <tu-button @click="onPayBtnClick" class="btn btn-success w-full br-0 shadow-lg">Pay now</tu-button>

                </div>
            </ion-toolbar>

        </ion-footer>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonFooter,
    IonItem,
    IonIcon,
    IonContent,
    IonLabel,
    IonNote,
    IonToolbar,
    IonSelect,
    IonSelectOption,
    IonItemSliding,
    IonItemOptions,
    IonItemOption,
    IonButton,
useIonRouter
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { OrderMode } from "@/utils/classes";
import { useCheckoutStore } from "@/stores/checkout";
import { storeToRefs } from "pinia";
import { add } from "ionicons/icons";
import { useUserStore } from "@/stores/user";
import { sleep } from "@/utils/funcs";
import TuButton from '@/components/TuButton.vue';
const checkoutStore = useCheckoutStore();
const userStore = useUserStore()
const { user, cart } = storeToRefs(userStore)

const { orderMode } = storeToRefs(checkoutStore);
const router = useIonRouter()
function getTotal(p: any[]) {
    let total = 0
    p.forEach(el => total += el.product.price)
    return total.toFixed(2)
}

async function onPayBtnClick(){
    await sleep(2000)
    router.push('/order/checkout/payment')
}
</script>
