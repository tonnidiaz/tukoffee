<template>
    <ion-page>
        <Appbar title="Orders">
            <button id="open-action-sheet" class="btn btn-sm fs-20 btn-ghost p-0 w-35px h-35px rounded-full">
                <ion-icon :md="ellipsisVertical"></ion-icon>
            </button>
            <ion-action-sheet
                        trigger="open-action-sheet"
                        mode="ios"
                        class="ios tu"
                        :buttons="selectedItems.length ? [
                            {
                            text: 'Select all',
                            data:{
                                action: 'select'
                            }
                        },
                            {
                            text: 'Cancel all',
                            data:{
                                action: 'cancell'
                            }
                        },
                        ]:[
                            {
                            text: 'Select all',
                            data:{
                                action: 'select'
                            }
                        }
                        ]"
                    />
        </Appbar>
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init"/>
            <div class="p-3">
                <TuFormField class="rounded-full" :field-props="{
                    class: 'rounded-full',
                    placeholder: 'Order ID'
                }">
                    <template #prefix-icon>
                        <span class="field-icon btn btn-sm btn-ghost">
                            <i class="fi fi-rr-search"></i>
                        </span>
                    </template>
                    <template #suffix-icon>
                        <span class="field-icon btn btn-sm btn-ghost">
                            <i class="fi fi-rr-settings-sliders"></i>
                        </span>
                    </template>
                </TuFormField>

                <ion-list v-if="orders && orders.length" class="my-3 bg-base-100">
                   <order-item v-for="(order, i) in orders" :order="order"/>
                </ion-list>
                <div v-else class="flex-auto">
                    <h3>{{ !orders ? "Loading..." : "Nothing to show"}}</h3>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonList,
    IonIcon
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import TuFormField from "@/components/TuFormField.vue";
import OrderItem from "@/components/OrderItem.vue";
import { onMounted } from "vue";
import { apiAxios } from "@/utils/constants";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import { useOrderStore } from "@/stores/order";
import { useAppStore } from "@/stores/app";
import { ellipsisVertical } from "ionicons/icons";
import Refresher from "@/components/Refresher.vue";


const userStore = useUserStore()
const orderStore = useOrderStore()
const appStore = useAppStore()

const {user} = storeToRefs(userStore)
const {orders} = storeToRefs(orderStore)
const {selectedItems} = storeToRefs(appStore)

async function getOrders(){
    orderStore.setOrders(null)
    try{
        const res = await apiAxios.get(`/orders?user=${user.value?._id}`)
        orderStore.setOrders(res.data.orders)
    }catch(e){
        console.log(e)
        orderStore.setOrders([])
    }
}
async function init(){await getOrders()}

onMounted(()=>{
    init()
})
</script>