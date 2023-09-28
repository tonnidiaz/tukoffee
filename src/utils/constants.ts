import axios from "axios";

export const localhost = "http://172.16.10.204";
export const nodeEnv = process.env.NODE_ENV
export const apiURL = process.env.NODE_ENV != "development" ? "https://tukoffee.vercel.app":`${localhost}:8000`
export const apiAxios = axios.create({baseURL: apiURL,headers:{
    Authorization: `Bearer ${localStorage.getItem('authToken')}`
}})

export const mapboxPublicToken =
"pk.eyJ1IjoidG9ubmlkaWF6IiwiYSI6ImNsbTg5YTk1eTBhaHczZHJyYmR1ZHhsM2cifQ.ockDRt9KPFkge-1zeyDhhA";
 
export const CLOUDINARY_CLOUD_NAME="sketchi",
CLOUDINARY_API_KEY="262393494665286",
CLOUDINARY_SECRET="eQKKfmQ__WkvkCoPaUScVsqbj_o"