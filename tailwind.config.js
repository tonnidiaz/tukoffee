/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{vue,js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {},
    },
    plugins: [require("daisyui")],
    daisyui: {
        themes: ["light", "winter", "cupcake", "bumblebee", 'cymk',
        {tu: {
            "primary": "#f9dc68",
           
            "secondary": "#59db69",
                     
            "accent": "#a37af4",
                     
            "neutral": "#1c1b23",
                     
            "base-100": "#ffffff",
                     
            "info": "#577bef",
                     
            "success": "#0d5948",
                     
            "warning": "#ebab4c",
                     
            "error": "#ea8b7b",
                     }},],

    }
};
