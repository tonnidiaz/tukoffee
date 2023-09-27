import { createRouter, createWebHistory } from '@ionic/vue-router';
import { RouteRecordRaw } from 'vue-router';
import TabsPage from '../views/TabsPage.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    redirect: '/tabs/tab1'
  },
  {
    path: '/tabs/',
    component: TabsPage,
    children: [
      {
        path: '',
        redirect: '/tabs/tab1'
      },
  
        {
        path: 'tab1',
        component: () => import('@/views/Tab1Page.vue')
      }, {
        path: 'shop',
        component: () => import('@/views/ShopPage.vue')
      }, 
      {
        path: 'cart',
        component: ()=> import("@/views/CartPage.vue")
      },
      {
        path: 'rf',
        component: () => import('@/views/RFPage.vue')
      },
      {
        path: 'account',
        component: () => import('@/views/AccountTab.vue')
      },
    ]
  }, 
  {
    path: '/product/:id',
    component: ()=>  import('../views/ProductPage.vue')
  },
  {
    path: '/auth/logout',
    component: ()=> import("@/views/auth/LogoutPage.vue")
  },
  {
    path: '/cart',
    component: ()=> import("@/views/CartPage.vue")
  },
  {
    path: '/orders',
    component: ()=> import("@/views/OrdersPage.vue")
  },
  {
    path: '/order/checkout',
    component: ()=> import("@/views/order/CheckoutPage.vue")
  },
  {
    path: '/order/checkout/payment',
    component: ()=> import("@/views/order/PaymentPage.vue")
  },
 
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router
