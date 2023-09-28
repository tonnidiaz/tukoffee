import { Obj } from "@/utils/classes";
import { defineStore } from "pinia";

export const useDashStore = defineStore("dash",{
    state: ()=>({
        products: null as Obj[] | null,
        orders: null as Obj[] | null,
        accounts: null as Obj[] | null,
    }),
    actions:{
        setProducts(val: typeof this.products){
            this.products = val
        },
        setOrders(val: typeof this.orders){
            this.orders = val
        },
        setAccounts(val: typeof this.accounts){
            this.accounts = val
        },
    }
})