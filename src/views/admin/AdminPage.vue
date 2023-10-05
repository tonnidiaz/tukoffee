<template>
    <ion-page id="main-content">
         
        <ion-tabs>
           
            <ion-router-outlet></ion-router-outlet>

            <ion-tab-bar class="bottom-nav" slot="bottom">
              
                <ion-tab-button tab="dashboard" href="/admin/dashboard">
                    <span><i class="fi fi-sr-apps"></i></span>
                    <ion-label>Dashboard</ion-label>
                </ion-tab-button>

                <ion-tab-button tab="products" href="/admin/products">
                    <span><i class="fi fi-sr-box-open-full"></i></span>
                    <ion-label>Products</ion-label>
                </ion-tab-button>

                <ion-tab-button tab="orders" href="/admin/orders">
                    <span><i class="fi fi-sr-person-dolly"></i></span>
                    <ion-label>Orders</ion-label>
                </ion-tab-button>
                <ion-tab-button tab="accounts" href="/admin/accounts">
                    <span><i class="fi fi-sr-users"></i></span>
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

</script>
<style lang="scss">

</style>
