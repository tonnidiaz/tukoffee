<template>
    <icon-btn v-if="hasSlot" @click="openPopover">
        <ion-icon :md="ellipsisVertical"></ion-icon>
        <ion-popover
            size="auto"
            :isOpen="isOpen"
            :event="event"
            @didDismiss="isOpen = false"
        >
            <ion-content class="bg-base-100">
                <slot />
            </ion-content>
        </ion-popover>
    </icon-btn>
    <button
        v-else-if="items.filter((it) => it == null).length != items.length"
        @click="
            (e) => {
                if (items.length) openPopover(e);
            }
        "
        class="btn btn-ghost rounded-lg p-0 w-30px h-30px fs-20"
    >
        <ion-icon :md="ellipsisVertical"></ion-icon>
        <ion-popover
            size="auto"
            :isOpen="isOpen"
            :event="event"
            @didDismiss="isOpen = false"
        >
            <ion-content class="bg-base-100">
                <ul class="tu-menu">
                    <li
                        v-for="(item, i) in items.filter((it) => it != null)"
                        :id="item?.id"
                        @click="
                            async () => {
                                isOpen = false;
                                if (item?.cmd) {
                                    await sleep(100);
                                    item!.cmd();
                                }
                            }
                        "
                        class="item ion-activatable"
                    >
                        <ion-ripple-effect />
                        {{ item!.label }}
                    </li>
                </ul>
            </ion-content>
        </ion-popover>
    </button>
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
import { defineComponent, onMounted, ref, watch } from "vue";

const isOpen = ref(false),
    event = ref<Event>();

interface DropdownItem {
    label: string;
    cmd?: Function;
    id?: string;
}

const props = defineProps({
    items: {
        type: Array<DropdownItem | null>,
        default: [],
    },
    hasSlot: Boolean,
});
const openPopover = (e: any) => {
    e.preventDefault();
    event.value = e;
    isOpen.value = true;
    return false;
};

defineComponent({
    name: "DropdownBtn",
});
onMounted(() => {});
</script>

<style lang="scss">
.tu-menu {
    .item {
        //background-color: red !important;
        padding: 10px 14px;
        position: relative;
    }
}

ion-popover {
    --ion-backdrop-color: rgba(30, 30, 30, 0.3);
}
</style>
