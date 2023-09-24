<template>
    <ion-page>
        <Appbar :title="product?.name"/>
        <ion-content>
            <div class="card md:flex md:justify-content-center h-200px p-2 bg-primary">
        <Galleria :value="images" :responsive-options="responsiveOptions" :numVisible="5" containerStyle="max-width: 640px; max-height: 100px">
            <template #item="slotProps">
                <img :src="slotProps.item.itemImageSrc" :alt="slotProps.item.alt" style="width: 100%" />
            </template>
            <template #thumbnail="slotProps">
                <img :src="slotProps.item.thumbnailImageSrc" :alt="slotProps.item.alt" />
            </template>
        </Galleria>
    </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {onBeforeMount, ref} from 'vue';
import {IonPage, IonContent} from '@ionic/vue';
import { useRouter, useRoute } from 'vue-router';
import {localhost} from '@/utils/constants';
import axios from 'axios';
import Galleria from 'primevue/galleria';
const router = useRouter()
const route = useRoute()
const {id} = route.params 
import Appbar from '@/components/Appbar.vue';
const product = ref<{[key: string] : any}>();
const responsiveOptions = ref([
    {
        breakpoint: '991px',
        numVisible: 4
    },
    {
        breakpoint: '767px',
        numVisible: 3
    },
    {
        breakpoint: '575px',
        numVisible: 2
    }
]);
const images = [
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria1.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria1s.jpg',
                    alt: 'Description for Image 1',
                    title: 'Title 1'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria2.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria2s.jpg',
                    alt: 'Description for Image 2',
                    title: 'Title 2'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria3.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria3s.jpg',
                    alt: 'Description for Image 3',
                    title: 'Title 3'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria4.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria4s.jpg',
                    alt: 'Description for Image 4',
                    title: 'Title 4'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria5.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria5s.jpg',
                    alt: 'Description for Image 5',
                    title: 'Title 5'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria6.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria6s.jpg',
                    alt: 'Description for Image 6',
                    title: 'Title 6'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria7.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria7s.jpg',
                    alt: 'Description for Image 7',
                    title: 'Title 7'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria8.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria8s.jpg',
                    alt: 'Description for Image 8',
                    title: 'Title 8'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria9.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria9s.jpg',
                    alt: 'Description for Image 9',
                    title: 'Title 9'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria10.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria10s.jpg',
                    alt: 'Description for Image 10',
                    title: 'Title 10'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria11.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria11s.jpg',
                    alt: 'Description for Image 11',
                    title: 'Title 11'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria12.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria12s.jpg',
                    alt: 'Description for Image 12',
                    title: 'Title 12'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria13.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria13s.jpg',
                    alt: 'Description for Image 13',
                    title: 'Title 13'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria14.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria14s.jpg',
                    alt: 'Description for Image 14',
                    title: 'Title 14'
                },
                {
                    itemImageSrc: 'https://primevue.org/images/galleria/galleria15.jpg',
                    thumbnailImageSrc: 'https://primevue.org/images/galleria/galleria15s.jpg',
                    alt: 'Description for Image 15',
                    title: 'Title 15'
                }
            ]

async function getProduct(){
    const res = await axios.get(`${localhost}:8000/products?pid=${726089}`)
    if (res.data.data){
        product.value = res.data.data[0]
    }
    console.log(product.value)
}
onBeforeMount(()=>{

   getProduct()
})
</script>