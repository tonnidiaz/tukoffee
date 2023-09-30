<template>
    <ion-page>
        <Appbar title="Signup" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div class="p-3 bg-base-100 flex flex-col justify- h-full">
                <ul class="steps">
                    <li @click="()=>{if (i < step) step = i}" v-for="(el, i) in steps" :class="`step step-${step >= i ?  'success' : ''}`">{{el}}</li>
                </ul> 
                <form v-if="step == 0" @submit="onFormSubmit" class="mt-3" action="#">
                    <div class="flex gap-2 my-1">
                        <ion-input
                            label="First name"
                            placeholder="e.g. John"
                            label-placement="floating"
                            fill="solid"
                            v-model="form.first_name"
                            required
                            color="dark"
                        >
                        </ion-input>
                        <ion-input
                            label="Last name"
                            placeholder="e.g. Doe"
                            label-placement="floating"
                            fill="solid"
                            v-model="form.last_name"
                            required
                            color="dark"
                        >
                        </ion-input>
                    </div>
                    <div class="form-control my-">
                        <ion-input
                            label="Phone"
                            placeholder="e.g. 0723456789"
                            label-placement="floating"
                            fill="solid"
                            v-model="form.phone"
                            required
                            class="ion-invalid"
                            :color="
                                phoneValid(form.phone) == null
                                    ? 'dark'
                                    : phoneValid(form.phone)
                                    ? 'success'
                                    : 'danger'
                            "
                            type="tel"
                            error-text="Invalid phone number"
                        >
                        </ion-input>
                    </div>
                    <div class="form-control">
                        <ion-input
                            label="Password"
                            placeholder="Enter password..."
                            label-placement="floating"
                            v-model="form.password"
                            required
                            fill="solid"
                            :type="showPass ? 'text' : 'password'"
                            :clear-on-edit="false"
                            :color="
                                form.password == null
                                    ? 'dark'
                                    : form.password?.length > 6
                                    ? 'success'
                                    : 'danger'
                            "
                            error-text="Invalid password"
                        >
                        </ion-input>

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
                            @click="onFormSubmit"
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
                </form>
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
import { errorHandler } from "@/utils/funcs";
import TuButton from "@/components/TuButton.vue";
import Step2 from "./signup/Step2.vue"
import { useAuthStore } from "@/stores/auth";
import { storeToRefs } from "pinia";

const authStore = useAuthStore()

const {form, step} = storeToRefs(authStore)

const steps = ['Register', 'Verify number']

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
    console.log("Submi");
    e.preventDefault();
    try {
        const _form = form.value;
        const fd = new FormData();
        for (let key of Object.keys(_form)) {
            fd.append(key, _form[key]);
        }

        await apiAxios.post("/auth/signup", fd);
        step.value = 1
   
    } catch (e: any) {
        console.log(e);
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
