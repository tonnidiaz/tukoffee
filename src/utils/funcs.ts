import axios from "axios";
import { CLOUDINARY_API_KEY, CLOUDINARY_SECRET, apiAxios } from "./constants";
import { Cloudinary, ResourceType } from "@capawesome/capacitor-cloudinary";
import { Obj } from "./classes";
import { alertController, toastController } from "@ionic/vue";

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
export const setupCart = async (phone: string, userStore: any) => {
    try {
        userStore.setCart(null);
        console.log("Setting up cart...");
        const res = await apiAxios.get(`/user/cart?user=${phone}`);
        userStore.setCart(res.data.cart);
        return res.data.cart;
    } catch (e) {
        console.log(e);
        return null;
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

export const showAlert = async ({title, message} : {title?: string, message: string}) => {
    const alert = await alertController.create({
      header: title,
      //subHeader: 'Important message',
      message,
      buttons: ['OK'],
      mode: 'ios'
    });

    await alert.present();
  };
export function errorHandler(e: any, message = "Something went wrong", force = false){
    const msg: string = force ? message : (e.response?.data ?? message);
        showToast({msg: msg.replace('tuned:', ''), cssClass: 'ion-danger', duration: 1500}  );
}

export function toHome(){
    location.href = '/'
}