<template>
    <ion-app
        ><ion-loading class="tu" :is-open="isLoading" @did-dismiss="setIsLoading(false); setLoadingMsg('Please wait...')" :message="loadingMsg"/>
        <ion-router-outlet v-if="userSetup"> </ion-router-outlet>

        <div v-else class="w-full h-full flex items-center justify-center">
            <h1 class="fs-30 fw-7">Loading</h1>
        </div>
    </ion-app>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet, IonLoading, useBackButton } from "@ionic/vue";
import { apiAxios } from "./utils/constants";
import { onBeforeMount, onMounted, ref, watch } from "vue";
import { useUserStore } from "./stores/user";
import { storeToRefs } from "pinia";
import { setupCart } from "./utils/funcs";
import { useStoreStore } from "./stores/store";
import { useAppStore } from "./stores/app";
import { useRoute } from "vue-router";
import { useFormStore } from "./stores/form";
import { apps } from "ionicons/icons";
const userStore = useUserStore();
const storeStore = useStoreStore();

const { userSetup } = storeToRefs(userStore);
const appStore = useAppStore()
const { isLoading, loadingMsg } = storeToRefs(appStore)
const {setIsLoading, setLoadingMsg} = appStore
const formStore = useFormStore()
const route = useRoute()
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

const setupStore = async () =>{
    try{
        const res  = await apiAxios.get('/store');
        const {data} = res
        storeStore.setStore(data.store)
        storeStore.setOwner(data.owner)
        storeStore.setDeveloper(data.developer)
    }
    catch(e){
        console.log(e)
    }
}
watch(route, val=>{
    appStore.setSelectedItems([])
})

onMounted(() => {
    setupUser();
    setupStore()
    getStores();
    /* useBackButton(10, () => {
      console.log('Handler was called!');
    }); */
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

ion-tab-button {
    --padding-start: 0;
    --padding-end: 0;
}
.button-native {
    padding: 0 !important;
}

.h-full{
    overflow-y: scroll;
}
ion-alert, ion-select, .item-radio-checked.sc-ion-select-popover-md{
    --ion-color-primary: rgba(42,42,42, .5);
--ion-color-primary-rgb: 42 42 42;
}
tr td:nth-child(2){
    text-align: end;
}
th, th h3{
    font-size: 18px;
}


input:-webkit-autofill,

input:-webkit-autofill:hover,

input:-webkit-autofill:focus

input:-webkit-autofill,

textarea:-webkit-autofill,

textarea:-webkit-autofill:hover

textarea:-webkit-autofill:focus,

select:-webkit-autofill,

select:-webkit-autofill:hover,

select:-webkit-autofill:focus {

  border:none !important;
  -webkit-text-fill-color: inherit !important;

   -webkit-box-shadow: 0 0px 0px 1000px var(--background) inset; 
  transition: background-color 5000s ease-in-out 0s;

}
</style>
