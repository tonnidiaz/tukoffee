<template>
    <ion-page>
        <Appbar title="Account settings" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div v-if="user" class="h-full py-0 px-2">
                <div class="px-3 py-1 my-1 bg-base-100">
                    <div class="flex items-center justify-between">
                        <h3 class="fs-18 fw-5">Email</h3>
                        <ion-text color="secondary" id="change-email-btn">Change</ion-text>
                    </div>
                    <div class="mt-2">
                        <ion-text>
                            {{ user.email  }}</ion-text>
                    </div>
                </div>
                <div class="px-3 py-1 my-1 bg-base-100">
                    <tu-btn id="change-pass-trigger" expand="block" color="dark" ionic>
                        Change password</tu-btn
                    >
                    <!-- Change pass sheet -->
                    <bottom-sheet trigger="change-pass-trigger">
                        <div class="bg-base-100 p-3">
                            <tu-form :on-submit="changePwd">
                                <div class="my-1">
                                    <tu-field
                                    label="Old password:"
                                    placeholder="Enter your old password..."
                                    auto="off"
                                    type="password"
                                    required
                                    v-model="form.old"
                                />
                                </div>
                                <div class="my-1">
                                    <tu-field
                                    label="New password:"
                                    placeholder="Enter new password..."
                                    type="password"
                                    auto="off"
                                    required
                                    v-model="form.new"
                                />
                                </div>
                                <div class="mt-2">
                                    <tu-btn type="submit" expand="block" color="dark">Submit</tu-btn>
                                </div>
                            </tu-form>
                        </div>
                    </bottom-sheet>
                </div>
                <div class="px-3 py-1 my-1 bg-base-100">
                    <tu-btn id='del-acc-btn' expand="block" color="danger" ionic>
                        <span><i class="fi fi-sr-triangle-warning"></i></span>
                        &nbsp;Delete account</tu-btn
                    >
                    <bottom-sheet trigger="del-acc-btn">
                        <div class="bg-base-100 p-3">
                            <h3 class="my-2">
                                Confirm your password
                            </h3>
                            <tu-form :on-submit="delAccount">
                                <div class="my-1">
                                    <tu-field
                                    label="Password:"
                                    placeholder="Enter your password..."
                                    auto="off"
                                    type="password"
                                    required
                                    v-model="form.password"
                                />
                                </div>
                                <div class="mt-2">
                                    <tu-btn type="submit" >Continue</tu-btn>
                                </div>
                                </tu-form>
                            
                            </div>
                    </bottom-sheet>
                </div>
            </div>
            <!-- SHEETS -->
            <div v-if="user">
            <bottom-sheet   trigger="change-email-btn" no-swipe-dismiss>
                <ChangeEmailView/>
            </bottom-sheet>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonContent, IonText, IonRippleEffect } from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import ChangeEmailView from "@/components/ChangeEmailView.vue";
import { Obj } from "@/utils/classes";
import { ref } from "vue";
import { apiAxios } from "@/utils/constants";
import { errorHandler, hideLoader, hideModal, showAlert, showLoading } from "@/utils/funcs";
import { storeToRefs } from "pinia";
import { useUserStore } from "@/stores/user";

const userStore = useUserStore()
const { user } =  storeToRefs(userStore)
const form = ref<Obj>({})

async function changePwd(){
    try {
        showLoading({msg: 'Changing password...'})
        await apiAxios.post('/auth/password/change', form.value)
        hideLoader()
        hideModal()
        showAlert({message: 'Password changed successfully!'})
    } catch (error) {
        hideLoader()
        errorHandler(error, 'Failed to change password')
    }
}

async function delAccount(){
    showAlert({
        title: 'Delete account',
        message: 'Are you sure you want to permenently delete your account?',
        buttons: [{
            text: 'Cancel',
            role: 'cancel',
        },
        {
            text: 'Yes',
            role: 'confirm',
            handler: async ()=>{
               try{
                await apiAxios.post('/user/delete', {password: form.value.password})
                localStorage.removeItem('auth-token')
                location.href = '/'
            }
               catch(e){
                errorHandler(e, 'Failed to delete account')
               }
            }
        }
    ]
    })
}
</script>
