<template>
    <ion-page>
        <Appbar title="Checkout" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div v-if="cart" class="p-3">
                <div class="bg-base-100">
                    <ion-item lines="none" color="clear">
                        <ion-select interface="popover" v-model="form.mode" label="Method" label-placement="floating">
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
                                <td class="f">R{{ getTotal(cart?.products).toFixed(2) }}</td>
                            </tr> 
                            <tr class="border-b bg-base-100 ">
                                <td>Delivery fee</td>
                                <td>R{{ cart?.delivery_fee ?? 0 }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div v-if="form.mode == OrderMode.deliver" class="my-3">
                    <div class="flex w-full items-center justify-between px-2">
                        <h3>Delivery address</h3>
                        <button class="btn-sm btn p-0 rounded-full">
                            <ion-icon class="w-25px h-25px" :md="add"></ion-icon>
                        </button>
                    </div>

                    <div class="my-2 bg-base-100">
                        <ion-radio-group v-model="form.address">
                            <ion-item-sliding v-for="(addr, i) in user?.delivery_addresses">
                            <ion-item color="clear">
                                <ion-radio color="secondary" slot="start" :value="addr"></ion-radio>
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
                        </ion-radio-group>
                        
                    </div>
                </div>
                <div class="my-3" v-else>
                    <h3>Collection info</h3>
                    <div class="my-3 bg-base-">
                        <ion-item class="bg-base-100" lines="none">
                            <ion-select required v-model="form.store" mode="ios" label="Store" label-placement="floating">
                                <ion-select-option :value="store._id" v-for="store in stores">{{store.location.name}}</ion-select-option>
                            </ion-select>
                        </ion-item>
                        <ion-item class="bg-base-100 my-1" lines="none">
                            
                            <span slot="start"><i class="fi fi-br-user text-gray-500"></i></span>
                            <ion-label>
                                <h3 class="fw-6">{{form.collector.name}}</h3>
                                <ion-note>{{ form.collector.phone }}</ion-note>
                            </ion-label>
                            <button @click="collectorSheetOpen = true" class="btn btn-sm p-0 w-30px h-30px btn-ghost">
                                <i class="fi fi-sr-pencil text-gray-500 fs-20"></i>
                            </button>
                        </ion-item>
                    </div>
                </div>
            </div>

            <bottom-sheet @did-dismiss="()=>collectorSheetOpen = false" :is-open="collectorSheetOpen">
            <div class="bg-base-100 w-full p-3">
                <h3>Order collector</h3>
                <div class="my-3">
                    <div class="my-1 bg-base-200">
                        <ion-input v-model="form.collector.name" required label="Name:" fill="solid" color="dark" placeholder="e.g. John Doe" label-placement="floating"></ion-input>
                    </div>
                    <div class="my-1 bg-base-200">
                        <ion-input v-model="form.collector.phone" required label="Phone:" fill="solid" color="dark" placeholder="e.g. 0712345678" type="tel" label-placement="floating"></ion-input>
                    </div>
                    <div class="my-2">
                        <tu-btn @click="collectorSheetOpen = false" type="submit" class="ion-bg-secondary w-full br-3">Save</tu-btn>
                    </div>
                </div>
            </div>
            </bottom-sheet>
        </ion-content>
        <ion-footer v-if="cart" class="ion-no-border">
            <ion-toolbar>
                <div class="p-3">
                    <div class="flex items-center justify-between">
                        <span class="fw-7">Total:</span>
                        <span class="fw-6">R{{ getTotal(cart?.products ?? []).toFixed(2) }}</span>
                    </div>
                    <tu-button :ionic="true" color="success" class="w-full" @click="onBtnPayClick">Pay now</tu-button>
                   <PaystackBtn ref="btnPaystack"
                   btn-class="btn ion-bg-success w-full br-3 hidden btn-paystack"
                   :email="'tonnidiazed@gmail.com'" :amount="getTotal(cart!.products)" :on-success="onCheckoutSuccess" :on-cancel="()=>console.log('cancelled')"/>

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
    IonInput,
    IonRadio,
    IonRadioGroup,

useIonRouter
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Obj, OrderMode } from "@/utils/classes";
import { useCheckoutStore } from "@/stores/checkout";
import { storeToRefs } from "pinia";
import { add, car } from "ionicons/icons";
import { useUserStore } from "@/stores/user";
import { sleep } from "@/utils/funcs";
import TuButton from '@/components/TuButton.vue';
import PaystackBtn from "@/components/PaystackBtn.vue";
import { useStoreStore } from "@/stores/store";
import { onMounted, ref } from "vue";
import { apiAxios } from "@/utils/constants";
const checkoutStore = useCheckoutStore();
const userStore = useUserStore()
const storeStore = useStoreStore()

const {stores} = storeToRefs(storeStore)
const { user, cart } = storeToRefs(userStore)

const { orderMode } = storeToRefs(checkoutStore);

const collectorSheetOpen = ref(false)
const btnPaystack = ref<any>()
const form = ref<Obj>({
    collector: {},
    mode: OrderMode.collect
})
const deliveryAddresses = ref<any[]>([])

const router = useIonRouter()

async function onBtnPayClick(){
    const _form = form.value

    if (_form.mode == OrderMode.collect && !_form.store){
       alert('Store is required')
        return;
    }
    else if (_form.mode == OrderMode.deliver && !_form.address){
        alert('Delivery address is required')
    }

    const btn : any = document.querySelector('.btn-paystack')
    console.log(btn)
    btn?.click()
   
}

function getTotal(p: any[]) {
    let total = 0
    p.forEach(el => total += el.product.price)
    return total
}

async function createOrder(){
    try {
        const _form = form.value
        console.log('creating order...')

        const res = await apiAxios.post(`/order/create?mode=${_form.mode}&cartId=${cart.value!._id}`, _form)
        console.log(res.data)
        router.replace(`/order/${res.data.order.oid}`)
    } catch (error) {
        console.log(error)
    }
}

const onCheckoutSuccess = (res: any) => { 
    console.log(res)
    createOrder()
 }

 onMounted(()=>{
    const _user = user.value;
    if (!_user) return;
    deliveryAddresses.value = _user.delivery_addresses
    const _form = form.value
    if (!_form.collector.name){
        _form.collector = {
            name: `${_user['first_name']} ${_user['last_name']}`,
            phone: _user.phone
        }
    }
 })
</script>
