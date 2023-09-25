<template>
    <ion-page>
        <Appbar title="Cart" />
        <ion-content :fullscreen="true">
            <div class="px-3 py-1 w-full h-full">
                <div v-if="cart" class="bg-base-100 pb-4">
                    <div >
                          <ion-item-divider color="clear">
                        <ion-label>Items </ion-label>
                    </ion-item-divider>

                    <CartItem v-for="(e, i) in userStore.cart?.products" :item="e">
                        <ion-thumbnail class="h-45px shadow-lg card rounded-lg" slot="start">
                            <ion-img v-if="e.product.images?.length"
                                class="rounded-lg"
                                :src="e.product.images[0].url"
                            ></ion-img>
                            <span v-else>
                                <i class="fi fi-rr-image-slash text-gray-600"></i>
                            </span>
                        </ion-thumbnail>
                        <ion-label>
                            <h3>{{ e.product.name }}</h3>
                            <ion-note>R{{ e.product.price.toFixed(2) }}</ion-note>
                        </ion-label>
                        <div class="flex flex-col" slot="end">
                            <span
                                class="relative"
                                @click="console.log('Edit')"
                            >
                                <i
                                    class="fi fi-br-pencil fs-13 text-gray-600"
                                ></i
                            ></span>
                            <span
                                class="relative"
                                @click="console.log('Remove')"
                            >
                                <i
                                    class="fi fi-br-cross fs-12 text-gray-600"
                                ></i
                            ></span>
                            <!--  <ion-button
                                fill="clear"
                                size="small"
                                color="dark"
                                shape="round"
                                class=""
                            >
                                <ion-icon :md="closeOutline"></ion-icon>
                            </ion-button>
                            <ion-button
                                fill="clear"
                                size="small"
                                class=""
                                color="dark"
                                shape="round"
                            >
                                <ion-icon :md="closeOutline"></ion-icon>
                            </ion-button> -->
                        </div>
                    </CartItem>
                    </div>
                  
                </div>
                <div v-else class="h-full w-full flex items-center justify-center">
                    <span><i class="fi fi-rr-person-dolly-empty fs-80 text-gray-500"></i></span>
                </div>
            </div>
        </ion-content>
        <ion-footer v-if="cart" class="ion-no-border">
                <ion-toolbar class="p-2">
                    <div class="flex items-center justify-between">
                        <span class="fw-7">Total:</span>
                        <span class="fw-6">R{{total.toFixed(2)}}</span>
                    </div>
                    <ion-button class="w-full">Proceed to checkout</ion-button>
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
    IonRippleEffect,
    IonRow,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { closeOutline, listCircle, removeSharp } from "ionicons/icons";
import { randomImg } from "@/utils/funcs";
import { dummyProduct, dummyProducts } from "@/utils/dummies";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import CartItem from '@/components/CartItem.vue';
import { ref, watch } from "vue";
const userStore = useUserStore()
const {cart} = storeToRefs(userStore)
const total = ref(0)

watch(cart, _cart=>{
    if (_cart){
        let _total = 0;
        for (let it of _cart.products){
            _total += it.product.price
        }
        total.value = _total
    }
}, {deep: true, immediate: true})
</script>
