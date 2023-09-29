<template>
<paystack
                :buttonClass="btnClass"
                buttonText="Pay now"
                :publicKey="paystackPKeyDemo"
                :email="email"
                :amount="amount * 100"
                :reference="reference()"
                currency="ZAR"
                :onSuccess="onSuccess"
                :onCancel="onCancel"/>
</template>

<script setup lang="ts">
import { paystackSecretKeyDemo, paystackPKeyDemo } from "@/utils/constants";

import paystack from "vue3-paystack";
    defineProps({
        onSuccess: Function,
        onCancel: Function,
        amount: {type: Number, required: true},
        email: {type: String, required: true},
        btnClass: String

    })

    function reference() {
    let randomRef = "";
    let characters =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (let i = 0; i < 15; i++)
        randomRef += characters.charAt(
            Math.floor(Math.random() * characters.length)
        );

    return randomRef;
}
</script>