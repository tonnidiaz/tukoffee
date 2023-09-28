<template>
    <ion-page id="main-content">
         
        <ion-tabs>
           
            <ion-router-outlet></ion-router-outlet>

            <ion-tab-bar class="bottom-nav" slot="bottom">
                <ion-tab-button tab="dashboard" href="/admin/dashboard">
                    <span><i class="fi fi-br-apps"></i></span>
                    <ion-label>Dashboard</ion-label>
                </ion-tab-button>

                <ion-tab-button tab="products" href="/admin/products">
                    <span><i class="fi fi-br-box-open-full"></i></span>
                    <ion-label>Products</ion-label>
                </ion-tab-button>

                <ion-tab-button tab="orders" href="/admin/orders">
                    <span><i class="fi fi-br-person-dolly"></i></span>
                    <ion-label>Orders</ion-label>
                </ion-tab-button>
                <ion-tab-button tab="accounts" href="/admin/accounts">
                    <span><i class="fi fi-br-users"></i></span>
                    <ion-label>Accounts</ion-label>
                </ion-tab-button>
               
            </ion-tab-bar>
        </ion-tabs>
    </ion-page>
</template>

<script setup lang="ts">
import {
    IonTabBar,
    IonTabButton,
    IonTabs,
    IonLabel,
    IonSpinner,
    IonPage,
    IonRouterOutlet,
} from "@ionic/vue";
import {useDashStore} from '@/stores/dash';
import { apiAxios } from "@/utils/constants";
import { onMounted } from "vue";
const dashStore = useDashStore()

const setupDash = async () => { 
    try {
        const res = await apiAxios.get('/admin/dash')
        const { data }= res
        dashStore.setProducts(data.products)
        dashStore.setOrders(data.orders)
        dashStore.setAccounts(data.customers)
    } catch (e) {
        console.log(e)
    }
 }
 onMounted(()=>{
    console.log('setting up dash')
    setupDash()
 })
</script>
<style lang="scss">

</style>
