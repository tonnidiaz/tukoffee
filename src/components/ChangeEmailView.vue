<template>
    <div class="bg-base-100 p-3">
        <div v-if="step == 0">
            <h3 class="fs-18 my-4">Change email address</h3>
            <div class="mt-2">
                <tu-form @submit="submitEmail">
                    <div class="my-2">
                        <tu-field
                            v-model="form.email"
                            required
                            name="email"
                            auto="off"
                            type="email"
                            label="New email:"
                            placeholder="Enter your new email..."
                        />
                    </div>
                    <div class="my-2">
                        <tu-field
                            v-model="form.password"
                            required
                            type="password"
                            label="Your password:"
                            placeholder="Enter your current password..."
                        />
                    </div>
                    <div class="my-2 flex justify-end">
                        <tu-btn type="submit" class="w-150px" expand="compact"
                            >Next</tu-btn
                        >
                    </div>
                </tu-form>
            </div>
        </div>
        <div v-else>
            <h3 class="fs-18 my-4">Change email address</h3>
            <div class="mt-2">
                <p class="text-center">Enter the 4-digit PIN sent to: <span class="text-gray-800 underline"> {{ form.email }}</span></p>
                <tu-form @submit="verifyOTP">
                    <div class="my-2">
                        <tu-field
                        @ion-input="onOTPInput"
                            v-model="form.otp"
                            required
                            type="number"
                            label="One-Time-PIN:"
                            placeholder="Enter 4-digit PIN..."
                        />
                    </div>
                    <div class="my-1=2">
                        <tu-btn type="submit"   
                            >Verify</tu-btn
                        >
                    </div>
                    
                    <div class="flex w-full justify-center">
                        <p class="m-auto text-center" v-if="timer > 0">
                            Resend code in {{ timer }}
                        </p>
                        <tu-btn
                            color="warning"
                            fill="clear"
                            size="small"
                            ionic
                            class="m-auto text-center"
                            @click="resendCode"
                            v-else
                            >Resend code</tu-btn
                        >
                    </div>
                </tu-form>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useUserStore } from "@/stores/user";
import { Obj } from "@/utils/classes";
import { ref } from "vue";
import { apiAxios } from "@/utils/constants";
import { errorHandler } from "@/utils/funcs";

const userStore = useUserStore();
const { user } = storeToRefs(userStore);
const TIMEOUT = 120;
const timer = ref(TIMEOUT);
const form = ref<Obj>({}),
    step = ref(0);


const verifyOTP = async (e: any) => {
    const _form = form.value;
    try {
        const res = await apiAxios.post("/auth/otp/verify", {
            otp: _form.otp,
            new_email: _form.email,
        });
        console.log(res.data);
        localStorage.setItem("authToken", res.data.token);
        location.reload()
    } catch (e: any) {
        console.log(e);
        errorHandler(e);
        return;
    }
};


const submitEmail = async () => { 
try {
    const res = await apiAxios.post('/user/edit?field=email', {
        data: form.value
    })
    step.value++
} catch (err) {
    errorHandler(err)
}
    
 }

const onOTPInput = (e: any) => {
    const otp = e.target.value;
    if (otp?.length >= 4) {
        e.target.value = otp.slice(0, 4);
    }
    form.value.otp = e.target.value;
};

const resendCode = async () => {
    const _form = form.value;
    try {
        await apiAxios.post("/auth/otp/resend", { phone: _form.phone });
        initTimer();
    } catch (e) {
        errorHandler(e);
    }
};
const initTimer = () => {
    console.log("INit timer");
    timer.value = TIMEOUT;
    const timerInterval = setInterval(() => {
        if (timer.value <= 0) {
            clearInterval(timerInterval);
            return;
        }
        timer.value--;
    }, 1000);
};
</script>
