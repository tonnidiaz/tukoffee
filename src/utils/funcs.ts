import { apiAxios } from "./constants";

export function randomIntFromInterval(min: number, max: number) {
    // min and max included
    return Math.floor(Math.random() * (max - min + 1) + min);
  }
export const randomImg = ()=>{
    return `https://picsum.photos/80/80?random=${randomIntFromInterval(1, 100)}`
}
export const setupCart = async (phone: string, userStore: any) => { 
    try{
        userStore.setCart(null)
        console.log('Setting up cart...')
        const res  = await apiAxios.get(`/user/cart?user=${phone}`)
        userStore.setCart(res.data.cart)
        return res.data.cart
    }catch(e){
        console.log(e)
        return null
    }
 }
 export const testClick = (e: any) => { console.log(`Clicked:`, e.target) }
 export function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}