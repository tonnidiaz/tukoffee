import axios from "axios";

export const localhost = "http://172.16.10.204";
export const nodeEnv = process.env.NODE_ENV
export const apiURL = process.env.NODE_ENV != "development" ? "https://tukoffee.vercel.app":`${localhost}:8000`
export const apiAxios = axios.create({baseURL: apiURL,headers:{
    Authorization: `Bearer ${localStorage.getItem('authToken')}`
}})