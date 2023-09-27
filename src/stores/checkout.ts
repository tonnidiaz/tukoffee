import { OrderMode } from "@/utils/classes";
import { defineStore } from "pinia";

export const useCheckoutStore = defineStore("checkout", {
    state: ()=>({
        orderMode: OrderMode.collect
    }),
    actions: {
        setOrderMode(val: typeof this.orderMode){
            this.orderMode = val;
        }
    }
})