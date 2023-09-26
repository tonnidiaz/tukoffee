<template>
    <div
        class="form-field flex justify-between items-center bg-base-100 border-1"
    >
        <div class="field-icon prefix-icon text-gray-700">
            <slot name="prefix-icon" />
        </div>
        <ion-input
            :label="label"
            color="clear"
            v-bind="fieldProps"
            v-bind:value="value"
            @ion-input="_onChange"
        ></ion-input>
        <div class="field-icon suffix-icon text-gray-700">
            <slot name="suffix-icon" />
        </div>
    </div>
</template>
<script setup lang="ts">
import { IonInput } from "@ionic/vue";

const props = defineProps({
    label: String,
    value: String,
    onChange: {
        type: Function,
    },
    fieldProps: {
        type: Object,
        default: {},
    },
});

function _onChange(event: any) {
    if (props.onChange) props.onChange(event);
}
</script>
<style lang="scss">
.form-field {
    //border-radius: 10px;
    padding: 0;
    position: relative;
    height: 45px;
    input {
        padding: 1px !important;
    }
    .field-icon {
        /**/
        .cont{
             padding: 0.5rem 0.7rem;
        padding-top: 0.75rem; 
        }
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: rgba(44, 44, 44, 0.6);
        position: relative;
    }

    .suffix-icon {
        border-top-right-radius: inherit;
        border-bottom-right-radius: inherit;
    }
    .prefix-icon {
        border-top-left-radius: inherit;
        border-bottom-left-radius: inherit;
    }
}
</style>
