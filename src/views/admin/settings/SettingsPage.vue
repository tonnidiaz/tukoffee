<template>
    <ion-page>
        <Appbar title="Settings" :show-cart="false">
            <DropdownBtn
                :items="[{ label: 'Back to home', cmd: () => toHome() }]"
            />
        </Appbar>
        <ion-content :fullscreen="true">
    
            <div class="px-2">
                <IonItemGroup class="my-1 bg-base-100 rounded-lg">
                    <ion-item :button="true"  mode="ios"
                        class=""
                        disabled
                        color="clear"
                        router-link="/_admin/settings/details"
                    >
                        <ion-label>Store details</ion-label>
                    </ion-item>
                    <ion-item :button="true"  mode="ios"
                        class=""
                        color="clear"
                        router-link="/_admin/settings/locations"
                        lines="none"
                    >
                        <ion-label>Locations & times</ion-label>
                    </ion-item>
                   
                </IonItemGroup></div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonContent, IonItemGroup, IonItem, IonLabel } from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { toHome } from "@/utils/funcs";

import { useDashStore } from "@/stores/dash";
import { apiAxios } from "@/utils/constants";
import { onMounted, ref } from "vue";
import { storeToRefs } from "pinia";
import { Obj } from "@/utils/classes";

</script>
