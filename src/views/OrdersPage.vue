<template>
    <ion-page>
        <Appbar title="Orders">
            <button @click="openPopover" id="open-action-sheet"
                class="btn btn-sm fs-20 btn-ghost p-0 w-35px h-35px rounded-full">
                <ion-icon :md="ellipsisVertical"></ion-icon>
            </button>
            <ion-popover :event="popoverEvent" :is-open="popoverOpen" @did-dismiss="popoverOpen = false" class="">

                <div class="bg-base-100">
                    <ul class="menu">
                        <li v-if="orders"><a @click="onSelectAll">Select all</a></li>
                        <li v-if="selectedItems.length"><a @click="onCancelSelected">Cancel selected</a></li>
                    </ul>
                </div>
            </ion-popover>
        </Appbar>
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init" />
            <div class="p-3 flex flex-col h-full">
                <TuFormField class="rounded-full" :value="`${orderID ?? ''}`" :on-change="(e: any)=>orderID = e.target.value" :field-props="{
                    class: 'rounded-full',
                    placeholder: 'Order ID',
                }">
                    <template #prefix-icon>
                        <span class="field-icon btn btn-sm btn-ghost">
                            <i class="fi fi-rr-search fs-18"></i>
                        </span>
                    </template>
                    <template #suffix-icon>
                        <span id="filter-sheet-trigger" class="field-icon btn btn-sm btn-ghost">
                            <i class="fi fi-rr-settings-sliders fs-18"></i>
                        </span>
                    </template>
                </TuFormField>
                <div class="dropdown hidden">
                    <label tabindex="0" class="btn m-1"> <ion-icon :md="ellipsisVertical"></ion-icon> </label>
                    <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                        <li><a>Item 1</a></li>
                        <li><a>Item 2</a></li>
                    </ul>
                </div>
                <ion-list v-if="_orders && _orders.length" class="my-3 bg-base-100">
                    <order-item v-for="(order, i) in _orders" :order="order" />
                </ion-list>
                <div v-else class="flex-auto flex items-center justify-center">
                    <h3>{{ !_orders ? "Loading..." : "Nothing to show" }}</h3>
                </div>
            </div>

            <!-- Modals -->
            <BottomSheet trigger="filter-sheet-trigger" id="filter-sheet">
                <div class="p-3 bg-base-100  flex flex-col justify-center">
                    <div class="flex w-full justify-between my-3">
                        <h3 class="">FILTER</h3>
                        <button @click="()=>orderStore.toggleOrder()" class="btn btn-sm btn-ghost p- rounded-full">
                            <i v-if="orderStore.sortOrder == SortOrder.ascending" class="fi fi-rr-sort-amount-down-alt fs-20 text-gray-600"></i>
                            <i v-else class="fi fi-rr-sort-amount-up-alt fs-20 text-gray-600"></i>
                        </button>
                    </div>


                    <ion-item lines="none">
                        <ion-select @ion-change="orderStore.setSortBy($event.target.value)" :value="orderStore.sortBy" mode="ios" label="Sort by" label-placement="floating">
                            <ion-select-option :value="OrderSortBy.created">Date created</ion-select-option>
                            <ion-select-option :value="OrderSortBy.modified">Last modified</ion-select-option>
                        </ion-select>
                    </ion-item>
                    <ion-item class="my-1" lines="none">
                        <ion-select  @ion-change="orderStore.setStatus($event.target.value)" :value="orderStore.status"  mode="ios" label="Status" label-placement="floating">
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
    IonIcon,
    IonPopover,
    IonSelect,
    IonItem,
    IonSelectOption
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import TuFormField from "@/components/TuFormField.vue";
import OrderItem from "@/components/OrderItem.vue";
import { onMounted, ref, watch } from "vue";
import { apiAxios } from "@/utils/constants";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import { useOrderStore, OrderSortBy,  } from "@/stores/order";
import { useAppStore } from "@/stores/app";
import { ellipsisVertical } from "ionicons/icons";
import Refresher from "@/components/Refresher.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import {SortOrder, OrderStatus} from '@/utils/classes';

const userStore = useUserStore()
const orderStore = useOrderStore()
const appStore = useAppStore()

const popoverOpen = ref(false), popoverEvent = ref<Event>();
const { user } = storeToRefs(userStore)
const { orders, sortedOrders } = storeToRefs(orderStore)
const { selectedItems } = storeToRefs(appStore)
const _orders = ref<typeof sortedOrders.value>()
const orderID = ref<number>()
function openPopover(e: Event) {
    popoverEvent.value = e;
    popoverOpen.value = true;
}
function hidePopover() { popoverOpen.value = false }
async function getOrders() {
    orderStore.setOrders(null)
    try {
        const res = await apiAxios.get(`/orders?user=${user.value?._id}`)
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
    hidePopover()

    const q = confirm("Are you sure you want to cancel the selected orders?")
    if (q) {
        const act = 'cancel'
        const fd = new FormData()
        const ids = selectedItems.value.map(el => el._id)
        fd.append('userId', user.value?._id)
        fd.append('ids', JSON.stringify(ids))
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
byIdinizer()
})
onMounted(() => {
    init()
})
</script>