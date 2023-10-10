<template>
    <ion-page>
        <Appbar title="Checkout" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div v-if="cart" class="p-3">
                <div class="bg-base-100">
                    <ion-item lines="none" color="clear">
                        <ion-select
                            color="dark"
                            interface="popover"
                            v-model="form.mode"
                            label="Method"
                            label-placement="floating"
                        >
                            <ion-select-option :value="OrderMode.deliver"
                                >Deliver</ion-select-option
                            >
                            <ion-select-option :value="OrderMode.collect"
                                >Collect</ion-select-option
                            >
                        </ion-select>
                    </ion-item>
                </div>

                <div class="my-3">
                    <h3 class="text-gray-500 ml-2">Order summary</h3>
                    <table class="table my-2">
                        <tbody>
                            <tr class="border-b bg-base-100">
                                <td>Items</td>
                                <td>{{ cart?.products.length ?? 0 }}</td>
                            </tr>
                            <tr class="border-b bg-base-100">
                                <td>Subtotal</td>
                                <td class="f">
                                    R{{ getTotal(cart?.products).toFixed(2) }}
                                </td>
                            </tr>
                            <tr class="border-b bg-base-100">
                                <td>Delivery fee</td>
                                <td>R{{ cart?.delivery_fee ?? 0 }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div v-if="form.mode == OrderMode.deliver" class="my-3">
                    <div class="flex w-full items-center justify-between px-2">
                        <h3>Delivery address</h3>
                        <button
                            id="add-address-trigger"
                            class="btn-sm btn p-0 rounded-full"
                        >
                            <ion-icon
                                class="w-25px h-25px"
                                :md="add"
                            ></ion-icon>
                        </button>
                        <bottom-sheet
                            trigger="add-address-trigger"
                            ref="editAddressSheet"
                        >
                            <div class="bg-base-100 p-3">
                                <h2 class="fs-20 fw-5">Add address</h2>
                                <tu-form
                                    id="addr-form"
                                    class="mt-3"
                                    :on-submit="addAddress"
                                >
                                    <div class="my-1">
                                        <tu-field
                                            :value="addressForm.location?.name"
                                            id="map-sheet-trigger"
                                            required
                                            label="Address"
                                            readonly
                                        />
                                    </div>
                                    <div
                                        class="my-1"
                                    >
                                        <tu-field
                                            v-model="addressForm.name"
                                            label="Recipient name"
                                            required
                                            placeholder="e.g. John Doe"
                                        />
                                      
                                    </div>
                                    <div class="my-1">
                                        <tu-field
                                            v-model="addressForm.phone"
                                            label="Recipient phone"
                                            required
                                            placeholder="e.g. 0723456789"
                                            type="tel"
                                        />
                                    </div>
                                    <div class="my-2">
                                        <tu-btn
                                            type="submit"
                                            ionic
                                            expand="block"
                                            color="dark"
                                            >Add address</tu-btn
                                        >
                                    </div>
                                </tu-form>
                            </div>
                            <bottom-sheet trigger="map-sheet-trigger">
                                <div class="h-100vh">
                                    <MapView
                                        :on-ok="(val: Obj)=> {addressForm.location = val; hideModal()}"
                                    />
                                </div>
                            </bottom-sheet>
                        </bottom-sheet>
                    </div>

                    <div
                        v-if="user?.delivery_addresses?.length"
                        class="my-2 bg-base-100"
                    >
                        <ion-radio-group v-model="form.address">
                            <ion-item-sliding
                                v-for="(addr, i) in user.delivery_addresses"
                            >
                                <ion-item color="clear">
                                    <ion-radio
                                        color="secondary"
                                        slot="start"
                                        :value="addr"
                                    ></ion-radio>
                                    <ion-label>
                                        <h4>{{ addr.name }}</h4>
                                        <ion-note>
                                            {{ addr.location.name }}
                                        </ion-note>
                                        <br />
                                        <ion-note class="fw-7 ion-secondary">
                                            {{ addr.phone }}
                                        </ion-note>
                                    </ion-label>
                                </ion-item>
                                <ion-item-options slot="end">
                                    <ion-item-option
                                        @click="delAddress(addr)"
                                        color="dark"
                                    >
                                        <i
                                            class="fi fi-sr-trash text-white"
                                        ></i>
                                    </ion-item-option>
                                </ion-item-options>
                            </ion-item-sliding>
                        </ion-radio-group>
                    </div>
                    <div v-else class="my-2 bg-base-100 p-3">
                        <h3 class="fw-5 text-center">Add an address</h3>
                    </div>
                </div>
                <div class="my-3" v-else>
                    <h3>Collection info</h3>
                    <div class="my-3 bg-base-">
                        <ion-item class="bg-base-100" lines="none">
                            <ion-select
                                required
                                v-model="form.store"
                                mode="ios"
                                label="Store"
                                label-placement="floating"
                            >
                                <ion-select-option
                                    :value="store._id"
                                    v-for="store in stores"
                                    >{{
                                        store.location.name
                                    }}</ion-select-option
                                >
                            </ion-select>
                        </ion-item>
                        <ion-item class="bg-base-100 my-1" lines="none">
                            <span slot="start"
                                ><i class="fi fi-br-user text-gray-500"></i
                            ></span>
                            <ion-label>
                                <h3 class="fw-6">{{ form.collector.name }}</h3>
                                <ion-note>{{ form.collector.phone }}</ion-note>
                            </ion-label>
                            <button
                                @click="collectorSheetOpen = true"
                                class="btn btn-sm p-0 w-30px h-30px btn-ghost"
                            >
                                <i
                                    class="fi fi-sr-pencil text-gray-500 fs-20"
                                ></i>
                            </button>
                        </ion-item>
                    </div>
                </div>
            </div>

            <bottom-sheet
                @did-dismiss="() => (collectorSheetOpen = false)"
                :is-open="collectorSheetOpen"
            >
                <div class="bg-base-100 w-full p-3">
                    <h3>Order collector</h3>
                    <div class="my-3">
                        <div class="my-1 bg-base-200">
                            <ion-input
                                v-model="form.collector.name"
                                required
                                label="Name:"
                                fill="solid"
                                color="dark"
                                placeholder="e.g. John Doe"
                                label-placement="floating"
                            ></ion-input>
                        </div>
                        <div class="my-1 bg-base-200">
                            <ion-input
                                v-model="form.collector.phone"
                                required
                                label="Phone:"
                                fill="solid"
                                color="dark"
                                placeholder="e.g. 0712345678"
                                type="tel"
                                label-placement="floating"
                            ></ion-input>
                        </div>
                        <div class="my-2">
                            <tu-btn
                                @click="collectorSheetOpen = false"
                                type="submit"
                                class="ion-bg-secondary w-full br-3"
                                >Save</tu-btn
                            >
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
                        <span class="fw-6"
                            >R{{
                                getTotal(cart?.products ?? []).toFixed(2)
                            }}</span
                        >
                    </div>
                    <tu-button
                        :ionic="true"
                        color="success"
                        class="w-full"
                        @click="onBtnPayClick"
                        >Pay now</tu-button
                    >
                    <PaystackBtn
                        ref="btnPaystack"
                        btn-class="btn ion-bg-success w-full br-3 hidden btn-paystack"
                        :email="'tonnidiazed@gmail.com'"
                        :amount="getTotal(cart!.products)"
                        :on-success="onCheckoutSuccess"
                        :on-cancel="() => console.log('cancelled')"
                    />
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
    useIonRouter,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { Obj, OrderMode } from "@/utils/classes";
import { useCheckoutStore } from "@/stores/checkout";
import { storeToRefs } from "pinia";
import { add, car } from "ionicons/icons";
import { useUserStore } from "@/stores/user";
import {
    hideModal,
    hideLoader,
    showAlert,
    showLoading,
    sleep,
    errorHandler,
} from "@/utils/funcs";
import TuButton from "@/components/TuButton.vue";
import PaystackBtn from "@/components/PaystackBtn.vue";
import { useStoreStore } from "@/stores/store";
import { onMounted, ref, watch } from "vue";
import { apiAxios } from "@/utils/constants";
import MapView from "@/components/MapView.vue";
import { useAppStore } from "@/stores/app";
import { useBrowserLocation } from "@vueuse/core";
const checkoutStore = useCheckoutStore();
const userStore = useUserStore();
const storeStore = useStoreStore();
const appStore = useAppStore();
const { stores, store } = storeToRefs(storeStore);
const { user, cart } = storeToRefs(userStore);
const { orderMode } = storeToRefs(checkoutStore);

const collectorSheetOpen = ref(false);
const btnPaystack = ref<any>();
const form = ref<Obj>({
    collector: {},
    mode: OrderMode.collect,
});

const addressForm = ref<Obj>({
    location: {},
});

const deliveryAddresses = ref<any[]>([]);

const router = useIonRouter();

async function addAddress(e: any) {
    e.preventDefault();
    appStore.setLoadingMsg("Adding address...");
    appStore.setIsLoading(true);
    const res = await apiAxios.post("/user/delivery-address?action=add", {
        address: addressForm.value,
    });

    userStore.setUser(res.data.user);
    appStore.setIsLoading(false);
    hideModal();
}

async function onBtnPayClick() {

    const _form = form.value;

    if (_form.mode == OrderMode.collect && !_form.store) {
        showAlert({ message: "Please select a store" });
        return;
    } else if (_form.mode == OrderMode.deliver && !_form.address) {
        showAlert({ message: "Please select or add a delivery address" });
        return;
    }

    const btn: any = document.querySelector(".btn-paystack");
    console.log(btn);
    btn?.click();
}

function getTotal(p: any[]) {
    let total = 0;
    p.forEach((el) => (total += el.product.price));
    return total;
}

async function createOrder() {
    try {
        showLoading({msg: 'Creating order'})
        const _form = form.value;
        console.log("creating order...");

        const res = await apiAxios.post(
            `/order/create?mode=${_form.mode}&cartId=${cart.value!._id}`,
            _form
        );
        hideLoader()
        cart.value = {...cart.value, products: []}
       router.push(`/order/${res.data.order.oid}`) 
    } catch (error) {
        console.log(error);
        showAlert({message: 'Failed to create order. Please contact us at ' + store.value?.email})
  
    }
}

const onCheckoutSuccess = (res: any) => {
    createOrder();
};

const delAddress = async (addr: Obj) => {
    showLoading({});
    try {
        const res = await apiAxios.post(
            "/user/delivery-address?action=remove",
            { address: addr }
        );
        userStore.setUser(res.data.user);
    } catch (e) {
        console.log(e);
        errorHandler(e, "Failed to delete address");
    }
    hideLoader();
};
watch(
    user,
    (_user) => {
        if (!_user) return;
        deliveryAddresses.value = _user.delivery_addresses;
        const _form = form.value;
        if (!_form.collector.name) {
            _form.collector = {
                name: `${_user["first_name"]} ${_user["last_name"]}`,
                phone: _user.phone,
            };
        }
    },
    { deep: true, immediate: true }
);
</script>
