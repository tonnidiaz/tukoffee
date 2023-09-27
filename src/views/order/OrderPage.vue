<template>
    <ion-page>
        <Appbar v-if="$route.params.id" :title="`Order #${$route.params.id}`" />
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init"/>
            <div v-if="!order" class="bg-base-100 h-full w-full flex items-center justify-center">
                <ion-spinner class="w-50px h-50px" color="medium"></ion-spinner>
            </div>
            <div v-else class="py-3">
                <section class=" p-3 border-1  bg-base-100">


                    <table class="table my-2 bg-base-200 br-0">
                        <th colspan="2" class="fs-20">Details</th>
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
                        <th colspan="2" class="fs-20">Customer</th>
                        <tbody>
                            <tr>
                                <td class="fw-6 fs-16">Name</td>
                                <td class=" fs-16 " style="text-align: end;">{{ order.customer.first_name + ' ' +
                                    order.customer.last_name }}</td>
                            </tr>
                            <tr>
                                <td class="fw-6 fs-16">Phone</td>
                                <td class=" fs-16 " style="text-align: end;">{{ order.customer.phone }}</td>
                            </tr>

                        </tbody>
                    </table>
                    <table class="table my-2 bg-base-200 br-0">
                        <th colspan="2" class="fs-20">Recipient</th>
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
                    <table class="table my-2 bg-base-200 br-0">
                        <th colspan="2" class="fs-20">Delivery address</th>
                        <tbody>
                            <tr>
                                <td class=" fs-16">{{ order.delivery_address.location.name }}</td>
                            </tr>


                        </tbody>
                    </table>
                </section>
                <section class="my-1 p-3 border-1  bg-base-100">
                    <h3>Items</h3>
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
        <ion-footer v-if="order" class="ion-no-border">
            <ion-toolbar>
                <div class="p-3">
                    <ion-select interface="popover" class="bg-base-" mode="md" v-model="form.status" label="Status"
                        label-placement="floating">
                        <ion-select-option value="pending">Pending</ion-select-option>
                        <ion-select-option value="cancelled">Cancelled</ion-select-option>
                        <ion-select-option value="completed">Completed</ion-select-option>
                    </ion-select>
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
    IonNote,
    IonSelect,
    IonSelectOption,
    IonSpinner,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import Refresher from '@/components/Refresher.vue';
import { onMounted, ref, watch } from "vue";
import { dummyOrder } from "@/utils/dummies";
import { OrderStatus } from "@/utils/classes";
import { useRoute } from "vue-router";
import { apiAxios } from "@/utils/constants";
const order = ref<{ [key: string]: any } | null>()

const form = ref<{ [key: string]: any }>({})

const route = useRoute()
const oid = ref(route.params.id)

async function getOrder(){
    order.value = null
    try {
        const res = await apiAxios.get(`/orders?oid=${oid.value}`)
        order.value = res.data.orders[0]
    } catch (error) {
        console.log(error)
    }
}
async function init(){
    await getOrder()
}

onMounted(()=>{
    init()
})

watch(order, val => {
    if (val) {
        form.value = { status: val.status }
    }
}, { deep: true, immediate: true })
</script>

<style lang="scss" scoped>tr {
    border-top: 1.5px solid rgb(66, 66, 66, .2) !important;
}</style>