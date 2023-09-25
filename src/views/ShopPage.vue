<template>
    <ion-page>
        <Appbar title="Shop" />
        <ion-content :fullscreen="true" class="ion-padding">
            <div class="flex justify-center w-ful">
                <div class="flex justify-center w-full flex-col">
               <TuFormField/>
                    <div class="relative mb-2 bg-gray- hidden">
                        <div
                            class="absolute inset-y-0 left-0 flex items-center pl-3.5 pointer-events-none"
                        >
                            <span id="open-modal">
                                <i class="fi fi-rr-search fs-18"
                            /></span>
                        </div>
                        <input
                            type="text"
                            id="input-group-1"
                            class="input input-bordered w-full pl-10 rounded rounded-full"
                            placeholder="Search"
                        />
                    </div>
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
            <div class="my-2 grid justify-center gap-2 grid-cols-2">
                <ProductCard
                    class="col-"
                    v-for="(e, i) in dummyProducts"
                    :product="e"
                />
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonModal, IonContent, IonInput, IonItem } from "@ionic/vue";
import { ref, onBeforeMount } from "vue";
import Appbar from "@/components/Appbar.vue";
import ProductCard from "@/components/ProductCard.vue";
import TuFormField from "@/components/TuFormField.vue";
import { dummyProducts } from "@/utils/dummies";
import { eye } from "ionicons/icons";

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

onBeforeMount(() => {
    /*  console.log(products.value)
    if (!products.value)
    products.value = dummyProducts */
});
</script>
<style lang="scss">

.inp-suffix{
    position: relative;
    
    input{
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
    padding: .7rem;
    background-color: yellowgreen;
    pointer-events: all;
}
}

</style>
