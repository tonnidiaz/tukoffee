<template>
    <div class="form-field flex justify-between items-center bg-base-100">
        <div class="field-icon prefix-icon text-gray-700"><i class="fs-18 fi fi-rr-search"></i></div>
        <ion-input color="clear" placeholder="Search"></ion-input>
        <div class="field-icon suffix-icon text-gray-700"><i class="fs-18 fi fi-rr-trash"></i></div>
    </div>
</template>
<script setup lang="ts">
import {IonInput} from '@ionic/vue';
</script>
<style lang="scss">
.form-field{
    border: 1.3px solid rgba(77, 77, 77, 0.555);
    border-radius: 10px;
    padding: 0;
    position: relative;
    height: 45px;
    input{
        padding: 1px !important;
    }
    .field-icon{
        padding: .5rem;
        padding-top: .75rem;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        
    }

    .suffix-icon{
        border-top-right-radius: inherit;
        border-bottom-right-radius: inherit;
    }
    .prefix-icon{
        border-top-left-radius: inherit;
        border-bottom-left-radius: inherit;
    }
}
</style>