<template>
    <ion-page>
        <Appbar :title="account?.first_name ?? 'Profile'" />
        <ion-content :fullscreen="true">
            <div v-if="account">
                <div class="my-1 bg-base-100 p-3">
                    <table class="table">
                        <th colspan="2">
                            <h2 class="fs-18 fw-5">Personal details</h2>
                        </th>
                        <tbody>
                            <tr>
                                <td class="fw-5 fs-16">First name</td>
                                <td class="fs-16">{{ account.first_name }}</td>
                            </tr>
                            <tr>
                                <td class="fw-5 fs-16">Last name</td>
                                <td class="fs-16">{{ account.last_name }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="my-1 bg-base-100 p-3">
                    <table class="table">
                        <th colspan="2">
                            <h2 class="fs-18 fw-5">Contact details</h2>
                        </th>
                        <tbody>
                            <tr>
                                <td class="fw-5 fs-16">Email</td>
                                <td class="fs-16">{{ account.email }}</td>
                            </tr>
                            <tr>
                                <td class="fw-5 fs-16">Phone</td>
                                <td class="fs-16">{{ account.phone }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="my-1 bg-base-100 p-3 pl-7">
                    <h2 class="fs-18 fw-5">Residential address</h2>
                    <p class="fw-5 fs-16 mt-4">
                        {{ account.address.location.name }}
                    </p>
                </div>
                <div class="my-1 bg-base-100 p-3 pl-7">
                    <h2 class="fs-18 fw-5">Permissions</h2>
                
                <div class="mt-4 gap-2 flex flex-wrap">
                    <ion-checkbox :checked="account.permissions >= 0" mode="ios" label-placement="end">Read</ion-checkbox>
                    <ion-checkbox  :checked="account.permissions >= 1" mode="ios" label-placement="end">Write</ion-checkbox>
                    <ion-checkbox  :checked="account.permissions >= 2"  mode="ios" label-placement="end">Delete</ion-checkbox>
                </div>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonMenuToggle,
    IonButtons,
    IonCheckbox,
    IonSearchbar,
    IonText,
    IonAvatar,
    IonInfiniteScroll,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { useRoute } from "vue-router";
import { onMounted, ref } from "vue";
import { apiAxios } from "@/utils/constants";
import { Obj } from "@/utils/classes";
import { storeToRefs } from "pinia";
import { useAppStore } from "@/stores/app";
import { useUserStore } from "@/stores/user";

const userStore = useUserStore();
const { user } = storeToRefs(userStore);

const account = ref<Obj | null>();

const route = useRoute();
const { id } = route.params;

const getAccount = async () => {
    try {
        const res = await apiAxios.get(`/users?id=${id}`);
        account.value = res.data.users[0];
    } catch (e) {
        console.log(e);
    }
};

onMounted(() => {
    if (id) {
        getAccount();
    } else {
        account.value = user.value!;
    }
});
</script>
