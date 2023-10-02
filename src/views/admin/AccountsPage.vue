<template>
    <ion-page>
        <Appbar title="Accounts" :show-cart="false" >
            <DropdownBtn :items="[
            {label: 'Back to home', cmd: ()=> $router.push('/~/home')}
        ]"/>
        </Appbar>
        <ion-content :fullscreen="true">
            <refresher :on-refresh="getAccounts" />
            <div class="my-1 bg-base-100 p-3">
                <div
                    class="bg-base-200 rounded-md flex items-center px-4 h-45px gap-2"
                >
                    <span class="mt-1"
                        ><i class="fi fi-rr-search fs-18 text-gray-700"></i
                    ></span>

                    <ion-input
                        color="clear"
                        @ion-input="onSearchInput"
                        placeholder="Search by name or email"
                        class="tu bg-primar"
                    ></ion-input>
                   
                </div>
            </div>
            <div class="my-1 bg-base-100">
                <h2 class="fs-20 fw-5 p-4">Staff</h2>
                <div v-if="staff">
                    <ion-list v-if="staff.length" class="bg-base-100">
                        <ion-item
                            :router-link="`/account/${acc._id}`"
                            v-for="acc in staff.filter(
                                (it) => it.permissions > 0
                            )"
                            color="clear"
                        >
                            <ion-avatar
                                slot="start"
                                class="bg-base-200 flex w-50px h-50px flex-center"
                            >
                                <span
                                    ><i class="fi fi-br-user text-gray-600"></i
                                ></span>
                            </ion-avatar>
                            <ion-label>
                                <h3 class="fw-5 fs-16">
                                    {{ acc.first_name }} {{ acc.last_name }}
                                </h3>
                                <ion-note>{{ acc.phone }}</ion-note>
                            </ion-label>
                            <DropdownBtn
                                :items="[
                                    {
                                        label: 'Delete',
                                        cmd: () => (delAccountAlert2 = true),
                                    },
                                ]"
                            />
                            <ion-alert
                                header="Delete account"
                                message="Are you sure you want to delete the account?"
                                class="tu"
                                @did-dismiss="delAccountAlert2 = false"
                                :is-open="delAccountAlert2"
                                :buttons="[
                                    {
                                        text: 'Cancel',
                                        role: 'cancel',
                                    },
                                    {
                                        text: 'Continue',
                                        role: 'confirm',
                                        handler: () => {
                                            delAccounts([acc]);
                                        },
                                    },
                                ]"
                            ></ion-alert>
                        </ion-item>
                    </ion-list>
                    <div v-else class="p-4">
                        <h3 class="fw-5 text-center">Nothing to show</h3>
                    </div>
                </div>
                <div v-else class="p-4">
                    <h3 class="fw-5 text-center">Loading...</h3>
                </div>
            </div>
            <div class="my-1 bg-base-100">
                <h2 class="fs-20 fw-5 p-4">Customers</h2>
                <div v-if="customers">
                    <ion-list v-if="customers.length" class="bg-base-100">
                        <ion-item
                            :router-link="`/account/${acc._id}`"
                            v-for="acc in customers.filter(
                                (it) => it.permissions == 0
                            )"
                            color="clear"
                        >
                            <ion-avatar
                                slot="start"
                                class="bg-base-200 flex w-50px h-50px flex-center"
                            >
                                <span
                                    ><i class="fi fi-br-user text-gray-600"></i
                                ></span>
                            </ion-avatar>
                            <ion-label>
                                <h3 class="fw-5 fs-16">
                                    {{ acc.first_name }} {{ acc.last_name }}
                                </h3>
                                <ion-note>{{ acc.phone }}</ion-note>
                            </ion-label>
                            <DropdownBtn
                                :items="[
                                    {
                                        label: 'Delete',
                                        cmd: () => (delAccountAlert = true),
                                    },
                                ]"
                            />

                            <!-- Delete account alert -->
                            <ion-alert
                                header="Delete account"
                                message="Are you sure you want to delete the account?"
                                class="tu"
                                @did-dismiss="delAccountAlert = false"
                                :is-open="delAccountAlert"
                                :buttons="[
                                    {
                                        text: 'Cancel',
                                        role: 'cancel',
                                    },
                                    {
                                        text: 'Continue',
                                        role: 'confirm',
                                        handler: () => {
                                            delAccounts([acc]);
                                        },
                                    },
                                ]"
                            ></ion-alert>
                        </ion-item>
                    </ion-list>
                    <div v-else class="p-4">
                        <h3 class="fw-5 text-center">Nothing to show</h3>
                    </div>
                </div>
                <div v-else class="p-4">
                    <h3 class="fw-5 text-center">Loading...</h3>
                </div>
            </div>
        </ion-content>
    </ion-page>
</template>
<script setup lang="ts">
import {
    IonPage,
    IonContent,
    IonInput,
    IonLabel,
    IonNote,
    IonAlert,
    IonAvatar,
    IonList,
    IonItem,
} from "@ionic/vue";
import Appbar from "@/components/Appbar.vue";
import { ellipsisVertical } from "ionicons/icons";
import { apiAxios } from "@/utils/constants";
import { onMounted, ref, watch } from "vue";
import { Obj } from "@/utils/classes";
import DropdownBtn from "@/components/DropdownBtn.vue";
import { errorHandler } from "@/utils/funcs";

const accounts = ref<Obj[]>(),
    sortedAccounts = ref<Obj[]>(),
    staff = ref<Obj[]>(),
    customers = ref<Obj[]>();
const delAccountAlert = ref(false);
const delAccountAlert2= ref(false);

async function getAccounts() {
    accounts.value = undefined;
    try {
        const res = await apiAxios.get("/users");
        accounts.value = res.data.users;
    } catch (e) {
        console.log(e);
        accounts.value = [];
    }
}

const onSearchInput = (e: any) => {
    const query = e.target.value;
    const filter = (it: Obj) => {
        let q = new RegExp(query, "i");
        const fullName = it.first_name + " " + it.last_name;
        return (
            q.exec(it.first_name) ?? q.exec(it.last_name) ?? q.exec(fullName)
        );
    };

    sortedAccounts.value = accounts.value?.filter(filter);
};

const delAccounts = async (accs: Obj[]) => {
    try {
        await apiAxios.post("/users/delete", {
            ids: accs.map((acc) => acc._id),
        });
        accounts.value = accounts.value?.filter((it) =>
            accs.find((el) => el._id != it._id)
        );
    } catch (e) {
        console.log(e);
        errorHandler(e, "Failed to delete account", true);
    }
};
watch(
    accounts,
    (val) => {
        sortedAccounts.value = val;
    },
    { deep: true, immediate: true }
);

watch(
    sortedAccounts,
    (val) => {
        staff.value = val?.filter((it) => it.permissions > 0);
        customers.value = val?.filter((it) => it.permissions == 0);
    },
    { deep: true, immediate: true }
);

onMounted(() => {
    getAccounts();
});
</script>
