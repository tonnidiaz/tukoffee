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
const express_1 = __importDefault(require("express"));
const router = express_1.default.Router();
const bcrypt_1 = __importDefault(require("bcrypt"));
const models_1 = require("../../models");
const functions_1 = require("../../utils/functions");
const middleware_1 = require("../../utils/middleware");
const constants_1 = require("../../utils/constants");
const otp_1 = __importDefault(require("./otp"));
const password_1 = __importDefault(require("./password"));
const importantEmails = ["tonnidiazed@gmail.com", "clickbait4587@gmail.com", "openbytes@yahoo.com"];
router.post("/signup", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { body, query } = req;
        //Email not required / not yet verified
        //Find user by number and add the other fields
        //Save user ,gen token
        if (query.act == 'complete') {
            const user = yield models_1.User.findOne({ email: body.email }).exec();
            for (let k of Object.keys(body)) {
                user.set(k, body[k]);
            }
            yield user.save();
            const token = (0, functions_1.genToken)({ id: user._id });
            return res.json({ token });
        }
        // Delete existing user with unverified number
        yield models_1.User.findOneAndDelete({ phone: body.phone, phone_verified: false }).exec();
        // Delete existing user with unverified email
        yield models_1.User.findOneAndDelete({ email: body.email, email_verified: false }).exec();
        if (yield models_1.User.findOne({ phone: body.phone, phone_verified: true }).exec())
            return (0, functions_1.tunedErr)(res, 400, 'User already with same number already exists');
        if (yield models_1.User.findOne({ email: body.email, email_verified: true }).exec())
            return (0, functions_1.tunedErr)(res, 400, 'User already with same email already exists');
        const user = new models_1.User();
        for (let key of Object.keys(body)) {
            if (key == 'password')
                user.password = bcrypt_1.default.hashSync(body[key], 10);
            else {
                user[key] = body[key];
            }
        }
        const otp = (0, functions_1.randomInRange)(1000, 9999);
        console.log(otp);
        user.otp = otp;
        yield (0, functions_1.sendMail)("Tukoffee Verification Email", `<h2 style="font-weight: 500">Here is your signup verification One-Time-PIN:</h2>
                    <p style="font-size: 20px; font-weight: 600">${user.otp}</p>
                `, user.email);
        // Send the otp && save user
        if (body.phone) {
            const number = body.phone.startsWith("+")
                ? body.phone
                : "+27" + body.phone.slice(1);
        }
        // const smsRes = await sendSMS(number, `Tukoffee - your code is: ${otp}`)
        //console.log(smsRes.data)
        yield user.save();
        res.json({ msg: "OTP Generated" });
        /*
            Verify email route
            if (importantEmails.indexOf(email) != -1)
                user.permissions = UserPermissions.delete;
            await user.save(); */
    }
    catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.post("/login", middleware_1.lightAuth, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email, password, phone } = req.body;
        if (req.user && !password) {
            //Loging in with token
            res.json({ user: Object.assign({}, req.user.toJSON()) });
            return;
        }
        else if (phone && password) {
            let user = yield models_1.User.findOne({ phone }).exec();
            if (user) {
                const passValid = bcrypt_1.default.compareSync(password, user.password);
                if (!passValid)
                    return res.status(401).send("tuned:Incorrect password.");
                const token = (0, functions_1.genToken)({ id: user._id });
                res.json({ user: Object.assign({}, user.toJSON()), token });
            }
            else
                return (0, functions_1.tunedErr)(res, 400, 'Account does not exist');
        }
        else if (email && password) {
            const user = yield models_1.User.findOne({ email }).exec();
            if (!user)
                return res.status(401).send("tuned:Account does not exists.");
            const passValid = bcrypt_1.default.compareSync(password, user.password);
            if (!passValid)
                return res.status(401).send("tuned:Incorrect password.");
            const token = (0, functions_1.genToken)({ id: user._id });
            res.json({ user: Object.assign(Object.assign({}, user.toJSON()), { password: password }), token });
        }
        else {
            res.status(400).send("tuned:Provide all fields");
        }
    }
    catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.post("/verify-email", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { email, otp } = req.body;
    try {
        const user = yield models_1.User.findOne({ email }).exec();
        if (!user)
            return (0, functions_1.tunedErr)(res, 400, "Restart the signup process");
        if (!otp) {
            const pin = (0, functions_1.randomInRange)(1000, 9999);
            //TODO: Send real pin
            console.log(pin);
            user.otp = pin;
        }
        else {
            if (user.otp == otp) {
                user.email_verified = true;
                if (importantEmails.includes(email))
                    user.permissions = constants_1.UserPermissions.delete;
            }
            else {
                return res.status(400).send("tuned:Incorrect OTP");
            }
        }
        yield user.save();
        res.json({ user: user.toJSON() });
    }
    catch (e) {
        console.log(e);
        res.status(500).send('tuned:Something went wrong');
    }
}));
router.use("/password", password_1.default);
router.use("/otp", otp_1.default);
exports.default = router;
