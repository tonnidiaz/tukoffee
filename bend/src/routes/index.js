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
const multer_1 = __importDefault(require("multer"));
const models_1 = require("../models");
const functions_1 = require("../utils/functions");
var router = express_1.default.Router();
const fs_1 = __importDefault(require("fs"));
const os_1 = __importDefault(require("os"));
const constants_1 = require("../utils/constants");
const middleware_1 = require("../utils/middleware");
const axios_1 = __importDefault(require("axios"));
const car_1 = require("../models/car");
const review_1 = require("@/models/review");
/* GET home page. */
router.get("/", function (req, res, next) {
    console.log(os_1.default.arch());
    res.render("index", { title: "Express" });
});
router.get('/map', (req, res) => {
    res.render("map");
});
router.get("/payment", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    res.render("payment");
}));
router.get("/clean", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    try {
        const { cancelled } = req.query;
        // clean carts
        console.log("Cleaning carts");
        const carts = yield models_1.Cart.find().exec();
        for (let cart of carts) {
            const user = yield models_1.User.findById(cart.customer).exec();
            if (!user)
                yield models_1.Cart.findByIdAndDelete(cart._id).exec();
            else {
                cart.products = (yield cart.populate("products")).products.filter((it) => it.product != null);
                yield cart.save();
            }
        }
        // clean orders
        console.log("Cleaning orders");
        const orders = yield models_1.Order.find().exec();
        for (let order of orders) {
            const user = yield models_1.User.findById(order.customer).exec();
            if (!user)
                yield models_1.Order.findByIdAndDelete(order._id).exec();
            if (cancelled && order.status == constants_1.OrderStatus.cancelled) {
                //console.log(order._id)
                const u = yield models_1.User.findById(order.customer).exec();
                if (!u)
                    continue;
                const newOrders = (_a = u.orders) === null || _a === void 0 ? void 0 : _a.filter(o => { return o.toString() != order._id.toString(); });
                yield models_1.Order.findByIdAndDelete(order._id).exec();
                u.orders = newOrders;
                yield u.save();
            }
            else {
                order.products = (yield order.populate("products")).products.filter((it) => it.product != null);
                yield order.save();
            }
        }
        console.log('Cleaning products');
        for (let prod of yield models_1.Product.find().exec()) {
            const revs = (_b = prod.reviews) !== null && _b !== void 0 ? _b : [];
            for (let rev of revs) {
                // Search for review with the id, if no exist, rm it from product
                if (!(yield models_1.Review.findById(rev).exec())) {
                    prod.reviews = prod.reviews.filter(it => it != rev);
                }
            }
            yield prod.save();
        }
        //Clean reviews
        for (let rev of yield models_1.Review.find().exec()) {
            if (rev.status == '0') {
                rev.status = review_1.EReviewStatus.pending;
            }
            else if (rev.status == '1') {
                rev.status = review_1.EReviewStatus.approved;
            }
            else if (rev.status == '2') {
                rev.status = review_1.EReviewStatus.rejected;
            }
            yield rev.save();
        }
        res.send("cleanup complete!");
    }
    catch (e) {
        console.log(e);
        res.status(500).json({ msg: "something went wrong" });
    }
}));
router.post("/update-field", (0, multer_1.default)().none(), (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { coll } = req.query;
    const { fields, f } = req.body;
    try {
        let db;
        switch (coll) {
            case "order":
                db = models_1.Order;
                break;
            case "cart":
                db = models_1.Cart;
                break;
            case "user":
                db = models_1.User;
                break;
            case "address":
                break;
            case "product":
                db = models_1.Product;
                break;
        }
        console.log(db);
        if (db) {
            /*"delivery_address.town" : "delivery_address.surbub",
    "delivery_address.province" : "delivery_address.state" */
            yield db
                .updateMany({}, {
                $rename: JSON.parse(fields),
            })
                .exec();
        }
        res.send("Ok");
    }
    catch (e) {
        console.log(e);
        res.status(500).json({ msg: "something went wrong" });
    }
}));
const jsonPath = __dirname + '/../assets/store.json'; //path.join(__dirname, "assets", "store.json");
router.get("/store", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const buff = fs_1.default.readFileSync(jsonPath, { encoding: "utf-8" });
    res.json(JSON.parse(buff));
}));
router.post("/store/update", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { data } = req.body;
        const buff = fs_1.default.readFileSync(jsonPath, { encoding: "utf-8" });
        const details = JSON.parse(buff);
        for (let key of Object.keys(data)) {
            details[key] = data[key];
        }
        fs_1.default.writeFileSync(jsonPath, JSON.stringify(details));
        res.json({
            store: JSON.parse(fs_1.default.readFileSync(jsonPath, { encoding: "utf-8" })),
        });
    }
    catch (e) {
        console.log(e);
        res.status(500).send("Something went wrong");
    }
}));
router.post("/encode", constants_1.parser, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const data = req.body;
        console.log(data);
        const token = (0, functions_1.genToken)(data);
        res.send(token);
    }
    catch (e) {
        console.log(e);
        res.status(500).send("swr");
    }
}));
router.get("/send-sms", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
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
                "X-RapidAPI-Key": process.env.INTELTECH_API_KEY,
                "X-RapidAPI-Host": "inteltech.p.rapidapi.com",
            },
            data: encodedParams,
        };
        const response = yield axios_1.default.request(options);
        console.log(response.data);
        res.send("ok");
    }
    catch (e) {
        console.log(e);
        return res.status(500).send("tuned:Something went wrong");
    }
}));
router.post('/cloudinary', middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { act, publicId, product } = req.body;
        if (act == 'del') {
            const r = yield (0, functions_1.delCloudinary)(publicId);
            console.log(r);
            if (product) {
                const _product = yield models_1.Product.findById(product).exec();
                _product.images = _product.images.filter(it => it.publicId != publicId);
                yield _product.save();
            }
        }
        res.send('Ok');
    }
    catch (e) {
        console.log(e);
        return (0, functions_1.tunedErr)(res, 500, 'Something went wrong');
    }
}));
router.get('/migrate', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const stores = yield models_1.Store.find().exec();
        //let ord = await Order.findOne({status: }).exec()
        //await Order.deleteMany({status: OrderStatus.cancelled}).exec()
        for (let store of stores) {
            /*  store.open_time_weekend = store.open_time_weekends
             store.close_time_weekend = store.close_time_weekends */
            yield store.save();
        }
        res.send('OK');
    }
    catch (e) {
        console.log(e);
        return (0, functions_1.tunedErr)(res, 500, 'Failed to migrate');
    }
}));
router.get('/cars', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const cars = yield car_1.Car.find().exec();
    res.json({ cars: cars.map(c => c.toJSON()) });
}));
router.post('/car', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const car = new car_1.Car();
        for (let key of Object.keys(req.body)) {
            car[key] = req.body[key];
        }
        yield car.save();
        res.send("CAR GOT");
    }
    catch (e) {
        console.log(e);
        return (0, functions_1.tunedErr)(res, 500, 'Failed to migrate');
    }
}));
exports.default = router;
