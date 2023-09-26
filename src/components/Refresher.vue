<template>
    <ion-refresher slot="fixed" @ion-refresh="_onRefresh">
        <ion-refresher-content />
    </ion-refresher>
</template>
<script setup lang="ts">
import { IonRefresher, IonRefresherContent } from "@ionic/vue";

const props = defineProps({
    onRefresh: Function,
});

const _onRefresh = async (e: any) => {
    if (props.onRefresh) {
        await props.onRefresh();
    }
    e.target.complete();
};
</script>
