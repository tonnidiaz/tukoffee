import { defineStore } from "pinia";

export const useOrderStore = defineStore('order', {
    state: ()=>({
        orders: null as any[] | null,
        sortedOrders:  null as any[] | null,
    }),

    actions: {
        setOrders(val: typeof this.orders){
            this.orders = val;
        },
        setSortedOrders(val: typeof this.sortedOrders){
            this.sortedOrders = val;
        },
    
    }
})