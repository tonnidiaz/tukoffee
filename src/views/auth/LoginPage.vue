<template>
    <ion-page>
        <Appbar title="Login" :show-cart="false"/> 
        <ion-content :fullscreen="true">
            <div class="p-3 bg-base-100 flex flex-col justify- h-full">
        <tu-form @submit="onFormSubmit" class="mt-3" action="#">
            <div class="my-1">
                <tu-field
                    label="Phone"
                    placeholder="e.g. 0723456789"
                    v-model="form.phone"
                    required
                    :validator="()=>{
                        return !form.phone?.length ? 'Phone is required' : (phoneValid(form.phone) == false ? 'Invalid phone number' : null)
                    }"
                    type="tel"
                    />
            </div>
            <div class="my-1">
                   <tu-field
                   
                    label="Password"
                    placeholder="Enter password..."
                    v-model="form.password"
                    required
                    :type="showPass ? 'text' : 'password'"
                    :validator="()=> passValidator(form.password)"
                >
                </tu-field>
 
                <div class="mt-1">
                    <ion-text router-link="/auth/forgot" color="secondary">Forgot password?</ion-text>
                </div>
                <ion-checkbox
                    v-model="showPass"
                    class="my-2"
                    mode="md"
                    label-placement="end"
                    justify="start"
                    >Show password?</ion-checkbox
                >
            </div>
            <div class="my-1 mt-2">
                <tu-button  type="submit" class="tu">
                    Login
                </tu-button>
            </div>
            <div class=" fs-18 flex items-center gap-2">
                <span>Or</span><ion-text router-link="/auth/signup" color="secondary">Create new account</ion-text>
            </div>
        </tu-form>
        <div class="toast toast-end hidden">
            <div class="alert alert-error">
                <span>Message sent successfully.</span>
            </div>
        </div>
        <ion-toast
            :class="toastClass"
            @did-dismiss="
                () => {
                    console.log('dismiss');
                    setToastOpen(false);
                    toastClass = '';
                }
            "
            :is-open="toastOpen"
            :duration="2000"
            :message="'toastMsg'"
        />
    </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonCheckbox,
    IonToast,
    IonText,
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';

import { ref } from "vue";
import { apiAxios } from "@/utils/constants";
import { useUserStore } from "@/stores/user";
import { errorHandler, setupCart, passValidator } from "@/utils/funcs";
import TuButton from "@/components/TuButton.vue";
import { useRoute } from "vue-router";
const form = ref<{ [key: string]: any }>({
    phone: "0726013383",
    password: "Baselined",
});

const toastMsg = ref(""),
    setToastMsg = (val: string) => (toastMsg.value = val),
    toastOpen = ref(false),
    setToastOpen = (val: boolean) => (toastOpen.value = val);

const toastClass = ref(""),
    showPass = ref(false);
const userStore = useUserStore();



const phoneValid = (phone: string | null) => {
    return !phone
        ? null
        : (phone.startsWith("0") && phone.length == 10) ||
              (phone.startsWith("+") && phone.length == 12);
};
const route = useRoute();
const { red } = route.query

async function onFormSubmit(e: any) {
    e.preventDefault();
    try {
        const _form = form.value;
        const fd = new FormData();
        for (let key of Object.keys(_form)) {
            fd.append(key, _form[key]);
        }

        const res = await apiAxios.post("/auth/login", fd);
        localStorage.setItem("authToken", res.data.token);
        userStore.setUser(res.data.user);
        setupCart(res.data.user["phone"], userStore);
        location.href = red as string ??  '/'
    } catch (e: any) {
        console.log(e);
        errorHandler(e)
        return;
    }
}


</script>

<style>
ion-button.tu{
    box-shadow: none !important;
    --box-shadow: 0 1px 1px 2px rgba(185, 185, 185, 0.192) !important;
}
input:-internal-autofill-selected {
    background: red !important;
}
</style>