<template>
    <ion-page>
        <Appbar title="Locations & times" :show-cart="false">
         
        </Appbar>
        <ion-content :fullscreen="true">
    
            <div class="px-2">
              
            </div>
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
