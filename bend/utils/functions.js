const { OTP } = require("../models/otp");
const jwt = require("jsonwebtoken");
const cloudinary = require('cloudinary').v2

const { env } = process

function configCloudinary(){
    cloudinary.config({
    api_secret: env.CLOUDINARY_SECRET_KEY,
    api_key: env.CLOUDINARY_API_KEY,
    cloud_name: 'sketchi'
})
}

function randomInRange(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}

const onGetGenToken = async (req, res) => {
    const purchase_units = [
        {
            amount: {
                value: 40,
                currency_code: "USD",
            },
        },
    ];
    const data = { purchase_units };
    const tkn = genToken(data);
    res.send(tkn);
};

const genToken = (data, exp) => {
    const { PRIVATE_KEY } = process.env;
    return exp
        ? jwt.sign(
              {
                  data,
              },
              PRIVATE_KEY,
              { expiresIn: exp }
          )
        : jwt.sign({ payload: data }, PRIVATE_KEY);
};
const genOTP = async (phone, email) => {
    const pin = randomInRange(1000, 9999);
    const otp = new OTP();
    otp.pin = pin;
    if (phone) otp.phone = phone;
    else otp.email = email;
    await otp.save();
    return otp;
};
const parseProducts = (products) => {
    let data = [];
    products.forEach((it) => {
        let r = 0;
        it.ratings.forEach((i) => {
            r += i.value;
        });
        r = r / it.ratings.length;
        data.push({ ...it.toJSON(), rating: r });
    });

    return data;
};
const axios = require("axios");
const sendSMS = async (number, message)=>{
    const encodedParams = new URLSearchParams();
    encodedParams.set("sms", number);
    encodedParams.set("message", message);
    encodedParams.set("key", "B486ED40-95DB-DCA4-E62D-7F395776F89B");
    encodedParams.set("username", "clickbait4587");

    const options = {
        method: "POST",
        url: "https://inteltech.p.rapidapi.com/send.php",
        headers: {
            "content-type": "application/x-www-form-urlencoded",
            "X-RapidAPI-Key":
                process.env.INTELTECH_API_KEY,
            "X-RapidAPI-Host": "inteltech.p.rapidapi.com",
        },
        data: encodedParams,
    };
    return await axios.request(options)
}

const tunedErr = (res, status, msg) => {
    return res.status(status).send(`tuned:${msg}`)
}

const delCloudinary = async (publicId)=>{
    configCloudinary()
    return await cloudinary.uploader.destroy(publicId)
}
module.exports = { genToken, delCloudinary, onGetGenToken, sendSMS, parseProducts, genOTP, randomInRange, tunedErr };
