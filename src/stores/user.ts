import { defineStore } from "pinia";

export const useUserStore = defineStore("user", {
    state: ()=> ({
        user: null as {[key:string]: any} | null,
        cart: null as {[key:string]: any} | null,

    }),
actions: {
    setUser(val: typeof this.user){
        this.user = val;
    },
    setCart(val: typeof this.cart){
        this.cart = val;
    },
}
})