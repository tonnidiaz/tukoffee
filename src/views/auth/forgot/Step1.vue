<template>
    <tu-form @submit="onFormSubmit" class="mt-3" action="#">
               
               <div class="form-control my-">
                   <tu-field
                       label="Email address:"
                       placeholder="Enter your email..."
                       v-model="form.email"
                       required                          
                       type="email"
                   >
                   </tu-field>
               </div>
         
               <div class="form-control mt-2">
                   <tu-btn
                       type="submit"
                       class="tu"
                       color="dark"
                   >
                      Next
                   </tu-btn>
               </div>
   
           </tu-form>
</template>
<script setup lang="ts">
import { apiAxios } from "@/utils/constants";
import { errorHandler } from "@/utils/funcs";
import {
    useIonRouter,
} from "@ionic/vue";
import { storeToRefs } from "pinia";
import { useAuthStore } from "@/stores/auth";
const authStore = useAuthStore()

const {form, step} = storeToRefs(authStore)

async function onFormSubmit(e: any) {
    console.log("Submi");
    e.preventDefault();
    try {
        const _form = form.value;
        const fd = new FormData();
        for (let key of Object.keys(_form)) {
            fd.append(key, _form[key]);
        }

        await apiAxios.post("/auth/password/reset?act=gen-otp", {
            email: _form.email
        });
        step.value = 1
   
    } catch (e: any) {
        console.log(e);
        errorHandler(e);
        return;
    }
}


</script>