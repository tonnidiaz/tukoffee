import axios from "axios";

export const localhost = "http://172.16.10.204";
export const nodeEnv = process.env.NODE_ENV
export const __DEV__ = process.env.NODE_ENV  == 'development'
export const apiURL = !__DEV__? "https://tukoffee.vercel.app":`${localhost}:8000`
export const tbURL = async () =>{
   
    let url = ""
    if (__DEV__){
        url =  `${localhost}:3000`
    }
    else{
        const res = await axios.get('https://raw.githubusercontent.com/tonnidiaz/tunedapps/main/meta.json')
        url = res.data.baseURL
    }
    console.log(url)
    return  url
} 
export const apiAxios = axios.create({baseURL: apiURL,headers:{
    Authorization: `Bearer ${localStorage.getItem('authToken')}`
}})
export const paystackSecretKeyDemo =
"sk_test_7c31366f091fd9bddfc2126935832309c7525f18";
export const paystackSecretKey = "sk_live_8e1e2765c345025d2261662f71d284f61ebac80f";
export const paystackPKey = "pk_live_5ea12fa15af1e3e86bc5b3e8e8e1cde2196b590b"
export const paystackPKeyDemo = "pk_test_dc0fe4e1a7040b36a88fc87e648e97c122292a13"

export const mapboxPublicToken =
"pk.eyJ1IjoidG9ubmlkaWF6IiwiYSI6ImNsbTg5YTk1eTBhaHczZHJyYmR1ZHhsM2cifQ.ockDRt9KPFkge-1zeyDhhA";
 
export const CLOUDINARY_CLOUD_NAME="sketchi",
CLOUDINARY_API_KEY="262393494665286",
CLOUDINARY_SECRET="eQKKfmQ__WkvkCoPaUScVsqbj_o"
export const reviewStatuses = ["pending", "approved", "rejected"];