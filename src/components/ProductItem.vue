<template>
    <OnLongPress @trigger="onLongPress">
        <ion-item color="clear" @click="onItemClick">
            <ion-thumbnail
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
            <ion-label>
                <h3 class="fw-5 fs-16">{{ item.name }}</h3>
                <ion-note>R{{ item.price.toFixed(2) }}</ion-note>
            </ion-label>
            <ion-checkbox
                :checked="
                    selectedItems.findIndex((el) => el._id == item._id) != -1
                "
                v-if="selectedItems?.length"
                slot="end"
                mode="ios"
            ></ion-checkbox>
     
        </ion-item>
    </OnLongPress>

    <ion-loading
        color="dark"
        message="Please wait..."
        :is-open="isLoading"
        @didDismiss="isLoading = false"
    />
</template>
<script setup lang="ts">
import {
    IonNote,
    IonItem,
    IonImg,
    IonLabel,
    IonCheckbox,
    IonThumbnail,
    IonLoading,
} from "@ionic/vue";
import { useUserStore } from "@/stores/user";
import { storeToRefs } from "pinia";
import { ref } from "vue";
import { useFormStore } from "@/stores/form";
import router from "@/router";
import { useAppStore } from "@/stores/app";
import { OnLongPress } from "@vueuse/components";

const userStore = useUserStore();
const formStore = useFormStore();
const appStore = useAppStore();

const { selectedItems } = storeToRefs(appStore);
const delAlertOpen = ref(false),
    isLoading = ref(false);
const { cart } = storeToRefs(userStore);

const isHolding = ref(false);

const onEditClick = (e: any) => {
    formStore.setForm(props.item);
    router.push("/edit/product");
};



const toggleSelected = () => {
    const inList = selectedItems.value.find((el) => el._id == props.item._id);
    const data = inList
        ? selectedItems.value.filter((el) => el._id != props.item._id)
        : [...selectedItems.value, props.item];
    appStore.setSelectedItems(data);
};
const onItemClick = (e: any) => {
    console.log(e.defaultPrevented);
    if (!selectedItems.value.length && !e.defaultPrevented) {
        router.push(`/product/${props.item.pid}`);
    }
    e.preventDefault();
    if (selectedItems.value.length) toggleSelected();
};
const onLongPress = (e: PointerEvent) => {
    return
    isHolding.value = true;
    toggleSelected();
    isHolding.value = false;
};
const props = defineProps({
    item: {
        type: Object,
        required: true,
    },
    reload: {
        type: Function,
        required: true,
    },
});
</script>
