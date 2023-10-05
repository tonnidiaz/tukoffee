<template>
    <tu-form :on-submit="onFormSubmit">
        <div class="my-1">
            <tu-field
                label="New password:"
                v-model="form.p1"
                type="password"
                placeholder="Enter new password..."
                :validator="() => passValidator(form.p1)"
                required
            />
           
        </div>
        <div class="my-1">
            <tu-field
                label="Confirm password:"
                v-model="form.password"
                type="password"
                placeholder="Enter new password..."
                :validator="
                    () =>
                        form.password != form.p1
                            ? 'Passwords do not match'
                            : null
                "
                required
            />
        </div>
        <div class="mt-2">
            <tu-btn type="submit">Submit</tu-btn>
        </div>
    </tu-form>
</template>
<script setup lang="ts">
import router from "@/router";
import { useAuthStore } from "@/stores/auth";
import { Obj } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { errorHandler, passValidator } from "@/utils/funcs";
import { storeToRefs } from "pinia";
import { onMounted, ref } from "vue";

const {form} = storeToRefs(useAuthStore())

const onFormSubmit = async ()=>{
    try{
        const _form  = form.value
       await apiAxios.post('/auth/password/reset?act=reset', {
            phone: _form.phone,
            password: _form.password
        })
        router.replace('/auth/login')
    }
    catch(e){
        errorHandler(e, 'Failed to create new password')
    }
}

onMounted(()=>{
    form.value.password = null,
    form.value.p1 = null
})
</script>
