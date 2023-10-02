<template>
    <ion-page>
        <Appbar title="Orders" :show-cart="route.path == '/orders'">
            <DropdownBtn :items="[
               orders && !selectedItems.length ? {label: 'Select all', cmd: onSelectAll} : null,
             selectedItems.length ? {label: 'Deselect all', cmd: ()=> selectedItems = []} : null,

               selectedItems.length ? {label: 'Cancel selected orders', cmd: onCancelSelected} : null,
                {label: 'Back to home', cmd: ()=> $router.push('/~/home')},
            ]"/>
       
        </Appbar>
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init" />
            <div class="flex flex-col h-full">
                <div class="my-1 bg-base-100 p-3">
                <div
                    class="bg-base-200 rounded-md flex items-center px-4 h-45px gap-2"
                >
                    <span class="mt-1"
                        ><i class="fi fi-rr-search fs-18 text-gray-700"></i
                    ></span>

                    <ion-input
                        color="clear"
                        placeholder="Order ID"
                        class="tu bg-primar"
                        @ion-input="(e:any)=> orderID = e.target.value"
                    ></ion-input>
                    <button
                        class="mt-2"
                        @click="filterSheetOpen = true"
                    >
                        <i
                            class="fi fi-rr-settings-sliders fs-18 text-gray-700"
                        ></i>
                    </button>
                </div>
            </div>

                <ion-list v-if="_orders && _orders.length" class="my-0 mx-2 bg-base-100">
                    <order-item v-for="(order, i) in _orders" :order="order" />
                </ion-list>
                <div v-else class="flex-auto flex items-center justify-center">
                    <h3>{{ !_orders ? "Loading..." : "Nothing to show" }}</h3>
                </div>
            </div>

            <!-- Modals -->
            <BottomSheet :is-open="filterSheetOpen" @did-dismiss="filterSheetOpen = false" id="filter-sheet">
                <div class="p-3 bg-base-100  flex flex-col justify-center">
                    <div class="flex w-full justify-between my-3">
                        <h3 class="">FILTER</h3>
                        <button @click="()=>orderStore.toggleOrder()" class="btn btn-sm btn-ghost p- rounded-full">
                            <i v-if="orderStore.sortOrder == SortOrder.ascending" class="fi fi-rr-sort-amount-down-alt fs-20 text-gray-600"></i>
                            <i v-else class="fi fi-rr-sort-amount-up-alt fs-20 text-gray-600"></i>
                        </button>
                    </div>


                    <ion-item lines="none">
                        <ion-select  interface="popover" @ion-change="orderStore.setSortBy($event.target.value)" :value="orderStore.sortBy" mode="md" label="Sort by" label-placement="floating">
                            <ion-select-option :value="OrderSortBy.created">Date created</ion-select-option>
                            <ion-select-option :value="OrderSortBy.modified">Last modified</ion-select-option>
                        </ion-select>
                    </ion-item>
                    <ion-item class="my-1" lines="none">
                        <ion-select interface="popover"  @ion-change="orderStore.setStatus($event.target.value)" :value="orderStore.status"  mode="md" label="Status" label-placement="floating">
                            <ion-select-option :value="OrderStatus.all">All</ion-select-option>
                            <ion-select-option :value="OrderStatus.pending">Pending</ion-select-option>
                            <ion-select-option :value="OrderStatus.cancelled">Cancelled</ion-select-option>
                            <ion-select-option :value="OrderStatus.completed">Completed</ion-select-option>
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
    IonSelect,
    IonItem,
    IonSelectOption,
    IonInput
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import OrderItem from "@/components/OrderItem.vue";
import { onMounted, ref, watch } from "vue";
import { apiAxios } from "@/utils/constants";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import { useOrderStore, OrderSortBy,  } from "@/stores/order";
import { useAppStore } from "@/stores/app";
import Refresher from "@/components/Refresher.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import {SortOrder, OrderStatus} from '@/utils/classes';
import { useRoute } from "vue-router";
import DropdownBtn from "@/components/DropdownBtn.vue";

const userStore = useUserStore()
const orderStore = useOrderStore()
const appStore = useAppStore()

const popoverOpen = ref(false), popoverEvent = ref<Event>();
const { user } = storeToRefs(userStore)
const { orders, sortedOrders } = storeToRefs(orderStore)
const { selectedItems } = storeToRefs(appStore)
const _orders = ref<typeof sortedOrders.value>()
const orderID = ref<number>()

const filterSheetOpen = ref(false)

const route = useRoute()

async function getOrders() {
    orderStore.setOrders(null)
    try {
        const url = route.path == '/orders' ? `/orders?user=${user.value?._id}` : '/orders'
        const res = await apiAxios.get(url)
        orderStore.setOrders(res.data.orders)
    } catch (e) {
        console.log(e)
        orderStore.setOrders([])
    }
}
async function init() { await getOrders() }

const onSelectAll = () => {
    popoverOpen.value = false
    appStore.setSelectedItems(_orders.value!)
}

async function onCancelSelected() {
    const q = confirm("Are you sure you want to cancel the selected orders?")
    if (q) {
        const act = 'cancel'
        const ids = selectedItems.value.map(el => el._id)
        appStore.setSelectedItems([])
        try {
            const res = await apiAxios.post(`/order/cancel?action=${act}`, { userId: user.value?._id, ids: ids })
            orderStore.setOrders(res.data.orders)
        } catch (error) {
            console.log(error)
        }
    }


}

function byIdinizer(){
    const val = sortedOrders.value
    const _orderID = orderID.value;
    try{
            _orders.value = val ? ( !_orderID ? val :  val.filter((el: any)=> `${el.oid}`.includes(`${_orderID}`))) : null

    }catch(e){
        console.log(e)
    }
}
watch(sortedOrders, (val)=>{
     byIdinizer()
}, {deep: true, immediate: true})
watch(orderID, val=>{
    console.log(val)
byIdinizer()
})
onMounted(() => {
    init()
})
</script>