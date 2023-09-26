<template>
    <ion-page>
        <appbar v-if="userStore.user?.phone" :title="userStore.user?.first_name + ' ' +  userStore.user?.last_name" />
        <appbar v-else title="Account"/>
        <ion-content :fullscreen="true">
            <div class="p-2">
            
                <IonItemGroup class="mb-1 bg-base-100">
                        <ion-item
                            class=""
                            color="clear"
                            router-link="/account/profile"
                        >
                            <ion-label>Profile</ion-label>
                        </ion-item>
                        <ion-item
                            class=""
                            color="clear"
                            router-link="/tabs/cart"
                        >
                            <ion-label>Cart</ion-label>
                        </ion-item>
                        <ion-item
                            class=""
                            lines="none"
                            color="clear"
                            router-link="/orders"
                        >
                            <ion-label>Orders</ion-label>
                        </ion-item>
                  
                    
                </IonItemGroup>
                <IonItemGroup class="mb-1 bg-base-100">
                        <ion-item
                            class=""
                            color="clear"
                            router-link="/account/settings"
                        >
                            <ion-label>Settings</ion-label>
                        </ion-item>
                        <ion-item
                            class=""
                            lines="none"
                            color="clear"
                        >
                            <ion-label>Help & Feedback</ion-label>
                        </ion-item>

                </IonItemGroup>
                <div class="bg-base-100 mb-2px p-2">
                    <div v-if="!userStore.user?.phone">
                     <ion-button id="login-modal-trigger" class=" text-white  w-full bt bt-primary">Login</ion-button>
                    <BottomSheet
                    :initial-breakpoint="0.5"
                    trigger="login-modal-trigger">

                        <LoginView/>
                    </BottomSheet>
                    </div>
                    <ion-button v-else router-link="/auth/logout" color="dark" class=" text-white  w-full">Logout</ion-button>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>

<script setup lang="ts">
import {
    IonPage,
    IonButton,
    IonToolbar,
    IonItem,
    IonLabel,
    IonInput,
    IonContent,
    IonItemGroup,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import LoginView from "@/components/LoginView.vue";
import { useUserStore } from "@/stores/user";

const userStore = useUserStore()
const reload = () => { 
    window.location.reload()
 }
</script>
<style lang="scss">
p {
    //  color: rgb(73, 80, 87);
    //font-size: 14px;
}

h1 {
    color: rgb(33, 33, 33);
}


</style>
