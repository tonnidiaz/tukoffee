<template>
    <ion-page>
        <Appbar title="Reset password" :show-cart="false" />
        <ion-content :fullscreen="true">
            <div class="p-3 bg-base-100 flex flex-col justify- h-full">
  
                <tu-form v-if="false" @submit="onFormSubmit" class="mt-3" action="#">
               
                    <div class="form-control my-">
                        <tu-field
                            label="Phone"
                            placeholder="e.g. 0723456789"
                            v-model="form.phone"
                            required                          
                            type="tel"
                        >
                        </tu-field>
                    </div>
              
                    <div class="form-control mt-2">
                        <tu-button
                            type="submit"
                            class="tu"
                            color="dark"
                        >
                           Next
                        </tu-button>
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
import { errorHandler } from "@/utils/funcs";
import TuButton from "@/components/TuButton.vue";
import Step2 from "../forgot/Step2.vue"
import { useAuthStore } from "@/stores/auth";
import { storeToRefs } from "pinia";

const authStore = useAuthStore()

const {form, step} = storeToRefs(authStore)

const onOTPInput = (e: any) => {
    const otp = e.target.value;
    if (otp?.length >= 4) {
        e.target.value = otp.slice(0, 4);
    }
    form.value.otp = e.target.value;
};


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
