<template>
    <ion-page>
        <Appbar title="Accounts" :show-cart="false"/> 
        <ion-content :fullscreen="true">
            <refresher :on-refresh="getAccounts"/>
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
                    <span class="mt-2"
                        ><i
                            class="fi fi-rr-settings-sliders fs-18 text-gray-700"
                        ></i
                    ></span>
                </div>
            </div>
            <div class="my-1 bg-base-100">
                <h2 class="fs-20 fw-5 p-4">Staff</h2> <div v-if="staff">
                
                <ion-list v-if="staff.length" class=" bg-base-100">
                    <ion-item :router-link="`/account/${acc._id}`" v-for="acc in staff.filter(it=> it.permissions > 0)" color="clear">
                        <ion-avatar slot="start" class="bg-base-200 flex w-50px h-50px flex-center">
                            <span><i class="fi fi-br-user text-gray-600"></i></span>
                        </ion-avatar>
                        <ion-label>
                            <h3 class="fw-5 fs-16">{{ acc.first_name}} {{ acc.last_name }}</h3>
                            <ion-note>{{acc.phone}}</ion-note>
                        </ion-label>
                        <button slot="end" class="btn btn-sm btn-ghost w-30px p-0 rounded-full fs-20">
                            <ion-icon :md="ellipsisVertical"/>
                        </button>
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
             <div v-if="customers" >
               
                <ion-list v-if="customers.length" class=" bg-base-100">
                    <ion-item :router-link="`/account/${acc._id}`" v-for="acc in customers.filter(it=>  it.permissions == 0)" color="clear">
                        <ion-avatar slot="start" class="bg-base-200 flex w-50px h-50px flex-center">
                            <span><i class="fi fi-br-user text-gray-600"></i></span>
                        </ion-avatar>
                        <ion-label>
                            <h3 class="fw-5 fs-16">{{ acc.first_name}} {{ acc.last_name }}</h3>
                            <ion-note>{{acc.phone}}</ion-note>
                        </ion-label>
                        <button slot="end" class="btn btn-sm btn-ghost w-30px p-0 rounded-full fs-20">
                            <ion-icon :md="ellipsisVertical"/>
                        </button>
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
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonInput,
    IonButtons,
    IonLabel,
    IonNote,
    IonIcon,
    IonAvatar,
    IonList,
    IonItem,
} from "@ionic/vue";
import Appbar from '@/components/Appbar.vue';
import { ellipsisVertical } from "ionicons/icons";
import { apiAxios } from "@/utils/constants";
import { onMounted, ref, watch } from "vue";
import { Obj } from "@/utils/classes";

const accounts = ref<Obj[]>(), sortedAccounts = ref<Obj[]>(), staff = ref<Obj[]>(), customers = ref<Obj[]>()

async function getAccounts(){
    accounts.value = undefined
    try{
        const res = await apiAxios.get('/users')
     accounts.value = res.data.users
    }catch(e){
        console.log(e)
        accounts.value = []
    }
}

const onSearchInput = (e: any) => { 
const query = e.target.value
    const filter = (it: Obj)=>{
        let q = new RegExp(query,  'i')
        const fullName = it.first_name + ' ' + it.last_name
        return q.exec(it.first_name) ?? q.exec(it.last_name) ?? q.exec(fullName)
    }
    
    sortedAccounts.value = accounts.value?.filter(filter)
 }

 watch(accounts, (val)=>{
    sortedAccounts.value = val
 }, {deep: true, immediate: true})

 watch(sortedAccounts, (val)=>{
    staff.value = val?.filter(it=>it.permissions > 0)
    customers.value = val?.filter(it=>it.permissions == 0)
 }, {deep: true, immediate: true})

onMounted(()=>{
    getAccounts()
})
</script>