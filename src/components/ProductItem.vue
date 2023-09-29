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
        <div slot="end">
            <dropdown-btn :items="[
                { label: 'Edit', cmd: onEditClick },
                { label: 'Delete', cmd: () => {delAlertOpen = true} },
                ]" />
        </div>
        <IonAlert
        message="Are you sure you want to delete this product?"
        header="Delete product" 
        :is-open="delAlertOpen"
        :buttons="[
            {text: 'Cancel', role: 'cancel'},
            {text: 'Yes', role: 'confirm', handler: delProduct},
        ]"
         @didDismiss="delAlertOpen = false"/>
    </ion-item>

    <ion-loading color="dark" message="Please wait..." :is-open="isLoading" @didDismiss="isLoading = false"/>
</template>
<script setup lang="ts">
import {
    IonNote,
    IonItem,
    IonImg,
    IonLabel,
    IonIcon,
    IonThumbnail,
    IonLoading,
IonAlert,
} from "@ionic/vue";
import { useUserStore } from "@/stores/user";
import BottomSheet from "@/components/BottomSheet.vue";
import TuFormField from "@/components/TuFormField.vue";
import { storeToRefs } from "pinia";
import { ref } from "vue";
import DropdownBtn from "./DropdownBtn.vue";
import { useFormStore } from "@/stores/form";
import router from "@/router";
import { apiAxios } from "@/utils/constants";
import { sleep } from "@/utils/funcs";

const userStore = useUserStore();
const formStore = useFormStore();


const delAlertOpen = ref(false), isLoading = ref(false);
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

const onEditClick = () => { 
    formStore.setForm(props.item)
    router.push('/edit/product')
 }

const delProduct = async () =>{
    const it = props.item
    try {
        isLoading.value = true
       const res = await apiAxios.post(`/products/delete?pid=${it["pid"]}`)
        isLoading.value = false
        await sleep(100)
        props.reload()
    } catch (error) {
        console.log(error)
    }
}

const logResult = (ev: CustomEvent) => {
    const { action } = ev.detail.data;
    if (action == "delete") {
        location.reload();
    }
    console.log(JSON.stringify(ev.detail, null, 2));
};
const props = defineProps({
    item: {
        type: Object,
        required: true,
    },
    reload:{
        type: Function,
        required : true
    }
});
</script>
