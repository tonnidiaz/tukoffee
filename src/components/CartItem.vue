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
            <ion-note>R{{ item.product.price.toFixed(2) }}</ion-note>
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
            :initial-breakpoint="0.15"
            :is-open="editSheetOpen"
        >
            <!-- Edit modal -->
            <div class="w-full">
                <div class="flex items-center">
                    <TuFormField
                        class="rounded-full h-40px w-40 m-auto"
                        :value="item.quantity"
                        :on-change="(e: any)=>{item.quantity = e.target.value}"
                        :field-props="{
                            placeholder: 'Qty',
                            class: 'text-center',
                            type: 'number',
                            min: 2,
                            max: 10,
                        }"
                    >
                        <template #prefix-icon>
                            <button class="cont" @click="item.quantity--">
                                <i class="fs-20 fi fi-sr-minus-circle"></i>
                            </button>
                        </template>
                        <template #suffix-icon>
                            <button class="cont" @click="item.quantity++">
                                <i class="fs-20 fi fi-sr-add"></i>
                            </button>
                        </template>
                    </TuFormField>
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
                <div class="my-2">
                    <!-- TODO: Edit  -->
                    <ion-button
                        @click="
                            () => {
                                editSheetOpen = false;
                            }
                        "
                        expand="full"
                        color="success"
                        >Save</ion-button
                    >
                </div>
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
} from "@ionic/vue";
import { useUserStore } from "@/stores/user";
import BottomSheet from "@/components/BottomSheet.vue";
import TuFormField from "@/components/TuFormField.vue";
import { storeToRefs } from "pinia";
import { testClick } from "@/utils/funcs";
import { ref } from "vue";
const userStore = useUserStore();
const editSheetOpen = ref(false);
const { cart } = storeToRefs(userStore);
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
const logResult = (ev: CustomEvent) => {
    const { action } = ev.detail.data;
    if (action == "delete") {
        location.reload()
    }
    console.log(JSON.stringify(ev.detail, null, 2));
};
const props = defineProps({
    item: {
        type: Object,
        required: true,
    },
});
</script>
