import { createRouter, createWebHistory } from '@ionic/vue-router';
import { RouteRecordRaw } from 'vue-router';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    redirect: '/~/home'
  },
  {
    path: '/~/',
    component: ()=> import('@/views/IndexPage.vue'),
    children: [
      {
        path: '',
        redirect: '/~/home'
      },
  
        {
        path: 'home',
        component: () => import('@/views/HomePage.vue')
      }, {
        path: 'shop',
        component: () => import('@/views/ShopPage.vue')
      }, 
      {
        path: 'cart',
        component: ()=> import("@/views/CartPage.vue")
      },

      {
        path: 'account',
        component: () => import('@/views/AccountTab.vue')
      },
    ]
  }, 
  {
    path: '/admin/',
    component: () => import('@/views/admin/AdminPage.vue'),
    children: [
        {
            path: '',
            redirect: '/admin/dashboard'
        },
        {
            path: 'dashboard',
            component: ()=>import('@/views/admin/DashboardPage.vue')
        },
        {
            path: 'products',
            component: ()=>import('@/views/admin/ProductsPage.vue')
        },
        {
            path: 'orders',
            component: ()=>import('@/views/OrdersPage.vue')
        },
        {
            path: 'accounts',
            component: ()=>import('@/views/admin/AccountsPage.vue')
        },
    ]
  },
  {
    path: '/product/:id',
    component: ()=>  import('../views/ProductPage.vue')
  },
  {
    path: '/:mode/product',
    component: ()=>  import('../views/AddProductPage.vue')
  },

        {
            path: '/auth/login',
            component: ()=> import('@/views/auth/LoginPage.vue')
        },
        {
            path: '/auth/signup',
            component: ()=> import('@/views/auth/SignupPage.vue')
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
    path: '/search',
    component: ()=> import("@/views/SearchPage.vue")
  },
  {
    path: '/orders',
    component: ()=> import("@/views/OrdersPage.vue")
  },
  {
    path: '/map',
    component: ()=> import("@/views/MapPage.vue")
  },
  {
    path: '/order/:id',
    component: ()=> import("@/views/order/OrderPage.vue")
  },
  {
    path: '/order/checkout',
    component: ()=> import("@/views/order/CheckoutPage.vue")
  },
  {
    path: '/order/checkout/payment',
    component: ()=> import("@/views/order/PaymentPage.vue")
  },
  {
    path: '/rf',
    component: () => import('@/views/RFPage.vue')
  },
  {
    path: '/account/profile',
    component: () => import('@/views/account/ProfilePage.vue')
  },
  {
    path: '/account/:id',
    component: () => import('@/views/account/ProfilePage.vue')
  },
 
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router
