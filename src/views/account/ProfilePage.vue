<template>
    <ion-page>
        <Appbar :title="account ? `${account.first_name} ${account.last_name}`: 'Profile'"  :show-cart="false">
        <icon-btn v-if="account?._id == user?._id" router-link="/account/settings"> <i class="fi fi-sr-settings"></i> </icon-btn>
        </Appbar>
        <ion-content :fullscreen="true">
            <refresher :on-refresh="getAccount"/>
            <div v-if="account" class="px-2">
                <div class="my-1">
                    <table class="table w-full">
                        <tr>
                            <th colspan="2" class="p-0 pl-4">
                                <div class="flex justify-between items-center">
                                    <h3 class="fs-18 fw-5">Personal details</h3>
                                    <icon-btn
                                        @click="personalDetailsSheetOpen = true"
                                    >
                                        <i class="fi fi-br-pencil fs-18"></i>
                                    </icon-btn>
                                </div>
                            </th>
                        </tr>
                        <!-- Personal details sheet -->
                        <bottom-sheet
                            :is-open="personalDetailsSheetOpen"
                            @did-dismiss="personalDetailsSheetOpen = false"
                        >
                            <div class="bg-base-100 p-3">
                                <tu-form
                                    @submit="editPersonalDetails"
                                    action=""
                                >
                                    <div class="my-1">
                                        <tu-field
                                            label="First name:"
                                            placeholder="e.g. John"
                                            required
                                            v-bind:value="account.first_name"
                                            v-model="form.first_name"
                                        />
                                    </div>
                                    <div class="my-1">
                                        <tu-field
                                            label="Last name:"
                                            placeholder="e.g. Doe"
                                            required
                                            v-bind:value="account.last_name"
                                            v-model="form.last_name"
                                        />
                                    </div>
                                    <div class="my-2">
                                        <tu-btn
                                            type="submit"
                                            class="w-full"
                                            >Save changed</tu-btn
                                        >
                                    </div>
                                </tu-form>
                            </div>
                        </bottom-sheet>
                        <tbody class="bg-base-100">
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
                <div class="my-1">
                    <table class="table">
                        <th colspan="2">
                            <h2 class="fs-18 fw-5">Contact details</h2>
                        </th>
                        <tbody class="bg-base-100">
                            <tr>
                                <td class="fw-5 fs-16">Email</td>
                                <td class="fs-16">{{ account.email }}</td>
                            </tr>
                            <tr class="">
                                <td class="fw-5 fs-16">Phone</td>
                                <td class="fs-16">{{ account.phone }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="my-1">
                    <div class="flex items-center justify-between pl-4">
                        <h2 class="fs-18 fw-5">Residential address</h2>
                        <icon-btn @click="addressSheetOpen = true"
                            >
                            <i v-if="account?.address" class="fi fi-br-pencil fs-18"></i>
                            <i v-else class="fi fi-br-plus fs-18"></i>
                        </icon-btn>
                        <bottom-sheet
                            no-swipe-dismiss
                            :is-open="addressSheetOpen"
                            @did-dismiss="addressSheetOpen = false"
                        >
                            <div class="h-100vh">
                                <map-view :location="account?.address?.location"
                                    :on-ok="(val: any)=>editAddress(val)"
                                />
                            </div>
                        </bottom-sheet>
                    </div>
                    <div v-if="account?.address" class="bg-base-100 p-3">
                         <p  class="fw-5 fs-16  selectable">
                        {{ account.address.location?.name }}
                    </p>
                    </div>
                   
                    <div class="bg-base-100 p-3" v-else>
                        <h3 class="fw-5 text-center">No address</h3>
                    </div>
                </div>
                <div class="mt-3">
                    <div class="flex items-center justify-between pl-4">
                        <h2 class="fs-18 fw-5">Permissions</h2>
                        <icon-btn v-if="user?.permissions > 0" @click="permissionsSheetOpen = true"
                            ><i class="fi fi-br-pencil fs-18"></i
                        ></icon-btn>
                        <bottom-sheet
                            :is-open="permissionsSheetOpen"
                            @did-dismiss="permissionsSheetOpen = false"
                        >
                            <div class="bg-base-100 p-3">
                                <h3 class="my-4 fs-18">Permissions</h3>
                                <div class="mt-4 gap-2 flex flex-wrap">
                                    <ion-checkbox
                                        :checked="form.permissions >= 0"
                                        @ion-change="
                                            $event.target.checked =
                                                !$event.target.checked
                                        "
                                        mode="ios"
                                        label-placement="end"
                                        >Read</ion-checkbox
                                    >
                                    <ion-checkbox
                                        :checked="form.permissions >= 1"
                                        @ion-change="(e)=>{if (e.target.checked) {form.permissions = 1 }else{form.permissions = 0}} "
                                        mode="ios"
                                        label-placement="end"
                                        >Write</ion-checkbox
                                    >
                                    <ion-checkbox
                                        :checked="form.permissions >= 2"
                                        @ion-change="(e)=>{if (e.target.checked) {form.permissions = 2 }else{form.permissions = 1}} "
                                        mode="ios"
                                        label-placement="end"
                                        >Delete</ion-checkbox
                                    >
                                </div>
                                <tu-btn :on-click="editPermissions" class="mt-4 w-full" color="dark" ionic>Save changes</tu-btn>
                            </div>
                        </bottom-sheet>
                    </div>

                    <div class="mt-4 gap-2 flex flex-wrap bg-base-100 p-4">
                        <ion-checkbox
                            :checked="account.permissions >= 0"
                            @ion-change="
                                $event.target.checked = !$event.target.checked
                            "
                            mode="ios"
                            label-placement="end"
                            >Read</ion-checkbox
                        >
                        <ion-checkbox
                            :checked="account.permissions >= 1"
                            @ion-change="
                                $event.target.checked = !$event.target.checked
                            "
                            mode="ios"
                            label-placement="end"
                            >Write</ion-checkbox
                        >
                        <ion-checkbox
                            :checked="account.permissions >= 2"
                            @ion-change="
                                $event.target.checked = !$event.target.checked
                            "
                            mode="ios"
                            label-placement="end"
                            >Delete</ion-checkbox
                        >
                    </div>
                </div>
            </div>
            <div class="h-full bg-base-100 flex flex-center" v-else>
                <ion-spinner color="medium" class="h-55px w-55px"></ion-spinner>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import { IonPage, IonContent, IonCheckbox, IonSpinner } from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { useRoute } from "vue-router";
import { onMounted, ref, watch } from "vue";
import { apiAxios } from "@/utils/constants";
import { Obj } from "@/utils/classes";
import { storeToRefs } from "pinia";
import { useUserStore } from "@/stores/user";
import BottomSheet from "@/components/BottomSheet.vue";
import { errorHandler, hideLoader, showLoading, sleep } from "@/utils/funcs";

const userStore = useUserStore();
const { user } = storeToRefs(userStore);
const {setUser} = userStore
const account = ref<Obj | null>();
const form = ref<Obj>({});

/* Sheets */
const personalDetailsSheetOpen = ref(false);
const addressSheetOpen = ref(false);
const permissionsSheetOpen = ref(false);

const route = useRoute();
const { id } = route.params;

const getAccount = async () => {
    try {
        account.value = null
        const res = await apiAxios.get(`/users?id=${id ??user.value?._id}`);
        account.value = res.data.users[0];
    } catch (e) {
        console.log(e);
    }
};

const editPersonalDetails = async (e: Event) => {
    const _form = form.value;
    try {
        const res = await apiAxios.post("/user/edit", {
            userId: account.value!._id,
            value: {
                first_name: _form.first_name,
                last_name: _form.last_name,
            },
        });
        account.value = res.data.user;
        setUser(res.data.user)
        personalDetailsSheetOpen.value = false;
    } catch (error) {
        errorHandler(error);
    }
};
const editPermissions = async (e: Event) => {
    const _form = form.value;
    try {
        const res = await apiAxios.post("/user/edit", {
            userId: account.value!._id,
            value: {
                permissions: _form.permissions,
            },
        });
        account.value = res.data.user;
        permissionsSheetOpen.value = false;
    } catch (error) {
        errorHandler(error);
    }
};
const editAddress = async (addr: Obj) => {
    try {
        addressSheetOpen.value = false;
        if (!addr) return;
        showLoading({msg: 'Adding address...'})
        const res = await apiAxios.post("/user/edit", {
            userId: account.value!._id,
            value: {
                address: {
                    location: addr,
                },
            },
        });
        account.value = res.data.user;
        hideLoader()
    } catch (error) {
        hideLoader()
        errorHandler(error);
        
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
<style>
td:nth-child(2) {
    text-align: end;
}
</style>
