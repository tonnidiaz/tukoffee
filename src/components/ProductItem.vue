<template>
    <!--  :router-link="`/product/${item.pid}`" -->
    <ion-item color="clear">
        <ion-thumbnail
            :router-link="`/product/${item.pid}`"
            class="h-45px shadow-lg card rounded-lg"
            slot="start"
        > 
            <ion-img
                v-if="item.images?.length"
                class="rounded-lg"
                :src="item.images[0].url"
            ></ion-img>
            <span v-else>
                <i class="fi fi-rr-image-slash text-gray-600"></i>
            </span>
        </ion-thumbnail>
        <ion-label :router-link="`/product/${item.pid}`">
            <h3>{{ item.name }}</h3>
            <ion-note>R{{ item.price.toFixed(2) }}</ion-note>
        </ion-label>
        <button
            slot="end"
            @click="editSheetOpen = true"
            class="relative rounded-full p-0 w-30px h-30px btn btn-ghost"
            :id="`edit-btn-${item._id}`"
        >
            <i class="fi fi-br-menu-dots-vertical fs-13 text-gray-600"></i>
        </button>

      
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
