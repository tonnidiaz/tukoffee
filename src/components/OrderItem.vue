<template>
    <OnLongPress @trigger="onLongPress" >
        <ion-item  color="clear" >
        <ion-label>
            <h3>#{{order.oid}}</h3>
            <div class="flex gap-4">
                <ion-note class="fs-13">
                    {{ new Date(order.date_created).toLocaleDateString() }}
                </ion-note>
                <span :class="'badge badge-' +( order.status == 'pending' ? 'warning' : (order.status == 'cancelled' ? 'error' : 'success'))">{{order.status}}</span>
            </div>

        </ion-label>
        <ion-checkbox @ion-change="onItemClick" :checked="selectedItems.findIndex(el => el._id == order._id) != -1" v-if="selectedItems?.length" slot="end" mode="ios"></ion-checkbox>

        <button v-else slot="end" class="btn btn-sm rounded-full btn-ghost p-0 w-24px">
            <ion-icon :md="ellipsisVertical"></ion-icon>
        </button>
    </ion-item>
    </OnLongPress>
    
</template>
<script setup lang="ts">
import { useOrderStore } from "@/stores/order";
import { useUserStore } from "@/stores/user";
import {
    IonPage,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonMenuToggle,
    IonCheckbox,
    IonIcon,
    IonItem,
    IonNote,
    IonList,
    IonLabel,
} from "@ionic/vue";
import { ellipsisVertical } from "ionicons/icons";
import { storeToRefs } from "pinia";
import { OnLongPress } from '@vueuse/components'
import { useAppStore } from "@/stores/app";
import { ref } from "vue";

const userStore = useUserStore()
const orderStore = useOrderStore()
const appStore = useAppStore()

const {user} = storeToRefs(userStore)
const {orders} = storeToRefs(orderStore)
const {selectedItems} = storeToRefs(appStore)

const isHolding = ref(false)

const props = defineProps({
    order: {
        type: Object,
        required: true
    }
})

const toggleSelected = () => { 
    const inList = selectedItems.value.find(el=>el._id == props.order._id)
    const data = inList  ? selectedItems.value.filter(el=> el._id != props.order._id) :
    [...selectedItems.value, props.order ]
    appStore.setSelectedItems(data)
    
 }
 const onItemClick = () => { 
    console.log(isHolding.value)
    if (selectedItems.value.length) toggleSelected()
  }
const onLongPress = (e: PointerEvent) => { 
    isHolding.value = true
    toggleSelected()
    isHolding.value = false
 }
</script>