<template>
    <div class="mt-2 p-3">
        <h3>Login / Signup</h3>
        <form @submit="onFormSubmit" class="mt-3" action="#">
            <div class="form-control">
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
                            ? 'primary'
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
                    fill="solid"
                    v-model="form.password"
                    required
                    class="ion-invalid"
                    :color="
                        form.password == null
                            ? 'primary'
                            : form.password?.length > 6
                            ? 'success'
                            : 'danger'
                    "
                    type="password"
                    error-text="Invalid password"
                >
                </ion-input>
                <p class="helper-text">Minimum of <code>6</code> characters.</p>
            </div>
            <div class="form-control mt-2">
                <tu-button :on-click="onFormSubmit" class="btn btn-md btn-primary">
                    Next
                </tu-button>
            </div>
        </form>
        <ion-toast :class="toastClass" @did-dismiss="()=>{setToastOpen(false); toastClass = ''}" :is-open="toastOpen" :duration="2000" :message="toastMsg" />
    </div>
</template>
<script setup lang="ts">
import { IonToast, IonInput, useIonRouter } from "@ionic/vue";
import { ref } from "vue";
import { apiAxios } from "@/utils/constants";
import { useUserStore } from "@/stores/user";
import { setupCart } from "@/utils/funcs";
import TuButton from '@/components/TuButton.vue';
const form = ref<{ [key: string]: any }>({
    phone: '0726013383',
    password: 'Baselined'
});

const toastMsg = ref(""),
    setToastMsg = (val: string) => (toastMsg.value = val),
    toastOpen = ref(false),
    setToastOpen = (val: boolean) => (toastOpen.value = val);

const toastClass = ref("")
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
    try {
        const _form = form.value;
        const fd = new FormData();
        for (let key of Object.keys(_form)) {
            fd.append(key, _form[key]);
        }

        const res = await apiAxios.post("/auth/login", fd);
        console.log(res.data);
        localStorage.setItem("authToken", res.data.token);
        userStore.setUser(res.data.user);
        setupCart(res.data.user["phone"], userStore);
        location.reload()
    } catch (e: any) {
        
        toastClass.value = "danger"
        const msg = e.response?.data ?? "Something went wrong"

        setToastMsg(msg.replace('tuned:', ''))
        setToastOpen(true)
    }
}
</script>

<style lang="scss">

</style>