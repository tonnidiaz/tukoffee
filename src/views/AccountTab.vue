<template>
    <ion-page>
      <ion-header class="ion-no-border">
        <ion-toolbar>
          <ion-title>Account</ion-title>
        </ion-toolbar>
      </ion-header>
      <ion-content :fullscreen="true">
        <ion-header collapse="condense">
          <ion-toolbar>
            <ion-title size="large">Account</ion-title>
          </ion-toolbar>
        </ion-header>
  
       <div class="p-4">
        <h1>Header 1</h1>
        <h2>Header 2</h2>
        <h3>Header 3</h3>
        <h4>Header 4</h4>
        <p>Just a paragraph</p>
       </div>
      </ion-content>
    </ion-page>
  </template>
  
  <script setup lang="ts">
  import { IonPage, IonHeader, IonToolbar, IonTitle, IonContent } from '@ionic/vue';
  import ExploreContainer from '@/components/ExploreContainer.vue';
  </script>
  <style lang="scss">
p{
  //  color: rgb(73, 80, 87);
    //font-size: 14px;
}

h1{
    color: rgb(33, 33, 33);
}
</style>