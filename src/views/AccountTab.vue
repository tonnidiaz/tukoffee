<template>
    <ion-page>
        <appbar
            v-if="userStore.user?.phone"
            :title="
                userStore.user?.first_name + ' ' + userStore.user?.last_name
            "
        />
        <appbar  v-else title="Account" />
        <ion-content :fullscreen="true">
            <div class="px-1">
                <IonItemGroup class="mb-1 bg-base-100">
                    <ion-item
                        class=""
                        color="clear"
                        router-link="/account/profile"
                    >
                        <ion-label>Profile</ion-label>
                    </ion-item>
                    <ion-item class="" color="clear" router-link="/cart">
                        <ion-label>Cart</ion-label>
                    </ion-item>
                    <ion-item
                        class=""
                        color="clear"
                        router-link="/orders"
                    >
                        <ion-label>Orders</ion-label>
                    </ion-item>
                    <ion-item
                        class=""
                        color="clear"
                        lines="none"
                        router-link="/store/info"
                    >
                        <ion-label>Store details</ion-label>
                    </ion-item>
                </IonItemGroup>
                <IonItemGroup
                    v-if="userStore.user?.permissions > 0"
                    class="mb-1 bg-base-100"
                >
                    <ion-item
                        class=""
                        color="clear"
                        router-link="/admin/dashboard"
                    >
                        <ion-label>Admin dashboard</ion-label>
                    </ion-item>
                    <ion-item
                        class=""
                        color="clear"
                        router-link="/rf"
                        lines="none"
                        v-if="__DEV__"
                    >
                        <ion-label>RF</ion-label>
                    </ion-item>
                </IonItemGroup>
                <IonItemGroup class="mb-1 bg-base-100">
                    <ion-item
                        class=""
                        color="clear"
                        router-link="/app/settings"
                    >
                        <ion-label>Settings</ion-label>
                    </ion-item>
                    <ion-item @click="feedbackSheetOpen = true" class="" color="clear" lines="none">
                        <ion-label>Help & Feedback</ion-label>
                        <bottom-sheet :is-open="feedbackSheetOpen" @did-dismiss="feedbackSheetOpen = false"  id="help-feedback-sheet">
                            <div class="p-4 bg-base-100">
                                <h3 class="my-4">Help & Feedback</h3>
                                <form action="">
                                    <div class="my-2">
                                        <tu-field v-model="form.name" label="Name:" placeholder="e.g. John Doe" required/>
                                    </div>
                                    <div class="my-2">
                                        <tu-field v-model="form.email" type="email" label="Email:" placeholder="Enter your email..." required/>
                                    </div>
                                    <div class="my-1">
                                        <tu-field required v-model="form.msg" label="Type your message (Issues, help, or suggestions)" textarea/>
                                    </div>
                                    <div class="my-1">
                                        <tu-btn :on-click="(e: Event) => sendMsg(e)" ionic color="dark" class="w-full tu" type="submit">Submit</tu-btn>
                                    </div>
                                </form>
                            </div>
                        </bottom-sheet>
                    </ion-item>
                </IonItemGroup>
                <div class="bg-base-100 mb-2px p-2">
                    <div v-if="!userStore.user?.phone">
                        <ion-button
                            color="dark"
                            class="text-white w-full"
                            router-link="/auth/login"
                            >Login</ion-button
                        >

                    </div>
                    <ion-button
                        v-else
                        router-link="/auth/logout"
                        color="dark"
                        class="text-white w-full"
                        >Logout</ion-button
                    >
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>

<script setup lang="ts">
import {
    IonPage,
    IonButton,
    IonItem,
    IonLabel,
    IonContent,
    IonItemGroup,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import BottomSheet from "@/components/BottomSheet.vue";
import { useUserStore } from "@/stores/user";
import { __DEV__ } from "@/utils/constants";
import { Obj } from "@/utils/classes";
import { ref } from "vue";
import axios from "axios";
import { useAppStore } from "@/stores/app";
import { errorHandler, showToast } from "@/utils/funcs";
const userStore = useUserStore();
const appStore = useAppStore()

const form = ref<Obj>({})
const feedbackSheetOpen = ref(false)


const goBack = ()=> window.history.back()
const sendMsg = async (e: Event) => {
    e.preventDefault()
    try {
        console.log(form.value)
        await axios.post('/message/send', {app: appStore.title, ...form.value})
        showToast({msg: "Feedback sent"})
        feedbackSheetOpen.value = false
    } catch (error) {
        errorHandler(error, "Failed to send feedback", true)
    }
}
</script>
<style lang="scss">

h1 {
    color: rgb(33, 33, 33);
}
</style>
