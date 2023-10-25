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
Object.defineProperty(exports, "__esModule", { value: true });
const router = require("express").Router();
const models_1 = require("../../models");
const constants_1 = require("../../utils/constants");
const functions_1 = require("../../utils/functions");
router.post("/resend", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { phone, email } = req.body;
        const user = phone ? (yield models_1.User.findOne({ phone }).exec()) : email ?
            (yield models_1.User.findOne({ email }).exec()) : null;
        if (!user) {
            return (0, functions_1.tunedErr)(res, 400, "User does not exist");
        }
        const otp = (0, functions_1.randomInRange)(1000, 9999);
        user.otp = otp;
        if (constants_1.DEV)
            console.log(otp);
        const storeDetails = (0, functions_1.getStoreDetails)();
        yield (0, functions_1.sendMail)(`${storeDetails.store.name} Verification Email`, `<h2 style="font-weight: 500">Here is your Email verification One-Time-PIN:</h2>
                    <p class='otp m-auto' style="font-size: 20px; font-weight: 600">${otp}</p>
                `, email);
        yield user.save();
        res.send("OTP endpoint");
    }
    catch (e) {
        console.log(e);
        return (0, functions_1.tunedErr)(res, 500, "Something went wrong");
    }
}));
router.post("/verify", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { phone, email, otp, new_email } = req.body;
    console.log(email);
    let user;
    if (!otp)
        return res.status(400).send("tuned:Please provide OTP.");
    if (phone) {
        // Phone verification
        user = yield models_1.User.findOne({ phone }).exec();
        if (!user)
            return res
                .status(404)
                .send(`tuned:Account with number: ${phone} does not exist!`);
        if (user.otp != otp)
            return res.status(400).send("tuned:Incorrect OTP.");
        user.phone_verified = true;
        user.otp = null;
    }
    else if (email) {
        // Email verification
        user = yield models_1.User.findOne({ email }).exec();
        if (!user)
            return (0, functions_1.tunedErr)(res, 400, `Account with email: ${email} does not exist!`);
        if (user.otp != otp)
            return (0, functions_1.tunedErr)(res, 400, "tuned:Incorrect OTP.");
        user.email_verified = true;
    }
    else if (new_email) {
        user = yield models_1.User.findOne({ new_email }).exec();
        if (!user)
            return (0, functions_1.tunedErr)(res, 400, `Incorrect credentials!`);
        if (user.otp != otp)
            return (0, functions_1.tunedErr)(res, 400, "tuned:Incorrect OTP");
        // Asign new email to email
        user.email = new_email;
    }
    yield user.save();
    const token = (0, functions_1.genToken)({ id: user._id });
    res.json({ user: Object.assign({}, user.toJSON()), token });
}));
exports.default = router;
