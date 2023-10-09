<template>
    <ion-page>
        <Appbar title="Locations & times" :show-cart="false"> </Appbar>
        <ion-content :fullscreen="true">
            <div class="p-2">
                <ion-list class="bg-base-100">
                    <ion-item
                        v-for="el in stores"
                        color="clear"
                        class="bg-base-10"
                    >
                        <span slot="start">
                            <i class="fi fi-br-store-alt text-gray-600"></i>
                        </span>
                        <ion-label>
                            <h3 class="fs-17 fw-5">{{ el.location.name }}</h3>
                            <div class="flex items-center justify-between mt-1">
                                <ion-note class="fw-6">{{
                                    isOpen(el) ? "OPEN" : "CLOSED"
                                }}</ion-note>
                                <ion-badge
                                    color="medium"
                                    mode="ios"
                                    class="px-2 py-1"
                                >
                                    {{
                                        isOpen(el)
                                            ? `Closes at ${el.close_time.replace(':00', '')}`
                                            : `Opens at ${el.open_time.replace(':00', '')}`
                                    }}
                                </ion-badge>
                            </div>
                        </ion-label>
                    </ion-item>
                </ion-list>
            </div>
            <!-- SHEETS -->

            <BottomSheet trigger="add-loc-fab" no-swipe-dismiss>
                <div class="bg-base-100 p-4">
                    <h2 class="my-4 fs-20">Add store location</h2>
                    <tu-form @submit="onLocFormSubmit">
                        <div class="my-1">
                            <tu-field
                                id="add-loc-field"
                                label="Location:"
                                v-bind:value="locForm.location?.name"
                                :readonly='false'
                                required
                            />
                            <BottomSheet
                                trigger="add-loc-field"
                                no-swipe-dismiss
                            >
                                <div class="h-100vh">
                                    <MapView
                                        @ok="(val: Obj)=>{locForm.location = val; hideModal()}"
                                    />
                                </div>
                            </BottomSheet>
                        </div>
                        <div class="my-5">
                            <h3 class="fs-18 fw-5 text-center">Business hours</h3>
                        </div>
                        <div class="my-1">
                            <h3 class="fs-16 fw-5 my-4 text-center">Weekdays</h3>
                            

                            <div
                                class="my-2 flex items-start justify-between gap-x-2"
                            >
                                <tu-field
                                    label="Open time:"
                                    :readonly='false'
                                    required
                                    v-model="locForm.open_time"
                                    id="open-time-field"
                                />
                                <TimePicker trigger="open-time-field" @change="(val: string)=>
                                        locForm.open_time = val.split('T') .pop()"/>
                                <tu-field
                                    label="Close time:"
                                    :readonly='false'
                                    id="close-time-field"
                                    required
                                    v-model="locForm.close_time"
                                />
                                <TimePicker trigger="close-time-field" @change="(val: string)=>
                                        locForm.close_time = val.split('T') .pop()"/>
                            </div>
                        </div>
                        <div class="my-1">
                            <h3 class="fs-16 fw-5 my-4 text-center">Weekends</h3>
                            <div
                                class="my-2 flex items-start justify-between gap-x-2"
                            >
                                <tu-field
                                    label="Open time:"
                                    :readonly='false'
                                    required
                                    v-model="locForm.open_time_weekend"
                                    id="weekend-open-time-field"
                                />
                                <TimePicker trigger="weekend-open-time-field" @change="(val: string)=>
                                        locForm.open_time_weekend = val.split('T') .pop()"/>
                                <tu-field
                                    label="Close time:"
                                    :readonly='false'
                                    required
                                    v-model="locForm.close_time_weekend"
                                    id="weekend-close-time-field"
                                />
                                <TimePicker trigger="weekend-close-time-field" @change="(val: string)=>
                                        locForm.close_time_weekend = val.split('T') .pop()"/>
                            </div>
                            <div class="mt-4">
                                <tu-btn type="submit">Save</tu-btn>
                            </div>
                        </div>
                    </tu-form>
                </div>
            </BottomSheet>

            <ion-fab horizontal="end" vertical="bottom">
                <ion-fab-button color="dark" id="add-loc-fab">
                    <span><i class="fi fi-br-plus"></i></span>
                </ion-fab-button>
            </ion-fab>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonList,
    IonItem,
    IonLabel,
    IonBadge,
    IonFab,
    IonFabButton,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { useStoreStore } from "@/stores/store";
import { storeToRefs } from "pinia";
import { Obj } from "@/utils/classes";
import BottomSheet from "@/components/BottomSheet.vue";
import TimePicker from "@/components/TimePicker.vue";
import { ref } from "vue";
import { errorHandler, hideLoader, hideModal, showLoading, sleep } from "@/utils/funcs";
import MapView from "@/components/MapView.vue";
import { apiAxios } from "@/utils/constants";
const storeStore = useStoreStore();
const { store, owner, developer, stores } = storeToRefs(storeStore);

const locForm = ref<Obj>({
    location: {},
});

const isOpen = (store: Obj) => {
    const now = new Date(),
        openTime = store.open_time.split(":").map((it: string) => parseInt(it)),
        closeTime = store.close_time
            .split(":")
            .map((it: string) => parseInt(it));

    const h = now.getHours(),
        m = now.getMinutes();
    let _isOpen = false;
    if (h >= openTime[0] && m >= openTime[1] && h <= closeTime[0]) {
        _isOpen =
            h < closeTime[0] ? true : h == closeTime[0] && m <= closeTime[1];
    } else {
        _isOpen = false;
    }
    return _isOpen;
};

const onLocFormSubmit = async () => {
    try {
        showLoading({msg: 'Adding store...'})
        const res = await apiAxios.post('/stores/add', locForm.value)
        storeStore.setStores(res.data.stores)
        hideLoader()
        hideModal()
    } catch (err) {
        hideLoader()
        errorHandler(err, 'Failed to add store')
        
    }
};
</script>
