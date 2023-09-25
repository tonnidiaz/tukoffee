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

        <ion-tab-button tab="tab3" href="/tabs/tab3">
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
import { IonTabBar, IonTabButton, IonTabs, IonLabel, IonIcon, IonPage, IonRouterOutlet, IonTitle, IonMenu, IonToolbar, IonHeader, IonContent } from '@ionic/vue';
import { cart, ellipse, home, person, square, storefront, triangle } from 'ionicons/icons';
</script>
<style lang="scss">

ion-tab-bar {
  bottom: 20px;
  position: relative;
  border-radius: 16px;
  width: 92%;
  margin: 0 auto;
  //background-color: black;
}

ion-tab-button {
--color: var(--surface-600);
  --color-selected:var(--primary-color);
/* rgb(255, 145,0);/ */
  &::before {
    background-color: transparent;
    display: block;
    content: "";
    margin: 0 auto;
    width: 20px;
    height: 2px;
  }
  background-color: var(--surface-a);

  &.tab-selected::before {
    background-color: var(--ion-color-primary);
    width: 30px;
    
  }
  ion-icon{
    font-size: 20px;
  }
  &.tab-selected{
    transform: scale(1.2);
  }
}
</style>