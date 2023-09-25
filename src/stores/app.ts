import { defineStore } from "pinia";

export const useAppStore = defineStore("app", {
    state: ()=> ({
        title: "TuKoffee",

    }),
actions: {
    setTitle(val: string){
        this.title = val;
    }
}
})