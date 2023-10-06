<template>
  <div class="h-full" v-if="product">
                <div class="my-1 p-3 bg-base-100">
                    <ion-item color="clear" lines="none">
                        <ion-thumbnail
                            class="h-45px shadow-lg card rounded-lg"
                            slot="start"
                        >
                            <ion-img
                                v-if="product.images?.length"
                                class="rounded-lg"
                                :src="product.images[0].url"
                            ></ion-img>
                            <span v-else>
                                <i
                                    class="fi fi-rr-image-slash text-gray-600"
                                ></i>
                            </span>
                        </ion-thumbnail>

                        <ion-label>
                            <h3 class="fs-18 fw-5">{{ product.name }}</h3>
                        </ion-label>
                    </ion-item>
                </div>

                <div class="my-1 p-3 bg-base-100">
                    <tu-form ref="formRef" @submit="submitReview">
                        <div class="mb-3 flex flex-center" >
                        <star-rating  :star-size="30" :padding="6" v-model:rating="form.rating" :increment="0.5"></star-rating>
                    </div>
                    <div class="my-1">
                        <tu-field  v-model="form.name" label="Name" placeholder="Enter your name..." required/>
                    </div>
                    <div class="my-1">
                        <tu-field v-model="form.title" label="Title" placeholder="Review title..." required/>
                    </div>
                    <div class="my-1">
                        <tu-field textarea :counter="true" :maxlength="MAX_CHARS" v-model="form.body" label="Review" placeholder="Write your review..." required/>
                    </div>
                    <div class="my">
                        <tu-btn  ionic type="submit" class="w-full tu" color="dark">SUBMIT</tu-btn>
                    </div>
                    </tu-form>
                    
                </div>
            </div>
</template>

<script lang="ts" setup>

import {
    IonLabel,
    IonItem,
    IonThumbnail,

    IonImg,
} from "@ionic/vue";
import { Obj } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { errorHandler, hideLoader, showAlert, showLoading } from "@/utils/funcs";
const product = ref<Obj>();
const formRef = ref<HTMLFormElement>()
const form = ref<Obj>({
    rating: 0,
    name: 'Thomas',
    title: 'Keeps me moving',
    body: 'This coffee really keeps me in motion'
});
const MAX_CHARS = 1000
const { id } = useRoute().params; 

const router = useRouter()

const props = defineProps({
    reviewId: String,
    admin: Boolean
})
async function getProduct() {
    try {
        product.value = undefined;
        const res = await apiAxios.get(`/products?pid=${id}`);
        if (res.data.data) {
            const _prod =  res.data.data[0]
            product.value = _prod;
            form.value.product = _prod._id

        }
    } catch (e) {
        console.log(e);
    }
}
async function getReview() {
    try {
        product.value = undefined;
        const res = await apiAxios.get(`/products/reviews?id=${props.reviewId}`);
            const _prod =  res.data.reviews[0].product
            const rev = res.data.reviews[0]
       
            delete rev['product']
            
            product.value = _prod; 
            form.value.product = _prod._id
            form.value = {product: _prod._id, ...rev}
    } catch (e) {
        console.log(e);
    }
}

const submitReview = async (e: any) => { 
    e.preventDefault()
    const _form = form.value

    try{
        if (props.reviewId){
            showLoading({})
        await apiAxios.post('/products/review?act=edit', {id: props.reviewId, review: _form})
        hideLoader()
        await showAlert({message: 'Review edited successfully'})
        location.reload()
        }else{
            showLoading({})
            await apiAxios.post('/products/review?act=add', {pid: product.value!.pid, review: _form})
            hideLoader()
        await showAlert({message: 'Review added successfully'})
        router.back()
        }
        
    }catch(e){
        console.log(e)
        errorHandler(e, 'Failed to add review')
        hideLoader()
    }
 }
onMounted(() => {
    if (props.reviewId){
        getReview()
    }else{ 
getProduct();
    }
   
});
</script>