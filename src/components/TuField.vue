<template>
    <ion-textarea
        v-if="textarea"
        label-placement="floating"
        fill="solid"
        color="dark"
        autocapitalize="words"
        :required="required"
    />
    <ion-input
        v-else
        :autocomplete="(auto as any)"
        label-placement="floating"
        fill="solid"
        color="dark"
        autocapitalize="words"
        :clear-on-edit="false"
        :required="required"
        :error-text="errorTxt"
        @ion-blur="onBlur"
        @ion-input="onInput"
       
    />
</template>
<script setup lang="ts">
import { IonInput, IonTextarea } from "@ionic/vue";
import { ref } from "vue";
const errorTxt = ref<string>();
const props = defineProps({
    textarea: Boolean,
    auto: String,
    validator: Function,
    required: Boolean
});

function onInput(e: any) {
    const val = e.target.value
    e.target.classList.add('ion-touched')
   validate(e, val)
}

function validate(e: any, val: any){

    if (props.validator) {
        const ret = props.validator(val);
        if (ret) {
            e.target.classList.remove("ion-valid");
            e.target.classList.add("ion-invalid");
            errorTxt.value = ret;
        } else {
            e.target.classList.remove("ion-invalid");
            errorTxt.value = undefined
        }
    }
    else if (props.required){
        if (!val?.length){
            e.target.classList.remove("ion-valid");
            e.target.classList.add("ion-invalid");
            errorTxt.value = 'Field is required';
        }
        else{
            e.target.classList.remove("ion-invalid");
            errorTxt.value = undefined
        }
    }
}
function onBlur(e: any){
    
    validate(e, e.target.value)
    console.log('blur')
}
</script>
