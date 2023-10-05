<template>
    <ion-page>
        <Appbar title="Cart" :show-cart="false">
           <DropdownBtn :items="[{
            label: 'Clear cart',
            cmd: clearCart
           }]"/>
        </Appbar>
        <ion-content :fullscreen="true">
           <refresher :on-refresh="async () => await _setupCart(user)"/>
            <div class="p-1 w-full h-full">
                <ion-popover trigger="click-trigger" trigger-action="click">
                    <ion-content class="">
                        <ul tabindex="0" class="menu border-1 border-gray-200">
                            <li>
                                <a>Clear cart</a>
                            </li>
                           
                            <li>
                                <a>Clear cart</a>
                            </li>
                            <li>
                                <a>Clear cart</a>
                            </li>
                        </ul>
                    </ion-content>
                </ion-popover>
                <div v-if="cart" class="bg-base-100 pb-4">
                    <div>
                        <ion-item-divider color="clear">
                            <ion-label>Items </ion-label>
                        </ion-item-divider>

                        <CartItem v-if="cart?.products.length"
                            v-for="(e, i) in cart?.products"
                            :item="e"
                        >
                           
                        </CartItem>
                        <div v-else class="h-full flex flex-center py-7">
                            <h3 class="fs-18 fw-5">Cart empty</h3>
                        </div>
                    </div>
                </div>
                <div
                    v-else
                    class="h-full w-full flex items-center justify-center"
                >
                    <span
                        ><i
                            class="fi fi-rr-person-dolly-empty fs-80 text-gray-500"
                        ></i
                    ></span>
                </div>
            </div>

        </ion-content>
        <ion-footer v-if="cart" class="ion-no-border">
            <ion-toolbar class="p-2">
                <div class="flex items-center justify-between">
                    <span class="fw-7">Total:</span>
                    <span class="fw-6">R{{ total.toFixed(2) }}</span>
                </div>
                <ion-button router-link="/order/checkout" class="w-full">Proceed to checkout</ion-button>
            </ion-toolbar>
        </ion-footer>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonItemDivider,
    IonFooter,
    IonContent,
    IonToolbar,
    IonButton,
    IonLabel,
    IonPopover,
    IonIcon,
    IonRefresher,
    IonRefresherContent,
    useIonRouter,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { ellipsisVertical } from "ionicons/icons";
import { errorHandler, setupCart } from "@/utils/funcs";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import CartItem from "@/components/CartItem.vue";
import {  onBeforeUnmount, ref, watch } from "vue";
import $ from "jquery";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { apiAxios } from "@/utils/constants";
import { Obj } from "@/utils/classes";
const userStore = useUserStore();
const {user, cart} = storeToRefs(userStore)
const {setCart} = userStore
const total = ref(0);


const clearCart = async () => {
    try{
        const res = await apiAxios.post('/user/cart?action=clear')
        setCart(res.data.cart)
    }catch(e){
        errorHandler(e)
    }
};


const _setupCart = async (user: Obj | null) => { 
    cart.value = null
     if (user?.phone){
       cart.value = await setupCart(user.phone, userStore)
    }
 }


watch(user, (val)=>{
    _setupCart(val)
}, {deep: true})
watch(
    cart,
    (_cart) => {
        if (_cart) {
            let _total = 0;
            for (let it of _cart.products) {
                _total +=( it.product.price * it.quantity);
            }
            total.value = _total;
        }
    },
    { deep: true, immediate: true }
);


 
</script>
