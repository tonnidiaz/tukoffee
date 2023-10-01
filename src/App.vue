<template>
    <ion-app>
        <ion-router-outlet v-if="userSetup" />
        <div v-else class="w-full h-full flex items-center justify-center">
            <h1 class="fs-30 fw-7">Loading</h1>
        </div>
    </ion-app>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet } from "@ionic/vue";
import { apiAxios } from "./utils/constants";
import { onBeforeMount } from "vue";
import { useUserStore } from "./stores/user";
import { storeToRefs } from "pinia";
import { setupCart } from "./utils/funcs";
import { useStoreStore } from "./stores/store";
const userStore = useUserStore();
const storeStore = useStoreStore();

const { userSetup } = storeToRefs(userStore);

const setupUser = async () => {
    userStore.setUserSetup(false);
    try {
        console.log("Setting up cart...");
        const authToken = localStorage.getItem("authToken");
        if (authToken) {
            const res = await apiAxios.post(`/auth/login`);
            userStore.setUser(res.data.user);
            setupCart(res.data.user["phone"], userStore);
        } else {
            userStore.setUser({});
            userStore.setCart({});
        }
    } catch (e) {
        console.log(e);
    }
    userStore.setUserSetup(true);
};
const getStores = async () => {
    try {
        const res = await apiAxios.get("/stores");
        storeStore.setStores(res.data.stores);
    } catch (e) {
        console.log(e);
    }
};

onBeforeMount(() => {
    setupUser();
    getStores();
});
</script>
<style lang="scss">
.flex-center {
    justify-content: center !important;
    align-items: center !important;
}
ion-content {
    display: flex;
    flex-direction: column;
}

.searchbar {
    /* flex items-center px-4 h-45px gap-2 */
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0 1rem;
    gap: 0.5rem;
}

ion-loading.tu {
    --spinner-color: #0f0f0f;
    color: #0f0f0f;
}

ul.default {
    list-style-type: disc;
    li {
        margin: 0 1.6rem;
    }
}

ion-tab-button{
    --padding-start: 0;
    --padding-end: 0;
}
.button-native {
    padding: 0 !important;
}
</style>
