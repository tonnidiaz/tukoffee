<template>
    <refresher :on-refresh="getProducts" />
    <div v-if="products && user" class="h-full">
        <div v-if="products.length" class="bg-base-100 sm:p-3  mt-1">
            <div v-for="product in products">
                <ion-item
                    :router-link="
                        review(product)
                            ? `/products/reviews/${review(product)._id}`
                            : undefined
                    "
                    color="clear"
                >
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
                        <div
                            v-if="review(product)"
                            class="flex items-center gap-x-3 flex-wrap"
                        >
                            <star-rating
                                :show-rating="false"
                                :star-size="15"
                                :padding="6"
                                read-only
                                :rating="review(product).rating"
                                :increment="0.5"
                            ></star-rating>
                            <ion-badge
                                mode="ios"
                                :color="
                                    review(product).status == 0
                                        ? 'medium'
                                        : review(product).status == 1
                                        ? 'success'
                                        : 'danger'
                                "
                                >{{
                                    reviewStatuses[review(product).status]
                                }}</ion-badge
                            >
                        </div>
                        <div v-else class="flex items-center justify-end">
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
        <div v-else class="bg-base-100 px-6 h- flex flex-center mt-1">
            <h3 class="fs-18 fw-5 text-center">
                You have not ordered and received any products using this app
                yet
            </h3>
        </div>
    </div>
    <div v-else class="h-full bg-base-100 flex flex-center">
        <ion-spinner color="medium" class="w-50px h-50px"></ion-spinner>
    </div>
</template>

<script setup lang="ts">
import {
    IonText,
    IonLabel,
    IonItem,
    IonThumbnail,
    IonImg,
    IonSpinner,
    IonBadge,
} from "@ionic/vue";
import { Obj } from "@/utils/classes";
import { apiAxios, reviewStatuses } from "@/utils/constants";
import { onMounted, ref } from "vue";
import { errorHandler } from "@/utils/funcs";
import { storeToRefs } from "pinia";
import { useUserStore } from "@/stores/user";
const { user } = storeToRefs(useUserStore());
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
const review = (product: Obj) => {
    return product.reviews.find((it: Obj) => it.user == user.value?._id);
};
onMounted(() => {
    getProducts();
});
</script>
