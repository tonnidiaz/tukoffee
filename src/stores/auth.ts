import { Obj } from "@/utils/classes";
import { defineStore } from "pinia";

export const useAuthStore = defineStore('auth', {
    state: ()=>({
        form: { phone: "0726013383",
        password: "Baseline",
        first_name: "Larry",
        last_name: "Boseman",} as Obj,
        step: 0
    })
})