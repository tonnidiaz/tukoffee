<template>
    <ion-page>
        <Appbar :show-cart="false" v-if="$route.params.id" :title="`Order #${$route.params.id}`" />
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init" />
            <div v-if="!order" class="bg-base-100 h-full w-full flex items-center justify-center">
                <ion-spinner class="w-50px h-50px" color="medium"></ion-spinner>
            </div>
            <div v-else class="py-1">
                <section class=" px-3 py-1 border-1 bg-base-100">


                    <table class="table my-2 bg-base-200 br-0">
                        <th colspan="2" class="fs-20">
                            <h3>Details</h3>
                            </th>
                        <tbody>
                            <tr>
                                <td class="fw-6 fs-16">Order ID</td>
                                <td class=" fs-16 " style="text-align: end;">{{ order.oid }}</td>
                            </tr>
                            <tr>
                                <td class="fw-6 fs-16">Order status</td>
                                <td class=" fs-16 " style="text-align: end;">{{ order.status }}</td>
                            </tr>
                            <tr>
                                <td class="fw-6 fs-16">Date created</td>
                                <td class=" fs-16 " style="text-align: end;">{{ new
                                    Date(order.date_created).toLocaleDateString() }}</td>
                            </tr>
                            <tr>
                                <td class="fw-6 fs-16">Last modified</td>
                                <td class=" fs-16 " style="text-align: end;">{{ new
                                    Date(order.last_modified).toLocaleDateString() }}</td>
                            </tr>
                        </tbody>
                    </table>
                    <table class="table my-2 bg-base-200 br-0">
                        <th colspan="2" class="fs-20"> <h3>Customer</h3></th>
                        <tbody>
                            <tr>
                                <td class="fw-6 fs-16">Name</td>
                                <td class=" fs-16 " style="text-align: end;">{{ (order?.customer?.first_name ?? user!.first_name) + ' ' +
                                    (order?.customer?.last_name ?? user!.last_name) }}</td>
                            </tr>
                            <tr>
                                <td class="fw-6 fs-16">Phone</td>
                                <td class=" fs-16 " style="text-align: end;">{{ order?.customer?.phone ?? user!.phone }}</td>
                            </tr>

                        </tbody>
                    </table>
                    <table class="table my-2 bg-base-200 br-0">
                        <th colspan="2" class="fs-20"><h3>Recipient</h3></th>
                        <tbody>
                            <tr>
                                <td class="fw-6 fs-16">Name</td>
                                <td class=" fs-16 " style="text-align: end;">{{ order.collector.name }}</td>
                            </tr>
                            <tr>
                                <td class="fw-6 fs-16">Phone</td>
                                <td class=" fs-16 " style="text-align: end;">{{ order.collector.phone }}</td>
                            </tr>

                        </tbody>
                    </table>
                    <table v-if="order.mode == OrderMode.deliver" class="table my-2 bg-base-200 br-0">
                        <th colspan="2" class="flex items-center justify-between">
                            <h3 class="fs-20">Delivery address</h3>
                            <icon-btn @click="mapSheetOpen = true"
                                class="btn btn-sm btn-ghost rounded-full w-30px h-30px">
                                <i class="fi fi-br-pencil fs-18"></i>
                            </icon-btn>
                            <BottomSheet :no-swipe-dismiss="true"  :is-open="mapSheetOpen" @did-dismiss="mapSheetOpen = false">
                                <div class="h-100vh">
                                    <MapView :on-ok="(addr: Obj)=>{form.delivery_address = {...form.delivery_address, location: addr}; mapSheetOpen = false}"/>
                                </div>
                            </BottomSheet>
                        </th>
                        <tbody>
                            <tr>
                                <td class=" fs-16">
                                    {{ order.delivery_address?.location?.name }}</td>
                            </tr>


                        </tbody>
                    </table>
                    <section v-else class="bg-base-200 px-3">
                        <ion-select color="dark" v-model="form.store" mode="ios" label="Store" label-placement="floating">
                            <ion-select-option v-for="(it, i) in stores" :value="it._id">{{it?.location?.name}}</ion-select-option>
                        </ion-select>
                    </section>
                </section>
                <section class="my-1 p-3 border-1  bg-base-100">
                    <h3 class="fs-20">Items</h3>
                    <div class="my-2">
                        <ion-list>
                            <ion-item v-for="(it, i) in order.products">
                                <ion-label>
                                    <h3>{{ it.product.name }}</h3>
                                </ion-label>
                                <div class="flex items-end" slot="end">
                                    <span><i class="fi fi-rr-cross-small fs-13"></i></span>
                                    <span>{{ it.quantity }}</span>
                                </div>
                            </ion-item>
                        </ion-list>
                    </div>
                </section>
            </div>


        </ion-content>
        <ion-footer v-if="order" class="ion-no-borde">
            <ion-toolbar>
                <div class="p-3">
                    <div v-if="user?.permissions > 0" class="bg-base-200 px-3 rounded">
                          <ion-select interface="popover" class="bg-base-" mode="md" v-model="form.status" label="Status"
                        label-placement="floating">
                        <ion-select-option value="pending">Pending</ion-select-option>
                        <ion-select-option value="cancelled">Cancelled</ion-select-option>
                        <ion-select-option value="completed">Completed</ion-select-option>
                    </ion-select>
                    </div>
                  <TuButton :on-click="saveChanges" :disabled="btnSaveChangesDisabled" class="mt-2 w-full" :ionic="true">Save changes</TuButton>
                </div>

            </ion-toolbar>
        </ion-footer>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonFooter,
    IonToolbar,
    IonList,
    IonContent,
    IonItem,
    IonLabel,
    IonSelect,
    IonSelectOption,
    IonSpinner,
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import TuButton from '@/components/TuButton.vue';
import MapView from '@/components/MapView.vue';
import BottomSheet from '@/components/BottomSheet.vue';
import Refresher from '@/components/Refresher.vue';
import { onMounted, ref, watch, watchEffect } from "vue";
import { useRoute } from "vue-router";
import { apiAxios } from "@/utils/constants";
import { Obj, OrderMode } from "@/utils/classes";
import { storeToRefs } from "pinia";
import { useStoreStore } from "@/stores/store";
import { useUserStore } from "@/stores/user";
import { errorHandler } from "@/utils/funcs";

const { stores } = storeToRefs(useStoreStore())
const { user} = storeToRefs(useUserStore())
const order = ref<{ [key: string]: any } | null>()

const form = ref<{ [key: string]: any }>({})
const mapSheetOpen = ref(false)
const btnSaveChangesDisabled = ref(true)
const route = useRoute()
const oid = ref(route.params.id)

async function getOrder() {
    order.value = null
    try {
        const res = await apiAxios.get(`/orders?oid=${oid.value}`)
        order.value = res.data.orders[0]
    } catch (error) {
        console.log(error)
    }
}
async function init() {
    await getOrder()
}

const saveChanges = async ()=>{
    try{
        const res = await apiAxios.post('/order/edit', form.value, {params: {
            id: order.value!._id
        }})
        init()
    }catch(e){
        errorHandler(e, 'Failed to modify order')
    }
}
onMounted(() => {
    init()
})

watch(order, val => {
    if (val) {
        form.value = { status: val.status, store: val.store?._id, delivery_address: val.delivery_address}
    }
}, { deep: true, immediate: true })

watchEffect(()=>{
    const _form = form.value, _order = order.value;
    btnSaveChangesDisabled.value = _form.status == _order?.status && _form.store == _order?.store?._id && _form.delivery_address == _order?.delivery_address
},)
</script>

<style lang="scss" scoped>
tr {
    border-top: 1.5px solid rgb(66, 66, 66, .2) !important;
}
</style>