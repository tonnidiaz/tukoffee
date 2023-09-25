import { apiAxios } from "./constants";

export function randomIntFromInterval(min: number, max: number) {
    // min and max included
    return Math.floor(Math.random() * (max - min + 1) + min);
  }
export const randomImg = ()=>{
    return `https://loremflickr.com/g/320/240/tech?random=${randomIntFromInterval(1, 100)}`
}
export const setupCart = async (phone: string, userStore: any) => { 
    try{
        userStore.setCart(null)
        console.log('Setting up cart...')
        const res  = await apiAxios.get(`/user/cart?user=${phone}`)
        userStore.setCart(res.data.cart)
    }catch(e){
        console.log(e)
    }
 }