import axios from "axios";
import { CLOUDINARY_API_KEY, CLOUDINARY_SECRET, apiAxios } from "./constants";
import { Cloudinary, ResourceType } from "@capawesome/capacitor-cloudinary";
import { Obj } from "./classes";
import { AlertButton, alertController, loadingController, modalController, popoverController, toastController } from "@ionic/vue";
import $ from 'jquery'
import { Router } from "vue-router";
import { App } from "@capacitor/app";
export function randomIntFromInterval(min: number, max: number) {
    // min and max included
    return Math.floor(Math.random() * (max - min + 1) + min);
}
export const randomImg = () => {
    return `https://picsum.photos/80/80?random=${randomIntFromInterval(
        1,
        100
    )}`;
};
export const setupCart = async (userId: string, userStore: any) => {
    try {
        userStore.setCart(null);
        console.log("Setting up cart...");
        const res = await apiAxios.get(`/user/cart?user=${userId}`);
        userStore.setCart(res.data.cart);
        return res.data.cart;
    } catch (e) {
        console.log(e);
        return {};
    }
};
export const testClick = (e: any) => {
    console.log(`Clicked:`, e.target);
};

export function sleep(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

const cloudinaryFolder = (storeName: string, folder = 'products')=>{
    const dev = true
    return `TunedBass/${storeName}/${dev ? "DEV" : "PROD"}/images/${folder}`
}

export const uploadImage = async (path: any, storeName: string)=>{
    const public_id = `${storeName}_-_product_-_epoch-${Date.now()}`;
    const res = await Cloudinary.uploadResource({
        path:path,
        publicId: cloudinaryFolder(storeName) + '/' + public_id,
        resourceType: ResourceType.Image,
        uploadPreset: 't6pie4cq',
        
  
      }); 
      return res
}

export const onBack = (path: string, router: Router)=>{
    if (path.startsWith('/~/') || history.state.back == '/order/checkout'){
       
        if (path == '/~/home'){
            // Exit app
            App.minimizeApp()
        }else{
            // Back to home
            router.replace('/')
        }
      }
      else if((path.startsWith('/admin'))){
        if (path == "/admin/dashboard"){
            // Back to home
            router.replace('/')
            
        }else{
            // To dashboard home
            router.replace('/admin/dashboard')
        }
      }
      else{
        router.back()
      }
}

export const saveProduct = async(product: Obj, mode = 'add')=>{
    try{
        const res = await apiAxios.post(`/products/${mode}`, product)
        return`${res.data.pid}`
    }
    catch(e){
        console.log(e)
        errorHandler(e,)
        return null
    }
}
export function strToDate(str: string) {
    return new Date(str);
}

export async function showToast({
    msg,
    position = "bottom",
    duration = 1500,
    cssClass,
}: {
    msg: string;
    position?: "top" | "middle" | "bottom";
    duration?: number;
    cssClass?: string;
} ) {
    const toast = await toastController.create({
        message: msg,
        duration: duration,
        position: position,
        cssClass: cssClass
    });

    await toast.present();
}

export const showAlert = async ({title, message, buttons = ['Ok']} : {title?: string, message: string, buttons?: (string | AlertButton)[]}) => {
    const alert = await alertController.create({
      header: title,
      //subHeader: 'Important message',
      subHeader: message,
      buttons,
      mode: 'ios'
    });

    await alert.present();
  };
export function errorHandler(e: any, message = "Something went wrong", force = false){
    const msg: string = force ? message : (e.response?.data ?? message);
        showToast({msg: msg.replace('tuned:', ''), cssClass: 'ion-danger', duration: 2000}  );
}

export function toHome(){
    location.href = '/'
}
export const showLoading = async ({msg = 'Please wait...',  duration = undefined} : {msg?: string, duration? : number | undefined})=>{
    const loading = await loadingController.create({
        message: msg,
        duration,
        cssClass: 'tu'
      });

      loading.present();
}
export async function hideModal(){
   await modalController.dismiss(null, 'close')
}
export function hideLoader(){
    loadingController.dismiss(null, 'close')
}
export function hidePopover(){
    popoverController.dismiss(null, )
}

export function openSheet(id: string){
    $('#' + id).trigger('click')
}

export const passValidator = (pwd: string | null)=>{
    return !pwd?.length ? 'Password is required' : (pwd?.length < 6 ? 'Should me 6 or more characters' : null)
}