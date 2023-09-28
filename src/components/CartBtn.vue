<template>
   
    <ion-button router-link="/cart" router-direction="forward" class="relative cart-btn ">
                      
                         <div class="indicator">
                    <span class="indicator-item badge badge-secondary fs-10"
                        >{{userStore.cart?.products?.length ?? 0}}</span>
                      <i class="fi fi-rr-shopping-basket"></i>
                    </div>
                    </ion-button>
</template>
<script setup lang="ts">
import {
    IonButton,IonBadge 
} from "@ionic/vue";
import {useUserStore} from '@/stores/user';
const userStore = useUserStore()

</script>
<style lang="scss">
.cart-btn{
    //background-color: red;
    --overflow: visible;
    margin-right: 5px !important;
}
.cart-badge{
    right:  -5px;
    top: -3px; 
    width: 20px;
    height: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
   background-color: orange;
   color: white;
   font-size: 12px;
   font-weight: 700;
         border-radius: 50% ;
    
}
</style>