import { Obj } from "@/utils/classes";
import { defineStore } from "pinia";


export const useStoreStore = defineStore("store", {
    state: ()=> ({
        title: "TuKoffee",
        store: null as Obj  | null,
        owner: null as Obj | null,
        developer: null as Obj | null,
        stores: [] as Obj[]
    }),
actions: {
    setTitle(val: string){
        this.title = val;
    },
    setStore(val: typeof this.store){
        this.store = val;
    },
    setStores(val: typeof this.stores){
        this.stores = val;
    },
    setDeveloper(val: typeof this.developer){
        this.developer = val;
    },
    setOwner(val: typeof this.owner){
        this.owner = val;
    },
}
})