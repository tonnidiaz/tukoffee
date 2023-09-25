<template>
    <ion-page>
        <Appbar title="Shop" />
        <ion-content :fullscreen="true" class="">
            <div class="flex justify-content-center w-full mt-2">
                <div class="px-3 flex justify-content-center w-full">
                    <span class="p-input-icon-left p-input-icon-right w-full relative">
                        <i class="fi fi-rr-search fs-18" />
                        <InputText placeholder="Search" class="w-full"/>
                        <i
                            class="fi fi-rr-settings-sliders fs-18 bg-"
                            id="open-modal"
                            style="
                                top: 25%;
                                right: 1px;
                                padding: 10px 13px 0px 10px;
                            "
                        />
                    </span>
                    <ion-modal
                        ref="modal"
                        
                        trigger="open-modal"
                        :initial-breakpoint="0.25"
                        :breakpoints="[0, 0.25, 0.5, 0.75]"
                    >
                        <ion-content class="ion-padding flex flex-column justify-content-center align-items-center relative">
                            <div
                                class="w-full h-fu  my-3 flex flex-column justify-content-start align-items-start"
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
            <div class="my-2 grid justify-content-center gap-2">
                <ProductCard class="col-5" v-for="(e, i) in dummyProducts" :product="e" />
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonModal,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonMenuToggle,
    IonButtons,
    IonRippleEffect,
    IonSearchbar,
    IonText,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import { ref, onMounted, onBeforeMount } from "vue";
import Appbar from "@/components/Appbar.vue";
import ProductCard from "@/components/ProductCard.vue";
import DataView from "primevue/dataview";
import Tag from "primevue/tag";
import InputText from "primevue/inputtext";
import Dropdown from "primevue/dropdown";
import { dummyProducts } from "@/utils/dummies";
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
