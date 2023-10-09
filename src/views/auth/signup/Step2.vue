<template>
    <tu-form @submit="submitOTP" action="" class="mt-3">
        <div class="form-control">
            <tu-field
                @ion-input="onOTPInput"
                required
                label="One-Time PIN"
                type="number"
            ></tu-field>
        </div>
        <div class="form-control my-2">
            <tu-button type="submit" color="dark"
                >Verify</tu-button
            >
        </div>
        <div class="flex w-full justify-center">
            <p class="m-auto text-center" v-if="timer > 0">
                Resend code in {{ timer }}
            </p>
            <tu-button
                color="warning"
                fill="clear"
                size="small"
                ionic
                class="m-auto text-center"
                @click="resendCode"
                v-else
                >Resend code</tu-button
            >
        </div>
    </tu-form>
</template>

<script setup lang="ts">
import { useAuthStore } from "@/stores/auth";
import { storeToRefs } from "pinia";
import { apiAxios } from "@/utils/constants";
import { errorHandler, sleep } from "@/utils/funcs";
import { onMounted, ref } from "vue";
import TuButton from "@/components/TuButton.vue";
import { IonInput, IonText } from "@ionic/vue";

const authStore = useAuthStore();

const { form, step } = storeToRefs(authStore);

const TIMEOUT = 120;
const timer = ref(TIMEOUT);

const submitOTP = async (e: any) => {
    e.preventDefault();
    const _form = form.value;
    try {
        const res = await apiAxios.post("/auth/otp/verify", {
            otp: _form.otp,
            email: _form.email,
        });
        console.log(res.data);
        localStorage.setItem("authToken", res.data.token);
        location.href = "/";
    } catch (e: any) {
        console.log(e);
        errorHandler(e);
        return;
    }
};
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
        await apiAxios.post("/auth/otp/resend", { email: _form.email });
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

onMounted(() => {
    initTimer();
});
</script>
