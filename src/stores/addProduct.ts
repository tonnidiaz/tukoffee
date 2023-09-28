import { Obj } from "@/utils/classes";
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
    form: {} as Obj
    }),
    actions:{
        setTempImgs (v: TypeImgs[]){this.tempImgs = v},
        setForm(v: typeof this.form){
            this.form = v;
        }
    }
})