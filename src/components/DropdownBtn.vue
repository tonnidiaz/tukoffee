<template>
 <!--    <ion-button @click="openPopover" slot="icon-only" class="clear button-clear in-toolbar" color="clear" shape="round">
        <ion-icon :md="ellipsisVertical"></ion-icon>
    </ion-button>
 -->
 <button  @click="e=> {if(items.length) openPopover(e)}" class="btn btn-ghost rounded-lg p-0 w-30px h-30px fs-20">
    <ion-icon :md="ellipsisVertical"></ion-icon>
 </button>
    <ion-popover
        size="auto"
        :isOpen="isOpen"
        :event="event"
        @didDismiss="isOpen = false"
    >
        <ion-content class="bg-base-100">
            <ul class="tu-menu">
                <li v-for="(item, i) in items.filter(it => it != null)" @click="async()=>{isOpen = false; await sleep(100); item!.cmd()}" class="item ion-activatable">
                    <ion-ripple-effect />
                    {{ item!.label }}
                </li>
  
            </ul>
        </ion-content>
    </ion-popover>
</template>
<script setup lang="ts">
import { sleep } from "@/utils/funcs";
import {
    IonPopover,
    IonContent,
    IonButton,
    IonIcon,
    IonRippleEffect,
} from "@ionic/vue";
import { ellipsisVertical } from "ionicons/icons";
import { defineComponent, ref, watch } from "vue";

const isOpen = ref(false),
    event = ref<Event>();

interface DropdownItem{
    label: string, cmd: Function
}


const props = defineProps({
    items: {
        type: Array<DropdownItem | null>,
            default: []
    }
})
const openPopover = (e: Event) => {
    console.log('Ope')
    e.preventDefault()
    event.value = e;
    isOpen.value = true;
    return false;
};

defineComponent({
    name: "DropdownBtn",
});
</script>

<style lang="scss">
.tu-menu {
    .item {
        //background-color: red !important;
        padding: 10px 14px;
        position: relative;
    }
}
</style>
