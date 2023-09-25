<template>
  <ion-app>
    <ion-router-outlet />
  </ion-app>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet } from '@ionic/vue';
import { apiAxios, } from './utils/constants';
import { onBeforeMount } from 'vue';
import { useUserStore } from './stores/user';
import { Store } from 'pinia';
import { setupCart } from './utils/funcs';
const userStore = useUserStore()

const setupUser = async () => { 
    try{
        console.log('Setting up cart...')
        const authToken = localStorage.getItem('authToken')
        if(authToken){
            const res  = await apiAxios.post(`/auth/login`)
            userStore.setUser(res.data.user)
            setupCart(res.data.user['phone'], userStore)
        }else{
            userStore.setUser({})
            userStore.setCart({})
        }
        
    }catch(e){
        console.log(e)
    }
 }



 onBeforeMount(()=>{
    setupUser()
 })
</script>
<style lang="scss">
ion-toolbar{
    --ion-toolbar-background: hsl(var(--b1));
    //border-bottom: 1px solid rgb(156 163 175 /.2);
}
ion-tab-bar {
    bottom: 0px;
    position: relative;
    //border-radius: 16px;
    width: 100%;
    margin: 0 auto;
   // border-top: 1px solid rgba(0, 0, 0, 0.178);
    padding: 0.2rem 0;
    //background-color: black;
}

ion-tab-button {
    --color: var(--surface-600);
    --color-selected: hsl(
        var(--bc)
    ); // hsl(var(--p) / var(--tw-bg-opacity))//var(--primary-color);
    /* rgb(255, 145,0);/ */
    &::before {
        background-color: transparent;
        display: block;
        content: "";
        margin: 0 auto;
        width: 20px;
        height: 2px;
    }


    &.tab-selected::before {
        width: 30px;
    }
    ion-icon {
        font-size: 20px;
    }
    &.tab-selected {
        transform: scale(1.3);
    }
}

ion-thumbnail{
    align-items: center;
    justify-content: center;
}
</style>