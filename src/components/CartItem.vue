<template>
    <!--  :router-link="`/product/${item.product.pid}`" -->
    <ion-item color="clear">
        <ion-thumbnail
            :router-link="`/product/${item.product.pid}`"
            class="h-45px shadow-lg card rounded-lg"
            slot="start"
        > 
            <ion-img
                v-if="item.product.images?.length"
                class="rounded-lg"
                :src="item.product.images[0].url"
            ></ion-img>
            <span v-else>
                <i class="fi fi-rr-image-slash text-gray-600"></i>
            </span>
        </ion-thumbnail>
        <ion-label :router-link="`/product/${item.product.pid}`">
            <h3>{{ item.product.name }}</h3>
            <div class="flex gap-3 items-center">
                            <ion-note>R{{ item.product.price.toFixed(2) }}</ion-note>
                            <span class="fw-5">x{{ item.quantity }}</span>

            </div>
        </ion-label>
        <button
            slot="end"
            @click="editSheetOpen = true"
            class="relative rounded-full px-3 py-1 btn btn-ghost"
            :id="`edit-btn-${item._id}`"
        >
            <i class="fi fi-br-pencil fs-13 text-gray-600"></i>
        </button>

        <BottomSheet
        @did-dismiss="editSheetOpen = false"

            :is-open="editSheetOpen"
        >
            <!-- Edit modal -->
            <div class="w-full  flex flex-col justify-center items-center relative bg-base-100 py-4 px-3">
                <div class="flex items-center">
                    <div class="flex flex-center rounded-full h-40px w-40 border-1 border-success px-2 gap-2 relative">
                 
                            <button class="mt-2" @click="updateQty(true)">
                                <i class="fs-20 fi fi-sr-minus-circle text-gray-500"></i>
                            </button>
                            <ion-input color="clear" class="text-center" type="number" :min="0" placeholder="Qty" :value="form.quantity" 
                            @ion-input="onQtyInput"
                            ></ion-input>
                            <button class="mt-2" @click="updateQty()">
                                <i class="fs-20 fi fi-sr-add text-gray-500"></i>
                            </button>
                        </div>
                    <ion-button
                        id="open-action-sheet"
                        shape="round"
                        size="small"
                        fill="clear"
                        color="dark"
                        slot="icon-only"
                    >
                        <i class="fs-20 fw-8 fi fi-sr-trash text-gray-700"></i>
                    </ion-button>
                    <ion-action-sheet
                        trigger="open-action-sheet"
                        header="Remove item from cart?"
                        mode="ios"
                        class="ios tu"
                        @didDismiss="logResult($event)"
                        :buttons="actionSheetButtons"
                    ></ion-action-sheet>
                </div>
                    <tu-button
                       :on-click="updateCart"
                        ionic
                        class="w-full"
                        color="success"
                        >Save</tu-button
                    >
            </div>
        </BottomSheet>
    </ion-item>
</template>
<script setup lang="ts">
import {
    IonNote,
    IonItem,
    IonImg,
    IonLabel,
    IonActionSheet,
    IonThumbnail,
    IonButton,
    IonInput
} from "@ionic/vue";
import { useUserStore } from "@/stores/user";
import BottomSheet from "@/components/BottomSheet.vue";


import { errorHandler, testClick } from "@/utils/funcs";
import { ref, watch } from "vue";
import { Obj } from "@/utils/classes";
import TuButton from "./TuButton.vue";
import { apiAxios } from "@/utils/constants";
const userStore = useUserStore();

const form = ref<Obj>({})
const editSheetOpen = ref(false);
const { setCart } = userStore;
const actionSheetButtons = [
    {
        text: "Confirm",
        role: "destructive",
        data: {
            action: "delete",
        },
    },

    {
        text: "Cancel",
        role: "cancel",
        data: {
            action: "cancel",
        },
    },
];

const updateCart = async(act = 'add')=>{
    try{
    const res = await apiAxios.post(`/user/cart?action=${act}`, form.value)
    setCart(res.data.cart)
    editSheetOpen.value = false
    }catch(e){
        errorHandler(e)
    }
}

const onQtyInput = (e: any) => { 
    let  {value } = e.target
    value = parseInt(value)
    const {item} = props
    let v = value <= 1 ? 1 : (value >= item.product.quantity ? item.product.quantity : value)
    e.target.value = v
 }

 function updateQty(decrement = false){
    const { quantity } = form.value
    if (decrement && quantity > 1){
        form.value.quantity--
    }else if(!decrement && quantity < props.item.product.quantity) {
        form.value.quantity++
    }
 }
const logResult = (ev: CustomEvent) => {
    const { action } = ev.detail.data;
    if (action == "delete") {
        updateCart('remove')
    }
    console.log(JSON.stringify(ev.detail, null, 2));
};
const props = defineProps({
    item: {
        type: Object,
        required: true,
    },
});
watch(props.item, val=>{
    form.value = {...form.value, quantity: val.quantity, product: val.product._id}
}, {deep: true, immediate: true})

</script>
