<template>
    <ion-page>
        <Appbar title="Store info" :show-cart="false" />
        <ion-content :fullscreen="true">
            <ion-accordion-group class="my-1 bg-base-100 p-2" expand="compact">
                <ion-accordion>
                    <ion-item slot="header" color="light">
                        <ion-label class="fs-18">Store details</ion-label>
                    </ion-item>
                    <div class="ion-padding" slot="content">
                        <table class="table bg-base-200 br-0">
                            <th class="hidden"></th>
                            <tbody>
                                <tr>
                                    <td class="fs-17 fw-5">Name:</td>
                                    <td class="fs-17 fw-4">
                                        {{ store?.name }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Phone:</td>
                                    <td class="fs-17 fw-4">
                                        {{ store?.phone }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Email:</td>
                                    <td class="fs-17 fw-4">
                                        {{ store?.email }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Website:</td>
                                    <td class="fs-17 fw-4">
                                        {{ store?.site }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </ion-accordion>
                <ion-accordion>
                    <ion-item slot="header" color="light">
                        <ion-label class="fs-18">Owner details</ion-label>
                    </ion-item>
                    <div class="ion-padding" slot="content">
                        <table class="table bg-base-200 br-0">
                            <th class="hidden"></th>
                            <tbody>
                                <tr>
                                    <td class="fs-17 fw-5">Name:</td>
                                    <td class="fs-17 fw-4">
                                        {{ owner?.name }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Phone:</td>
                                    <td class="fs-17 fw-4">
                                        {{ owner?.phone }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Email:</td>
                                    <td class="fs-17 fw-4">
                                        {{ owner?.email }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Website:</td>
                                    <td class="fs-17 fw-4">
                                        {{ owner?.site }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </ion-accordion>
                <ion-accordion>
                    <ion-item slot="header" color="light">
                        <ion-label class="fs-18">Developer details</ion-label>
                    </ion-item>
                    <div class="ion-padding" slot="content">
                        <table class="table bg-base-200 br-0">
                            <th class="hidden"></th>
                            <tbody>
                                <tr>
                                    <td class="fs-17 fw-5">Name:</td>
                                    <td class="fs-17 fw-4">
                                        {{ developer?.name }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Phone:</td>
                                    <td class="fs-17 fw-4">
                                        {{ developer?.phone }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Email:</td>
                                    <td class="fs-17 fw-4">
                                        {{ developer?.email }}
                                    </td>
                                </tr>
                                <tr>
                                    <td class="fs-17 fw-5">Website:</td>
                                    <td class="fs-17 fw-4">
                                        {{ developer?.site }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </ion-accordion>
            </ion-accordion-group>
            <ion-accordion-group expand="compact" class="my-1 bg-base-100 p-2">
                <ion-accordion>
                    <ion-item slot="header" color="light">
                        <ion-label class="fs-18">Locations and times</ion-label>
                    </ion-item>
                    <div class="ion-padding" slot="content">
                        <ion-list>
                            <ion-item v-for="el in stores" class="bg-base-10">
                                <span slot="start">
                                    <i class="fi fi-br-store-alt text-gray-600"></i>
                                </span>
                                <ion-label>
                                    <h3 class="fs-17 fw-5">{{el.location.name}}</h3>
                                    <div
                                        class="flex items-center justify-between mt-1"
                                    >
                                        <ion-note class="fw-6">{{ isOpen(el) ? 'OPEN' :  'CLOSED' }}</ion-note>
                                        <ion-badge color="medium" mode="ios" class="px-2 py-1">
                                            {{ isOpen(el) ? `Closes at ${el.close_time}`: `Opens at ${el.open_time}`}}
                                        </ion-badge>
                                    </div>
                                </ion-label>
                            </ion-item>
                        </ion-list>
                    </div>
                </ion-accordion>
            </ion-accordion-group>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonAccordion,
    IonAccordionGroup,
    IonLabel,
    IonItem,
    IonList,
    IonNote,
    IonBadge,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { useStoreStore } from "@/stores/store";
import { storeToRefs } from "pinia";
import { onMounted } from "vue";
import { Obj } from "@/utils/classes";
const storeStore = useStoreStore();
const { store, owner, developer, stores } = storeToRefs(storeStore);


const isOpen = (store: Obj)=>{
    const now = new Date(),
    openTime = store.open_time.split(':').map((it: string)=> parseInt(it)),
    closeTime = store.close_time.split(':').map((it: string)=> parseInt(it));

    const h = now.getHours(), m = now.getMinutes()
    return (h >= openTime[0] && m >= openTime[1]) && (h < closeTime[0] && m < closeTime[1])
}
onMounted(() => {
});
</script>
