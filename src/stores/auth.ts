import { Obj } from "@/utils/classes";
import { defineStore } from "pinia";

export const useAuthStore = defineStore('auth', {
    state: ()=>({
        form: { phone: "",
        password: "",
        first_name: "",
        last_name: "",} as Obj,
        step: 0
    })
})