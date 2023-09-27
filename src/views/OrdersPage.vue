<template>
    <ion-page>
        <Appbar title="Orders">
            <button @click="openPopover" id="open-action-sheet" class="btn btn-sm fs-20 btn-ghost p-0 w-35px h-35px rounded-full">
                <ion-icon :md="ellipsisVertical"></ion-icon>
            </button>
           <ion-popover :event="popoverEvent" :is-open="popoverOpen" @did-dismiss="popoverOpen = false"  class="" >

            <div class="bg-base-100">
                <ul class="menu">
                    <li v-if="orders"><a @click="onSelectAll">Select all</a></li>
                    <li v-if="selectedItems.length"><a >Cancel selected</a></li>
                </ul>
            </div>
           </ion-popover>
        </Appbar>
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init"/>
            <div class="p-3 flex flex-col h-full">
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
                        <span id="filter-sheet-trigger" class="field-icon btn btn-sm btn-ghost">
                            <i class="fi fi-rr-settings-sliders"></i>
                        </span>
                    </template>
                </TuFormField>

                <ion-list v-if="orders && orders.length" class="my-3 bg-base-100">
                   <order-item v-for="(order, i) in orders" :order="order"/>
                </ion-list>
                <div v-else class="flex-auto flex items-center justify-center">
                    <h3>{{ !orders ? "Loading..." : "Nothing to show"}}</h3>
                </div>
            </div>

            <!-- Modals -->
            <BottomSheet  trigger="filter-sheet-trigger" id="filter-sheet">
                <div class="p-3 bg-base-100  flex flex-col justify-center">
                    <div class="flex w-full justify-between my-3">
                         <h3 class="">FILTER</h3>
                         <button class="btn btn-sm btn-ghost p-0 rounded-full">
                            <i class="fi fi-rr-sort-amount-down-alt fs-20 text-gray-600"></i>
                         </button>
                    </div>
                   

                    <ion-item lines="none">
                        <ion-select mode="ios" label="Sort by" label-placement="floating">
                            <ion-select-option>Date created</ion-select-option>
                            <ion-select-option>Last modified</ion-select-option>
                        </ion-select>
                    </ion-item>
                    <ion-item class="my-1" lines="none">
                        <ion-select mode="ios" label="Status" label-placement="floating">
                            <ion-select-option>All</ion-select-option>
                            <ion-select-option>Pending</ion-select-option>
                            <ion-select-option>Cancelled</ion-select-option>
                            <ion-select-option>Completed</ion-select-option>
                        </ion-select>
                    </ion-item>
                </div>
            </BottomSheet>
        </ion-content>
    </ion-page> 
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonList,
    IonIcon,
    IonPopover,
    IonSelect,
    IonItem,
    IonSelectOption
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import TuFormField from "@/components/TuFormField.vue";
import OrderItem from "@/components/OrderItem.vue";
import { onMounted, ref } from "vue";
import { apiAxios } from "@/utils/constants";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import { useOrderStore } from "@/stores/order";
import { useAppStore } from "@/stores/app";
import { ellipsisVertical } from "ionicons/icons";
import Refresher from "@/components/Refresher.vue";
import BottomSheet from "@/components/BottomSheet.vue";


const userStore = useUserStore()
const orderStore = useOrderStore()
const appStore = useAppStore()

const popoverOpen = ref(false), popoverEvent = ref<Event>();
const {user} = storeToRefs(userStore)
const {orders} = storeToRefs(orderStore)
const {selectedItems} = storeToRefs(appStore)

function openPopover(e: Event){
    popoverEvent.value = e;
    popoverOpen.value = true;
}
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

const onSelectAll = ()=>{ 
    popoverOpen.value = false
    appStore.setSelectedItems(orders.value!)}
onMounted(()=>{
    init()
})
</script>