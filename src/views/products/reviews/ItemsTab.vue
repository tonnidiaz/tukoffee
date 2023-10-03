<template>
    <div v-if="products" class="h-full">
        <div class="bg-base-100 p-3">
            <ion-item v-for="product in products" color="clear">
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
                        <i class="fi fi-rr-image-slash text-gray-600"></i>
                    </span>
                </ion-thumbnail>

                <ion-label>
                    <h3 class="fs-18 fw-5">{{ product.name }}</h3>
                    <div class="flex items-center justify-end">
                        <ion-text
                            :router-link="`/product/${product.pid}/review`"
                            class="fs-14 fw-6"
                            color="secondary"
                            >WRITE REVIEW</ion-text
                        >
                    </div>
                </ion-label>
            </ion-item>
        </div>
    </div>
</template>

<script setup lang="ts">
import { IonText, IonLabel, IonItem, IonThumbnail, IonImg } from "@ionic/vue";
import { Obj } from "@/utils/classes";
import { apiAxios } from "@/utils/constants";
import { onMounted, ref } from "vue";
import { errorHandler } from "@/utils/funcs";

const products = ref<Obj[] | null>();

const getProducts = async () => {
    try {
        const res = await apiAxios.get("/products?q=received");
        let prods: Obj[] = [];
        for (let p of res.data) {
            const itemIds: string[] = p.items.map((it: Obj) => it._id);

            // If prods does not contain an item whose id is in itemIds
            if (!prods.find((it) => itemIds.includes(it._id)))
                prods = prods.concat(p.items);
        }
        products.value = prods.filter((it) => it);
    } catch (e) {
        console.log(e);
        errorHandler(e, "Failed to fetch products");
    }
};

onMounted(() => {
    getProducts();
});
</script>
