const express = require("express");
const multer = require("multer");
const { Order, Cart, User, Product } = require("../models");
const { AddressSchema } = require("../models/user");
const { genToken } = require("../utils/functions");
var router = express.Router();
const fs = require("fs");
const path = require("path");
const os = require("os");
const { parser } = require("../utils/constants");
const { auth } = require("../utils/middleware");

/* GET home page. */
router.get("/", function (req, res, next) {
    console.log(os.arch());
    res.render("index", { title: "Express" });
});

router.get('/map', (req,res)=>{
    res.render("map")
})
router.get("/payment", async (req, res) => {
    res.render("payment");
});
router.get("/clean", async (req, res) => {
    try {
        // clean carts
        console.log("Cleaning carts");
        const carts = await Cart.find().exec();
        for (let cart of carts) {
            const user = await User.findById(cart.customer).exec();
            if (!user) await Cart.findByIdAndDelete(cart._id).exec();
            else {
                cart.products = (
                    await cart.populate("products")
                ).products.filter((it) => it.product != null);
                await cart.save();
            }
        }
        // clean orders
        console.log("Cleaning orders");
        const orders = await Order.find().exec();
        for (let order of orders) {
            const user = await User.findById(order.customer).exec();
            if (!user) await Order.findByIdAndDelete(order._id).exec();
            else {
                order.products = (
                    await order.populate("products")
                ).products.filter((it) => it.product != null);
                await order.save();
            }
        }
        res.send("cleanup complete!");
    } catch (e) {
        res.status(500).json({ msg: "something went wrong" });
    }
});
router.post("/update-field", multer().none(), async (req, res) => {
    const { coll } = req.query;
    const { fields, f } = req.body;
    try {
        let db;
        switch (coll) {
            case "order":
                db = Order;
                break;
            case "cart":
                db = Cart;
                break;
            case "user":
                db = User;
                break;
            case "address":
                db = Address;
                break;
            case "product":
                db = Product;
                break;
        }
        console.log(db);
        if (db) {
            /*"delivery_address.town" : "delivery_address.surbub",
    "delivery_address.province" : "delivery_address.state" */
            await db
                .updateMany(
                    {},
                    {
                        $rename: JSON.parse(fields),
                    }
                )
                .exec();
        }

        res.send("Ok");
    } catch (e) {
        console.log(e);
        res.status(500).json({ msg: "something went wrong" });
    }
});
const baseDir = path.resolve("./");
const jsonPath = path.join(baseDir, "assets", "store.json");
router.get("/store", async (req, res) => {
    const buff = fs.readFileSync(jsonPath, { encoding: "utf-8" });
    res.json(JSON.parse(buff));
});
router.post("/store/update", auth, async (req, res) => {
    try {
        const { data } = req.body;
        const buff = fs.readFileSync(jsonPath, { encoding: "utf-8" });
        const details = JSON.parse(buff);
        for (let key of Object.keys(data)) { 
            details[key] = data[key];
        }
        fs.writeFileSync(jsonPath, JSON.stringify(details));
        res.json({
            store: JSON.parse(fs.readFileSync(jsonPath, { encoding: "utf-8" })),
        });
    } catch (e) {
        console.log(e);
        res.status(500).send("Something went wrong");
    }
});

router.post("/encode", parser, async (req, res) => {
    try {
        const data = req.body;
        console.log(data);
        const token = genToken(data);
        res.send(token);
    } catch (e) {
        console.log(e);
        res.status(500).send("swr");
    }
});

const axios = require("axios");

router.get("/send-sms", async (req, res) => {
    try {
        const encodedParams = new URLSearchParams();
        encodedParams.set("sms", "+27726013383");
        encodedParams.set("message", "Tukoffe - Your verification code is: 45784");
        encodedParams.set("key", "B486ED40-95DB-DCA4-E62D-7F395776F89B");
        encodedParams.set("username", "clickbait4587");

        const options = {
            method: "POST",
            url: "https://inteltech.p.rapidapi.com/send.php",
            headers: {
                "content-type": "application/x-www-form-urlencoded",
                "X-RapidAPI-Key":
                    "71e962e760mshe177840eb7630a1p1ce7a7jsncff43c280599",
                "X-RapidAPI-Host": "inteltech.p.rapidapi.com",
            },
            data: encodedParams,
        };
            const response = await axios.request(options);
            console.log(response.data);
 
        res.send("ok");
    } catch (e) {
        console.log(e);
        return res.status(500).send("tuned:Something went wrong");
    }
});
module.exports = router;
