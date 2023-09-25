<template>
    <!--  <ion-menu side="end" content-id="main-content">
        <ion-header class="ion-no-border">
            <ion-toolbar>
                <ion-title>Menu Content</ion-title>
            </ion-toolbar>
        </ion-header>
        <ion-content iclass="ion-padding"
            >This is the menu content.</ion-content
        >
    </ion-menu> -->
    <ion-page id="main-content">
        <ion-tabs>
            <ion-router-outlet></ion-router-outlet>

            <ion-tab-bar class="bottom-nav" slot="bottom">
                <ion-tab-button tab="tab1" href="/tabs/tab1">
                    <ion-icon aria-hidden="true" :icon="home" />
                    <ion-label>Home</ion-label>
                </ion-tab-button>

                <ion-tab-button tab="shop" href="/tabs/shop">
                    <ion-icon aria-hidden="true" :icon="storefront" />
                    <ion-label>Shop</ion-label>
                </ion-tab-button>

                <ion-tab-button tab="cart" href="/tabs/cart">
                    <ion-icon aria-hidden="true" :icon="cart" />
                    <ion-label>Cart</ion-label>
                </ion-tab-button>
                <ion-tab-button tab="account" href="/tabs/account">
                    <ion-icon aria-hidden="true" :icon="person" />
                    <ion-label>Account</ion-label>
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
    IonIcon,
    IonPage,
    IonRouterOutlet,
} from "@ionic/vue";
import {
    cart,
    home,
    person,
    storefront,
} from "ionicons/icons";
</script>
<style lang="scss">

</style>
