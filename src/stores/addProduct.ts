import { defineStore } from "pinia";

export interface TypeImgs {
    url?: string;
    file?: string;
    loading: boolean;
}
;

export const useAddProductStore =  defineStore('add-product',{
    state: ()=>({
    tempImgs: [] as TypeImgs[],
    }),
    actions:{
        setTempImgs (v: TypeImgs[]){this.tempImgs = v}
    }
})