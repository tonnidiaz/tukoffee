import { defineStore } from "pinia";

const loadingMsg = 'Please wait...'
export const useAppStore = defineStore("app", {
    state: ()=> ({
        title: "TuKoffee",
        selectedItems: [] as any[],
        isLoading: false,
        loadingMsg: loadingMsg
    }),
actions: {
    setTitle(val: string){
        this.title = val;
    },
    setSelectedItems(val: typeof this.selectedItems){
        this.selectedItems = val
    },
    setIsLoading(val: typeof this.isLoading){
        this.isLoading = val;
        if (!val) this.loadingMsg = loadingMsg
    },
    setLoadingMsg(val: string){
        this.loadingMsg = val;
    }
}
})