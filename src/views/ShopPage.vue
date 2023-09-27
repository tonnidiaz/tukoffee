<template>
    <ion-page>
        <Appbar title="Shop" />
        <ion-content :fullscreen="true">
            <Refresher :on-refresh="init"/>
            <div class="h-full w-full flex flex-col p-3">
                <div class="flex justify-center w-ful">
                <div class="flex justify-center w-full flex-col">
                    <TuFormField class="rounded-full w-full" :field-props="{
                        placeholder:'Search'
                    }" placeholder="Search..." >
                        <template #prefix-icon
                            >
                            <span class="btn btn-ghost btn-sm rounded-full field-icon">
                                <i class="fs-18 fi fi-rr-search"></i
                        >
                            </span>
                            </template>
                        <template #suffix-icon 
                            >
                            <span class="btn btn-ghost btn-sm rounded-full field-icon" id="open-modal">
                                <i class="fs-18 fi fi-rr-settings-sliders"></i
                        >
                            </span>
                            </template>
                    </TuFormField>

                    <ion-modal
                        ref="modal"
                        trigger="open-modal"
                        :initial-breakpoint="0.25"
                        :breakpoints="[0, 0.25, 0.5, 0.75]"
                    >
                        <ion-content
                            class="ion-padding flex flex-col justify-center items-center relative"
                        >
                            <div
                                class="w-full h-fu my-3 flex flex-col justify-start items-start"
                            >
                                <div class="flex gap-2 w-full">
                                    <Dropdown
                                        v-model="sortBy"
                                        :options="sorts"
                                        optionLabel="name"
                                        placeholder="Sort by"
                                        class="w-full md:w-14rem"
                                    />
                                    <Dropdown
                                        v-model="sortBy"
                                        :options="sorts"
                                        optionLabel="name"
                                        placeholder="Status"
                                        class="w-full md:w-14rem"
                                    />
                                </div>
                            </div>
                        </ion-content>
                    </ion-modal>

                    <!-- 
 -->
                </div>
            </div>
            <div v-if="products" class="my-2 grid justify-center gap-1 grid-cols-2">
                <ProductCard
                    v-for="(e, i) in products"
                    :product="e"
                />
            </div>
            <div style="flex: auto;" class="w-full flex items-center justify-center" v-else>
                <h3 class="fs-20">Loading...</h3>
            </div>

            </div>
            
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonModal, IonContent, IonInput, IonItem } from "@ionic/vue";
import { ref, onMounted } from "vue";
import Appbar from "@/components/Appbar.vue";
import ProductCard from "@/components/ProductCard.vue";
import TuFormField from "@/components/TuFormField.vue";
import TuButton from "@/components/TuButton.vue";

import { apiAxios } from "@/utils/constants";
import Refresher from "@/components/Refresher.vue";
import { sleep } from "@/utils/funcs";

const products = ref();
const sortBy = ref();
const sorts = [
    {
        name: "Name",
        value: "name",
    },
    {
        name: "Price",
        value: "price",
    },
    {
        name: "Date new to old",
        value: "date1",
    },
    {
        name: "Date old to new",
        value: "date2",
    },
];

const handleClick =async () => { 
    await sleep(2000)
    console.log('Slept')
 }
async function getProducts(){
    try {
        products.value = undefined
        const res = await apiAxios.get('/products')
        products.value = res.data.data

    } catch (error) {
        console.log(error)
    }
}
const init = async () => { 
    await getProducts()
 }

onMounted(() => {
    init()
});
</script>
<style lang="scss">
.inp-suffix {
    position: relative;

    input {
        padding-right: 2rem !important;
    }
    .suffix-icon {
        position: absolute;
        top: 0;
        right: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        height: 100%;
        padding: 0.7rem;
        background-color: yellowgreen;
        pointer-events: all;
    }
}
</style>
