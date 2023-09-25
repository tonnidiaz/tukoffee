import { defineStore } from "pinia";

export const useStore = defineStore("store", {
    state: ()=> ({
        title: "TuKoffee",

    }),
actions: {
    setTitle(val: string){
        this.title = val;
    }
}
})