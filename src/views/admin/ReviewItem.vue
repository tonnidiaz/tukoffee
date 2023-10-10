<template>
    <OnLongPress @trigger="onLongPress">
        <div>
            <div class="flex justify-end pr-5 mt-2">
                <span class="fs-12">
                {{ new Date(rev.last_modified).toLocaleDateString() }} </span
            >
            </div>
            <ion-item
                class="tu"
                :router-link="`/products/reviews/${rev._id}`"
                @click="onItemClick"
                color="clear"
            >
                <ion-thumbnail
                    class="h-45px shadow-lg card rounded-lg"
                    slot="start"
                >
                    <ion-img
                        v-if="rev.product.images?.length"
                        class="rounded-lg"
                        :src="rev.product.images[0].url"
                    ></ion-img>
                    <span v-else>
                        <i class="fi fi-rr-image-slash text-gray-600"></i>
                    </span>
                </ion-thumbnail>
                <ion-label class="m-0">
                    <h3 class="fw-5 fs-16">{{ rev.title }}</h3>
                    <ion-note class="">
                        <span class="fw-6">{{ rev.name }}</span>
                    </ion-note>
                    <br />
                    <ion-badge
                        mode="ios"
                        :color="
                            rev.status == 0
                                ? 'medium'
                                : rev.status == 1
                                ? 'success'
                                : 'danger'
                        "
                        class="py-1"
                    >
                        {{ reviewStatuses[rev.status] }}
                    </ion-badge>
                </ion-label>
                <ion-checkbox
                    :checked="
                        selectedItems.findIndex((el) => el._id == rev._id) != -1
                    "
                    v-if="selectedItems?.length"
                    slot="end"
                    mode="ios"
                ></ion-checkbox>
                <DropdownBtn
                    v-else
                    :has-slot="false"
                    :items="[
                        {
                            label: 'Edit',
                            cmd: () => (editSheetOpen = true),
                        },
                        {
                            label: 'Delete',
                            cmd: () => delReview(rev),
                        },
                    ]"
                >
                </DropdownBtn>
                <!-- Edit sheet -->
                <bottom-sheet
                    :is-open="editSheetOpen"
                    @did-dismiss="editSheetOpen = false"
                >
                    <div class="">
                        <div class="bg-base-100 p-3">
                            <ion-accordion-group expand="compact">
                                <tu-accordion :title="rev.title">
                                    <p>{{ rev.body }}</p>
                                </tu-accordion>
                            </ion-accordion-group>
                            <ion-item class="mt-2" lines="none">
                                <ion-select
                                    label="Status"
                                    label-placement="floating"
                                    v-model="editRevForm.status"
                                    @ion-change="
                                        console.log($event.detail.value)
                                    "
                                >
                                    <ion-select-option
                                        :value="i"
                                        v-for="(st, i) in reviewStatuses"
                                        >{{ st }}</ion-select-option
                                    >
                                </ion-select>
                            </ion-item>
                            <div class="mt-3">
                                <tu-btn :on-click="saveChanges" expand="block"
                                    >Save changes</tu-btn
                                >
                            </div>
                        </div>
                    </div>
                </bottom-sheet>
            </ion-item>
        </div>
    </OnLongPress>
</template>

<script setup lang="ts">
import {
    IonItem,
    IonThumbnail,
    IonAccordionGroup,
    IonSelect,
    IonSelectOption,
    IonImg,
    IonLabel,
    IonNote,
    IonCheckbox,
    IonBadge,
} from "@ionic/vue";
import { Obj } from "@/utils/classes";
import { apiAxios, reviewStatuses } from "@/utils/constants";
import { OnLongPress } from "@vueuse/components";
import {
    errorHandler,
    hideLoader,
    hideModal,
    showAlert,
    showLoading,
} from "@/utils/funcs";
import { ref, watch, watchEffect } from "vue";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { useAppStore } from "@/stores/app";
import { storeToRefs } from "pinia";
const appStore = useAppStore();
const { selectedItems } = storeToRefs(appStore);

const isHolding = ref(false);
const editRevForm = ref<Obj>({});

const editSheetOpen = ref(false);
const props = defineProps({
    rev: {
        type: Object,
        required: true,
    },
    setReviews: Function,
});

async function delReview(rev: Obj) {
    showAlert({
        title: "Delete review",
        message: "Are you sure you want to delete the review?",
        buttons: [
            {
                text: "Cancel",
                role: "cancel",
            },
            {
                text: "Yes",
                handler: async () => {
                    try {
                        showLoading({ msg: "Deleting review..." });
                        const res = await apiAxios.post(
                            "/products/review?act=del",
                            { id: rev._id }
                        );
                        if (props.setReviews) {
                            props.setReviews(res.data.reviews);
                        }
                        hideLoader();
                    } catch (e) {
                        errorHandler(e, "Failed to delete review");
                        hideLoader();
                    }
                },
            },
        ],
    });
}

const saveChanges = async () => {
    try {
        showLoading({ msg: "Saving changes" });
        const res = await apiAxios.post("/products/review?act=edit", {
            id: props.rev._id,
            review: editRevForm.value,
        });
        if (props.setReviews) {
            props.setReviews(res.data.reviews);
        }
        hideLoader();
        hideModal();
    } catch (e) {
        errorHandler(e, "Failed to save changes");
        hideLoader();
    }
};

const toggleSelected = () => {
    const inList = selectedItems.value.find((el) => el._id == props.rev._id);
    const data = inList
        ? selectedItems.value.filter((el) => el._id != props.rev._id)
        : [...selectedItems.value, props.rev];
    appStore.setSelectedItems(data);
};

const onItemClick = (e: any) => {
    e.preventDefault();
    if (selectedItems.value.length) toggleSelected();
};
const onLongPress = (e: PointerEvent) => {
    isHolding.value = true;
    toggleSelected();
    isHolding.value = false;
};

watchEffect(() => {
    const _rev = props.rev;
    editRevForm.value = { status: _rev.status };
});
</script>
