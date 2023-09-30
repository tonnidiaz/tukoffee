<template>
     <form @submit="submitOTP" action="" class="mt-3">
                    <div class="form-control">
                        <ion-input @ion-input="onOTPInput" required label-placement="floating" color="dark" label="One-Time PIN" fill="solid" type="number"></ion-input>
                    </div>
                    <div class="form-control my-2">
                        <tu-button type="submit" ionic color="dark" @click="submitOTP">Verify</tu-button>
                    </div>
                    <div class="flex w-full justify-center">
                            <p class="m-auto text-center" v-if="timer > 0">Resend code in {{ timer }}</p>
                    <tu-button color="warning" fill="clear" size="small" ionic class="m-auto text-center" @click="resendCode" v-else>Resend code</tu-button>
              
                    </div>
                  </form>
</template>

<script setup lang="ts">


import { useAuthStore } from "@/stores/auth";
import { storeToRefs } from "pinia";
import { apiAxios } from "@/utils/constants";
import { errorHandler, sleep } from "@/utils/funcs";
import { onMounted, ref } from "vue";
import TuButton from "@/components/TuButton.vue";
import { IonInput, IonText } from "@ionic/vue";

const authStore = useAuthStore()

const {form, step} = storeToRefs(authStore)
/* TODO: Timer to 60 secs */
const timer =  ref(10)

const submitOTP = async (e: any) => { 
    e.preventDefault()
    const _form = form.value
    try{
        const res = await apiAxios.post('/auth/otp/verify', {otp: _form.otp, phone: _form.phone})
        console.log(res.data)
        localStorage.setItem("authToken", res.data.token);
        location.href= '/'
    }
    catch (e: any) {
        console.log(e);
        errorHandler(e);
        return;
    }
 }
const onOTPInput = (e: any) =>{
    const otp = e.target.value
    if (otp?.length >= 4){
        console.log('greter', otp.length)
        e.target.value = otp.slice(0, 4)
    }
    form.value.otp =  e.target.value
}

const resendCode = async () =>{
    const _form = form.value;
    try{
        await apiAxios.post('/auth/otp/resend', {phone: _form.phone})
        initTimer()
    }catch(e){
        errorHandler(e)
    }
}

const initTimer = () => { 
    console.log('INit timer')
    timer.value = 10
     const timerInterval  = setInterval(()=>{
        if (timer.value <= 0){
            clearInterval(timerInterval)
            return
        }
        timer.value --
    }, 1000)
 }

onMounted(()=>{
   initTimer()
})
</script>