<template>
    <ion-page>
        <Appbar title="Signup" :show-cart="false" :loading="isLoading" />
        <ion-content :fullscreen="true">
            <div class="p-3 bg-base-100 flex flex-col justify- h-full">
                <ul class="steps">
                    <li @click="()=>{if (i < step) step = i}" v-for="(el, i) in steps" :class="`step step-${step >= i ?  'success' : ''}`">{{el}}</li>
                </ul> 
                <tu-form v-if="step == 0" @submit="onFormSubmit" class="mt-3" action="#">
                    <div class="flex gap-2 my-1">
                        <tu-field
                            label="First name"
                            placeholder="e.g. John"
                            v-model="form.first_name"
                            required/>
                        <tu-field
                            label="Last name"
                            placeholder="e.g. Doe"
                            v-model="form.last_name"
                            required/>
                    </div>
                    <div class="form-control my-">
                        <tu-field
                            label="Email address:"
                            placeholder="e.g. john@gmail.com"
                            v-model="form.email"
                            required
                            type="email"
                            error-text="Invalid email address"/>
                    </div>
                    <div class="form-control my-">
                        <tu-field
                            label="Phone:"
                            placeholder="e.g. 0712345678"
                            v-model="form.phone"
                            
                            type="tel"
                            error-text="Invalid email address"/>
                    </div>
                    <div class="form-control">
                        <tu-field
                            label="Password"
                            placeholder="Enter password..."
                            v-model="form.password"
                            required
                            :type="showPass ? 'text' : 'password'"
                            :color="
                                form.password == null
                                    ? 'dark'
                                    : form.password?.length > 6
                                    ? 'success'
                                    : 'danger'
                            "
                            error-text="Invalid password"/>

                        <ion-checkbox
                            v-model="showPass"
                            class="my-2"
                            mode="md"
                            label-placement="end"
                            justify="start"
                            >Show password?</ion-checkbox
                        >
                    </div>
                    <div class="form-control mt-2">
                        <tu-button
                            type="submit"
                            class="tu"
                            :ionic="true"
                            color="dark"
                        >
                            Sign up
                        </tu-button>
                    </div>
                    <div class="fs-18 flex items-center gap-2">
                        <span>Already have an account?</span
                        ><ion-text @click="$router.replace('/auth/signup')" color="primary"
                            >Login</ion-text
                        >
                    </div>
                </tu-form>
               <Step2 v-else/>
        

            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonInput,
    IonCheckbox,
    IonText,
    useIonRouter,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";

import { ref } from "vue";
import { apiAxios } from "@/utils/constants";
import { useUserStore } from "@/stores/user";
import { errorHandler, showLoading } from "@/utils/funcs";
import TuButton from "@/components/TuButton.vue";
import Step2 from "./signup/Step2.vue"
import { useAuthStore } from "@/stores/auth";
import { storeToRefs } from "pinia";

const authStore = useAuthStore()

const {form, step} = storeToRefs(authStore)

const steps = ['Register', 'Verify number']
const isLoading = ref(false), setIsLoading = (v: boolean) => isLoading.value = v;
const toastClass = ref(""),
    showPass = ref(false); 
const userStore = useUserStore();

const phoneValid = (phone: string | null) => {
    return !phone
        ? null
        : (phone.startsWith("0") && phone.length == 10) ||
              (phone.startsWith("+") && phone.length == 12);
};
const router = useIonRouter();


async function onFormSubmit(e: any) {
    
    e.preventDefault();
    setIsLoading(true)
    try {
        const _form = form.value;
        const fd = new FormData();
        for (let key of Object.keys(_form)) {
            fd.append(key, _form[key]);
        }

        await apiAxios.post("/auth/signup", fd);
        setIsLoading(false)
        step.value = 1
   
    } catch (e: any) {
        console.log(e);
        setIsLoading(false)
        errorHandler(e);
        return;
    }
}

</script>

<style>
ion-button.tu {
    box-shadow: none !important;
    --box-shadow: 0 1px 1px 2px rgba(185, 185, 185, 0.192) !important;
}
input:-internal-autofill-selected {
    background: red !important;
}
</style>
