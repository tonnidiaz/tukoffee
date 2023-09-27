<template>
    <ion-page>
        <Appbar title="Cart">
            <ion-button shape="round" id="click-trigger" slot="icon-only" @click="()=>console.log('Ellipsis')"
                ><ion-icon :md="ellipsisVertical"></ion-icon
            ></ion-button>
        </Appbar>
        <ion-content :fullscreen="true">
            <ion-refresher slot="fixed" :pull-factor="0.5" :pull-min="100" :pull-max="200" @ionRefresh="handleRefresh($event)">
                <ion-refresher-content> </ion-refresher-content>
            </ion-refresher>
            <div class="px-3 py-2 w-full h-full">
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

                        <CartItem
                            v-for="(e, i) in userStore.cart?.products"
                            :item="e"
                        >
                           
                        </CartItem>
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
    IonNote,
    IonFooter,
    IonContent,
    IonToolbar,
    IonButton,
    IonImg,
    IonLabel,
    IonThumbnail,
    IonPopover,
    IonIcon,
    IonRefresher,
    IonRefresherContent,
    useIonRouter,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { closeOutline, listCircle, ellipsisVertical } from "ionicons/icons";
import { randomImg, setupCart } from "@/utils/funcs";
import { dummyProduct, dummyProducts } from "@/utils/dummies";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import CartItem from "@/components/CartItem.vue";
import {  onBeforeUnmount, onMounted, onUnmounted, ref, watch } from "vue";
import $ from "jquery";
import BottomSheet from "@/components/BottomSheet.vue";
const userStore = useUserStore();
const {user} = storeToRefs(userStore)
const cart = ref<{[key: string]: any} | null>()
const total = ref(0);

const ionRouter = useIonRouter();

const clickOutside = () => {
    $(".outside").trigger("click");
};


const _setupCart = async () => { 
    cart.value = null
     if (user.value?.phone){
       cart.value = await setupCart(user.value['phone'], userStore)
    }
 }
const handleRefresh = async (e: any) => {
   
    await _setupCart()
    e.target.complete()
};

watch(user, ()=>{
    _setupCart()
}, {deep: true, immediate: true})
watch(
    cart,
    (_cart) => {
        if (_cart) {
            let _total = 0;
            for (let it of _cart.products) {
                _total += it.product.price;
            }
            total.value = _total;
        }
    },
    { deep: true, immediate: true }
);

onBeforeUnmount(()=>{
  cart.value = null
})
 
</script>
