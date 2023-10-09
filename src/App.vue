<template>
    <ion-app
        ><ion-loading
            class="tu"
            :is-open="isLoading"
            @did-dismiss="
                setIsLoading(false);
                setLoadingMsg('Please wait...');
            "
            :message="loadingMsg"
        />
        <div v-if="isConnected == null" style="background-color: white;" class="w-full h-full flex flex-col items-center gap-3 justify-center">
            <ion-img class="w-100px" src="/splash.png"></ion-img>
            <h1 style="font-size: 2.5em;" class="fw-8" >TuKoffee</h1>
        </div>
        <div v-else-if="!isConnected" class="w-full h-full flex flex-col items-center gap-0 justify-center">
                <h3 class="fw-6 fs-14">OFFLINE</h3>
                <tu-btn :on-click="checkInternet" fill="outline">Refresh</tu-btn>
        </div>
        <div v-else class="w-full h-full flex flex-col items-center gap-3 justify-center">
             <div v-if="userSetup">
            <updates-view />
            <ion-router-outlet> </ion-router-outlet>
        </div>

        <div v-else style="background-color: white;" class="w-full h-full flex flex-col items-center gap-3 justify-center">
            <ion-img class="w-100px" src="/splash.png"></ion-img>
            <h1 style="font-size: 2.5em;" class="fw-8" >TuKoffee</h1>
        </div>
        </div>
       
    </ion-app>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet, IonLoading, IonImg, useBackButton } from "@ionic/vue";
import { apiAxios } from "./utils/constants";
import { onMounted, ref, watch } from "vue";
import { useUserStore } from "./stores/user";
import { storeToRefs } from "pinia";
import { hideLoader, onBack, setupCart, showLoading, sleep } from "./utils/funcs";
import { useStoreStore } from "./stores/store";
import { useAppStore } from "./stores/app";
import { useRoute, useRouter } from "vue-router";
import { useFormStore } from "./stores/form";
import UpdatesView from "./components/UpdatesView.vue";
import { Network } from '@capacitor/network';

const userStore = useUserStore();
const storeStore = useStoreStore();

const { userSetup } = storeToRefs(userStore);
const appStore = useAppStore();
const { isLoading, loadingMsg } = storeToRefs(appStore);
const { setIsLoading, setLoadingMsg } = appStore;
const formStore = useFormStore();
const isConnected = ref<boolean | null>()
const route = useRoute();
const router = useRouter();
const setupUser = async () => {
    userStore.setUserSetup(false);
    try {
        console.log("Setting up cart...");
        const authToken = localStorage.getItem("authToken");
        if (authToken) {
            const res = await apiAxios.post(`/auth/login`);
            userStore.setUser(res.data.user);
            setupCart(res.data.user["_id"], userStore);
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

const setupStore = async () => {
    try {
        const res = await apiAxios.get("/store");
        const { data } = res;
        storeStore.setStore(data.store);
        storeStore.setOwner(data.owner);
        storeStore.setDeveloper(data.developer);
    } catch (e) {
        console.log(e);
    }
};
watch(route, (val) => {
    appStore.setSelectedItems([]);
});
async function checkInternet(load: boolean = true){
    isConnected.value = null
    load && showLoading({
        msg: 'Checking connection...'
    })
    const status = await Network.getStatus();
    isConnected.value = status.connected
   await sleep(500)
   load && hideLoader()
}


const initBackListener = ()=>{
        useBackButton(10, () => {
            const { path } = route
            onBack(path, router)
    }); 
}
onMounted(() => {
    checkInternet(false)
   initBackListener()
 
});
watch(isConnected, val=>{
    if (val){
        setupUser();
    setupStore();
    getStores();
    }
}, {deep: true})
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


.button-native {
    padding: 0 !important;
}

.h-full {
    overflow-y: scroll;
}
ion-alert,
ion-select,
.item-radio-checked.sc-ion-select-popover-md {
    --ion-color-primary: rgba(42, 42, 42, 0.5);
    --ion-color-primary-rgb: 42 42 42;
}

ion-toolbar{
    --ion-toolbar-background: hsl(var(--b1));
    //border-bottom: 1px solid rgb(156 163 175 /.2);
}
ion-tab-bar {
    bottom: 0px;
    position: relative;
    //border-radius: 16px;
    width: 100%;
    margin: 0 auto;
   // border-top: 1px solid rgba(0, 0, 0, 0.178);
    padding: 0.2rem 0;
    //background-color: black;
    i {
        font-size: 20px !important;
        line-height: .8rem !important;
    }
    ion-label{
        font-size: 12px;
        font-weight: 600;
    }
  
}

ion-tab-button {
     --padding-start: 0;
    --padding-end: 0;
    --color: var(--surface-600);
    --color-selected: hsl(
        var(--bc)
    ); // hsl(var(--p) / var(--tw-bg-opacity))//var(--primary-color);
    /* rgb(255, 145,0);/ */
    &::before {
        background-color: transparent;
        display: block;
        content: "";
        margin: 0 auto;
        width: 20px;
        height: 2px;
    }


    &.tab-selected::before {
        width: 30px;
    }
    ion-icon {
        font-size: 20px;
    }
    &.tab-selected {
        color: var(--ion-color-primary);
        
        
    }
}


table {
            border-spacing: 0px;
            table-layout: fixed;
       //     margin-left: auto;
            margin-right: auto;
        }
tr td:nth-child(2) {
    text-align: end;
    white-space: wrap;
    word-wrap: break-word;
    user-select: text;
}
th,
th h3 {
    font-size: 18px;
}
.selectable{
    user-select: text;
}
input:-webkit-autofill,
input:-webkit-autofill:hover,
input:-webkit-autofill:focus input:-webkit-autofill,
textarea:-webkit-autofill,
textarea:-webkit-autofill:hover textarea:-webkit-autofill:focus,
select:-webkit-autofill,
select:-webkit-autofill:hover,
select:-webkit-autofill:focus {
    border: none !important;
    -webkit-text-fill-color: inherit !important;

    -webkit-box-shadow: 0 0px 0px 1000px var(--background) inset;
    transition: background-color 5000s ease-in-out 0s;
}

ion-avatar {
    display: flex;
    justify-content: center;
    align-items: center;
}
</style>
