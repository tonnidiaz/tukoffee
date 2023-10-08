<template>
<router-link
                          
                            :to="`/product/${item.pid}`"
                            class="flex flex-col items-center flex-shrink-0 w-90px bg- relative overflow-hidden ion-activatable"
                        >
                        <ion-ripple-effect/>
                            <div
                                class="flex flex-col w-full items-center overflow-hidden"
                            >
                                <div class="avatar">
                                    <div
                                        style="display: flex !important"
                                        class="w-80px rounded-full bg-base-100 flex items-center justify-center"
                                    >
                                        <img
                                            v-if="item.images?.length"
                                            alt=""
                                            :src="item.images[0].url"
                                        />

                                        <span v-else>
                                            <i class="fi fi-rr-image-slash"></i>
                                        </span>
                                    </div>
                                </div>

                                
                                <div v-if="sale">
                                    <h5 class="mt-2 text-black fs-12 fw-6 linethrough">
                                    R{{ item.price.toFixed(2) }}
                                </h5>
                                    <h5
                                class="text-black fs-12 fw-6"
                                style="transform: scale(1.2)"
                            >
                                R{{ item.sale_price.toFixed(2) }}
                            </h5>
                                </div>
                                <h5 v-else class="mt-2 text-black fs-12 fw-6">
                                    R{{ item.price.toFixed(2) }}
                                </h5>
                                <div class="flex items-start justify-start overflow-hidden w-full">
                                    <h4
                                        class="fs-14 fw-5 overflow-hidden"
                                        style="
                                            white-space: nowrap;
                                            text-overflow: ellipsis;
                                        "
                                    >
                                        {{ item.name }} Lorem ipsum, dolor sit amet
                                        consectetur adipisicing elit.
                                        Consectetur voluptatem quam et
                                        voluptates provident earum, quas debitis
                                        eos dolorem praesentium! Totam fugit
                                        dignissimos ipsa ad omnis porro impedit
                                        exercitationem obcaecati.
                                    </h4>
                                </div>
                            </div>
                        </router-link>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonSearchbar,
    IonText,
    IonRefresher,
    IonRefresherContent,
    IonRippleEffect
} from "@ionic/vue";
import { Obj } from '@/utils/classes';

 
defineProps<{
    item: Obj,
    sale?: boolean
}>()
</script>