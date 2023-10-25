"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.tunedErr = exports.randomInRange = exports.genOTP = exports.parseProducts = exports.sendSMS = exports.delCloudinary = exports.genToken = exports.getStoreDetails = exports.sendMail = void 0;
const otp_1 = require("../models/otp");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const cloudinary = require('cloudinary').v2;
const nodemailer_1 = __importDefault(require("nodemailer"));
const fs_1 = __importDefault(require("fs"));
const { env } = process;
function configCloudinary() {
    cloudinary.config({
        api_secret: env.CLOUDINARY_SECRET_KEY,
        api_key: env.CLOUDINARY_API_KEY,
        cloud_name: 'sketchi'
    });
}
function randomInRange(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}
exports.randomInRange = randomInRange;
const genToken = (data, exp) => {
    const { PRIVATE_KEY } = process.env;
    return exp
        ? jsonwebtoken_1.default.sign({
            data,
        }, PRIVATE_KEY, { expiresIn: exp })
        : jsonwebtoken_1.default.sign({ payload: data }, PRIVATE_KEY);
};
exports.genToken = genToken;
const genOTP = (phone, email) => __awaiter(void 0, void 0, void 0, function* () {
    const pin = randomInRange(1000, 9999);
    const otp = new otp_1.OTP();
    otp.pin = pin;
    if (phone)
        otp.phone = phone;
    else
        otp.email = email;
    yield otp.save();
    return otp;
});
exports.genOTP = genOTP;
const parseProducts = (products) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    let data = [];
    for (let prod of products) {
        let rating = 0;
        let revs = prod.reviews;
        // Clear the reviews
        prod.reviews = [];
        for (let revId of revs) {
            console.log(revId);
            const rev = yield models_1.Review.findOne({ _id: revId, status: review_1.EReviewStatus.approved }).exec();
            if (rev) {
                rating += rev.rating;
                prod.reviews.push(rev._id);
            }
        }
        if ((_a = prod.reviews) === null || _a === void 0 ? void 0 : _a.length) {
            rating = (rating / (prod.reviews.length)).toFixed(1);
        }
        data.push(Object.assign(Object.assign({}, prod.toJSON()), { rating }));
    }
    return data;
});
exports.parseProducts = parseProducts;
const axios_1 = __importDefault(require("axios"));
const models_1 = require("../models");
const review_1 = require("../models/review");
const sendSMS = (number, message) => __awaiter(void 0, void 0, void 0, function* () {
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
            "X-RapidAPI-Key": process.env.INTELTECH_API_KEY,
            "X-RapidAPI-Host": "inteltech.p.rapidapi.com",
        },
        data: encodedParams,
    };
    return yield axios_1.default.request(options);
});
exports.sendSMS = sendSMS;
const tunedErr = (res, status, msg, e) => {
    if (e) {
        console.log(e);
    }
    return res.status(status).send(`tuned:${msg}`);
};
exports.tunedErr = tunedErr;
const delCloudinary = (publicId) => __awaiter(void 0, void 0, void 0, function* () {
    configCloudinary();
    return yield cloudinary.uploader.destroy(publicId);
});
exports.delCloudinary = delCloudinary;
const sendMail = (subject, body, clients, sender) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        // create reusable transporter object using the default SMTP transport
        let transporter = nodemailer_1.default.createTransport({
            host: process.env.GMAIL_HOST,
            port: Number(process.env.GMAIL_PORT),
            secure: false,
            auth: {
                user: process.env.EMAIL,
                pass: process.env.GMAIL_PASSWORD, //testAccount.pass, // generated ethereal password
            },
        });
        const storeDetails = getStoreDetails();
        // send mail with defined transport object
        const _sender = sender !== null && sender !== void 0 ? sender : storeDetails.store.email;
        console.log('SENDING FROM: ', _sender);
        console.log('SENDING MAIL TO: ', clients);
        let info = yield transporter.sendMail({
            from: `"${storeDetails.store.name}" <${_sender}>`,
            to: `"${clients}"`,
            subject,
            html: `<html lang="en">
          <head>
              <meta charset="UTF-8">
              <meta http-equiv="X-UA-Compatible" content="IE=edge">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style type="text/css">
              .tb {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif  !important;
                margin: auto;
                padding: 10px;
                color: black;
              }
        
              .btn {
                cursor: pointer;
                display: inline-block;
                min-height: 1em;
                outline: 0;
                border: none;
                vertical-align: baseline;
                background: #e0e1e2 none;
                color: rgba(0, 0, 0, 0.6);
                font-family: Lato, "Helvetica Neue", Arial, Helvetica, sans-serif;
                margin: 0 0.25em 0 0;
                padding: 10px 16px;
                text-transform: none;
                text-shadow: none;
                font-weight: 600;
                line-height: 1em;
                font-style: normal;
                text-align: center;
                text-decoration: none;
                border-radius: 0.28571429rem;
                box-shadow: inset 0 0 0 1px transparent,
                  inset 0 0 0 0 rgba(34, 36, 38, 0.15);
                -webkit-user-select: none;
                -ms-user-select: none;
                user-select: none;
                transition: opacity 0.1s ease, background-color 0.1s ease,
                  color 0.1s ease, box-shadow 0.1s ease, background 0.1s ease;
                will-change: "";
                -webkit-tap-highlight-color: transparent;
              }
              .btn-primary {
                color: #fff !important;
                background-color: #0d6efd !important;
                border-color: #0d6efd !important;
              }
              .btn-danger {
                color: #fff !important;
                background-color: #fd950d !important;
                border-color: #fd950d !important;
              }
        a{
          color: #f08800 !important;
          font-weight: 600 !important;
        }
              table {
               
               
                width: 100%;
                
                border-radius: 10px !important;
                padding: 5px;
                border-collapse: collapse;
              }
        
              td,
              th {
                border: 2px solid #8f8f8f;
                text-align: left;
                padding: 8px;
              }
        
              tr:nth-child(even) {
                background-color: #e6e6e6;
              }
        
              .otp {
                background-color: #c4c4c4;
                border: 2px dashed #d37305;
                padding: 10px;
                border-radius: 5px;
                width: 150px;
                text-align: center;
                font-weight: 700;
                letter-spacing: 6;
                font-family: monospace;
                font-size: 20px;
              }
              .text-c{
                text-align: center !important;
              }

              .m-auto{
                margin: 0 auto;
              }
            </style>
          </head>
          <body>
  
              <div class="tb text-c">
              ${body}
              <p>For support please contact the Developer at <a href="mailto:${storeDetails.developer.email}">${storeDetails.developer.email}</a></p>
              </div>
  
          </body>
          </html>
                `, // html body
        });
        console.log("Message sent: %s", info.messageId);
        // Message sent: <b658f8ca-6296-ccf4-8306-87d57a0b4321@example.com>
        return "Email sent";
    }
    catch (err) {
        console.log(err);
        return null;
    }
});
exports.sendMail = sendMail;
const jsonPath = __dirname + '/../assets/store.json';
const getStoreDetails = () => {
    const buff = fs_1.default.readFileSync(jsonPath, { encoding: "utf-8" });
    return JSON.parse(buff);
};
exports.getStoreDetails = getStoreDetails;
