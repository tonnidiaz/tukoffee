<template>
    <ion-page>
        <appbar title="Product reviews" :show-cart="false"/>
            <ion-content fullscreen>
                <div  class="flex flex-col h-full">
                <ion-segment v-model:value="tab" @ion-change="tab = $event.target.value as number" class="bg-base-100" color="dark">
                    <ion-segment-button :value="0">
                        <ion-label>Items</ion-label>
                    </ion-segment-button>
                    <ion-segment-button :value="1">
                        <ion-label>Review histroy</ion-label>
                    </ion-segment-button>
                </ion-segment>
                <div class="flex-auto">
                    <component :is="tabs[tab]"/>
                </div>
                </div>
            </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonSegment,
    IonSegmentButton,
    IonLabel,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { ref, watch } from "vue";
import ItemsTab from "./ItemsTab.vue";
import HistoryTab from "./HistoryTab.vue";

const tabs = [
    ItemsTab,
    HistoryTab
]
const tab = ref(0)

</script>
