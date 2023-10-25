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
const models_1 = require("../models");
const middleware_1 = require("../utils/middleware");
const bcrypt_1 = __importDefault(require("bcrypt"));
const constants_1 = require("../utils/constants");
const functions_1 = require("../utils/functions");
const express_1 = require("express");
const router = (0, express_1.Router)();
/* GET users listing. */
router.get("/", (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const { email, id } = req.query;
    let user;
    user = email
        ? yield models_1.User.findOne({ email }).exec()
        : yield models_1.User.findById(id).exec();
    res.json({ user: user.toJSON() });
}));
router.get("/cart", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { user } = req.query;
        //const _user = await User.findById(user).exec();
        const cart = yield models_1.Cart.findOne({ customer: user }).exec();
        if (!cart)
            return res.status(404).send("tuned:Cart not found");
        let c = yield cart.populate("products.product");
        c = Object.assign(Object.assign({}, c.toJSON()), { products: c.products.filter((it) => it.product != null && it.product.quantity > 0) });
        res.json({ cart: c });
    }
    catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.post("/cart", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { action } = req.query;
        const { product, quantity } = req.body;
        console.log(product, action, quantity);
        const _user = req.user;
        let cart = null;
        if (_user.cart) {
            cart = (_a = (yield models_1.Cart.findById(_user.cart).exec())) !== null && _a !== void 0 ? _a : new models_1.Cart();
        }
        else {
            cart = new models_1.Cart();
        }
        if (action == "add") {
            cart.customer = _user._id;
            const prod = cart.products.find((it) => it.product == product);
            if (!prod) {
                console.log("Adding");
                //add product to cart if the cart does not have the product
                console.log(product);
                //cart.products.push({ product: product });
            }
            else if (prod && quantity) {
                // Increase the product's quantiry
                prod.quantity = quantity;
            }
            yield cart.save();
            _user.cart = cart._id;
            yield _user.save();
            //let c = await cart.populate("products.product")
            let c = yield cart.populate("products.product");
            c = Object.assign(Object.assign({}, c.toJSON()), { products: c.products.filter((it) => it.product != null && it.product.quantity > 0), customer: {} });
            res.json({ cart: c });
        }
        else if (action == "remove") {
            if (_user.cart) {
                cart.products = cart.products.filter((it) => it.product != product);
                yield cart.save();
                let c = yield cart.populate("products.product");
                c = Object.assign(Object.assign({}, c.toJSON()), { products: c.products.filter((it) => it.product != null && it.product.quantity > 0), customer: {} });
                res.json({ cart: c });
            }
            else
                res.status(400).send("tuned:User has no cart");
        }
        else if (action == 'clear') {
            cart.products = [];
            yield cart.save();
            let c = yield cart.populate("products.product");
            c = Object.assign(Object.assign({}, c.toJSON()), { products: c.products.filter((it) => it.product != null && it.product.quantity > 0), customer: {} });
            res.json({ cart: c });
        }
    }
    catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.post("/delivery-address", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { action } = req.query;
        const { address } = req.body;
        let u = req.user;
        if (action == "add") {
            if (!address)
                return res.status(400).send("tuned:Provide address");
            u.delivery_addresses.push(address);
        }
        else {
            u.delivery_addresses = u.delivery_addresses.filter((it) => it["_id"] != address["_id"]);
        }
        yield u.save();
        res.json({ user: u.toJSON() });
    }
    catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.post("/edit", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { field } = req.query;
        const { value, userId, data } = req.body;
        console.log(userId);
        const _user = userId ? yield models_1.User.findById(userId).exec() : req.user;
        if (!field) {
            for (let key of Object.keys(value)) {
                _user[key] = value[key];
            }
        }
        else {
            if (field == 'email') {
                // Check password
                if (!bcrypt_1.default.compareSync(data.password, _user.password))
                    return (0, functions_1.tunedErr)(res, 401, 'Incorrect password');
                _user.new_email = data.email;
                const otp = (0, functions_1.randomInRange)(1000, 9999);
                _user.otp = otp;
                if (constants_1.DEV)
                    console.log(otp);
                yield (0, functions_1.sendMail)("Tukoffee Verification Email", `<h2 style="font-weight: 500">Here is your Email verification One-Time-PIN:</h2>
                    <p style="font-size: 20px; font-weight: 600">${_user.otp}</p>
                `, _user.new_email);
            }
            else {
                _user[field] = value;
            }
        }
        yield _user.save();
        res.json({ user: _user.toJSON() });
    }
    catch (error) {
        console.log(error);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.post("/delete", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { password } = req.body;
        const passValid = bcrypt_1.default.compareSync(password, req.user.password);
        if (!passValid) {
            return res.status(401).send("tuned:Incorrect password!");
        }
        // delete the user
        yield models_1.User.findByIdAndDelete(req.user._id).exec();
        res.send("tuned:Account deleted successfully!");
    }
    catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
}));
exports.default = router;
