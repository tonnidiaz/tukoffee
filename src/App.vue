<template>
  <ion-app>
    <ion-router-outlet v-if="userSetup"/>
    <div v-else class="w-full h-full flex items-center justify-center">
        <h1 class="fs-30 fw-7">Loading</h1>
        
    </div>
  </ion-app>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet } from '@ionic/vue';
import { apiAxios, } from './utils/constants';
import { onBeforeMount } from 'vue';
import { useUserStore } from './stores/user';
import { Store, storeToRefs } from 'pinia';
import { setupCart } from './utils/funcs';
const userStore = useUserStore()
const { userSetup} = storeToRefs(userStore)
const setupUser = async () => { 
    userStore.setUserSetup(false)
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
    userStore.setUserSetup(true)
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

.dropdown{
    *{
        white-space: nowrap;
        text-transform: ellipsis;
        overflow-x: hidden;
    }
}

ion-popover{
    --width: 200px,
    &::part(backdrop) {
    background-color: rgb(165, 165, 165);
  }}

  ion-action-sheet.tu .action-sheet-group {
    //background: #f58840;
  }

  ion-action-sheet.tu .action-sheet-title {
    //color: #fff;
  }

  ion-action-sheet.tu .action-sheet-cancel::after {
    //background: #e97223;
  }

  ion-action-sheet.tu .action-sheet-button,
  ion-action-sheet.tu .action-sheet-button.ion-focused {
    color: hsl(var(--bc) / .8);
    height: 50px;
  }

  @media (any-hover: hover) {
    ion-action-sheet.tu .action-sheet-button:hover {
      color: #000000;
    }
  }

  ion-action-sheet.tu ion-backdrop {
    opacity: 0.6;
  }

  .bg-base-100{
    --background: hsl(var(--b1) / var(--tw-bg-opacity))
  }
  .m-block {
    width: 100%;
    height: 300px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  ion-modal{
    &.h-auto{
    --height: auto
    }
  }
</style>