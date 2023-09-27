import { defineStore } from "pinia";

export const useAppStore = defineStore("app", {
    state: ()=> ({
        title: "TuKoffee",
        selectedItems: [] as any[]
    }),
actions: {
    setTitle(val: string){
        this.title = val;
    },
    setSelectedItems(val: typeof this.selectedItems){
        this.selectedItems = val
    }
}
})