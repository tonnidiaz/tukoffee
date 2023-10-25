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
const models_1 = require("../models");
const functions_1 = require("../utils/functions");
const middleware_1 = require("../utils/middleware");
const constants_1 = require("../utils/constants");
const review_1 = require("../models/review");
const router = express_1.default.Router();
const genPID = () => __awaiter(void 0, void 0, void 0, function* () {
    const pid = Math.floor(Math.random() * 999999) + 1;
    const exists = yield models_1.Product.findOne({ pid }).exec();
    if (exists != null)
        return genPID();
    return pid;
});
router.get("/", middleware_1.lightAuth, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const args = req.query;
    const { pid, q } = args;
    try {
        let prods = pid && !q
            ? yield models_1.Product.find({ pid }).exec()
            : yield models_1.Product.find().exec();
        switch (q) {
            case "top-selling":
                prods = prods.filter((it) => it.top_selling);
                break;
            case "special":
                prods = prods.filter((it) => it.on_special);
                break;
            case "sale":
                prods = prods.filter((it) => it.on_sale);
                break;
            case "received":
                let orders = yield models_1.Order.find({
                    customer: req.user._id,
                    status: constants_1.OrderStatus.completed,
                }).exec();
                orders = yield Promise.all(orders.map((it) => __awaiter(void 0, void 0, void 0, function* () { return (yield it.populate("products.product")).populate('products.product.reviews'); }))); //
                return res.json(orders.map((it) => {
                    return {
                        date: it.last_modified,
                        items: it.products
                            .map((p) => p.product)
                            .filter((it) => it),
                    };
                }));
        }
        let data = yield (0, functions_1.parseProducts)(prods);
        res.json({ data });
    }
    catch (err) {
        console.log(err);
        res.status(500).json({ msg: "Something went wrong" });
    }
}));
router.post("/add", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const body = req.body;
        const prod = new models_1.Product();
        for (let key of Object.keys(body)) {
            prod[key] = body[key];
        }
        prod.pid = yield genPID();
        yield prod.save();
        console.log("Product added!");
        res.json({ pid: prod.pid });
    }
    catch (err) {
        console.log(err);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.get("/reviews", middleware_1.lightAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id, pid, user, ids } = req.query;
        let reviews = [];
        if (pid)
            reviews = yield models_1.Review.find({ product: pid }).exec();
        else if (id)
            reviews = [(yield models_1.Review.findById(id).exec())];
        else if (user)
            reviews = yield models_1.Review.find({ user }).exec();
        else {
            reviews = yield models_1.Review.find().exec();
        }
        reviews = yield Promise.all(reviews.map((it) => __awaiter(void 0, void 0, void 0, function* () { return (yield it.populate("product")).toJSON(); })));
        res.json({ reviews });
    }
    catch (error) {
        console.log(error);
        return (0, functions_1.tunedErr)(res, 500, "Something went wrong");
    }
}));
router.post("/review", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { act } = req.query;
        const { pid, id, review, ids } = req.body;
        if (act == "add") {
            const prod = (_a = (yield models_1.Product.findOne({ pid }).exec())) !== null && _a !== void 0 ? _a : (yield models_1.Product.findById(id).exec());
            if (!prod)
                return (0, functions_1.tunedErr)(res, 404, "Product not found");
            const _review = new models_1.Review();
            for (let key of Object.keys(review)) {
                _review.set(key, review[key]);
            }
            _review.product = prod._id;
            _review.user = req.user._id;
            yield _review.save();
            prod.reviews.push(_review._id);
            yield prod.save();
            return res.json({ reviews: prod.reviews.map(e => e.toJSON()) });
        }
        else if (act == "edit") {
            const rev = yield models_1.Review.findById(id).exec();
            if (!rev)
                return res.status(400).send("Bad request");
            for (let key of Object.keys(review)) {
                rev.set(key, review[key]);
            }
            if (!review.status) {
                rev.status = review_1.EReviewStatus.pending;
            }
            rev.last_modified = new Date();
            yield rev.save();
        }
        else if (act == 'del') {
            if (ids) {
                for (let id of ids) {
                    const rev = yield models_1.Review.findById(id).exec();
                    yield models_1.Review.findByIdAndDelete(id).exec();
                    const prod = yield models_1.Product.findById(rev.product).exec();
                    prod.reviews = prod.reviews.filter(it => it != id);
                    yield prod.save();
                }
            }
            else {
                yield models_1.Review.findByIdAndDelete(id).exec();
            }
        }
        let revs = yield models_1.Review.find().exec();
        revs = yield Promise.all(revs.map((it) => __awaiter(void 0, void 0, void 0, function* () { return (yield it.populate('product')).toJSON(); })));
        res.json({ reviews: revs });
    }
    catch (e) {
        console.log(e);
        (0, functions_1.tunedErr)(res, 500, "Something went wrong");
    }
}));
router.post("/edit", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _b;
    try {
        const { body } = req;
        const prod = (_b = (yield models_1.Product.findOne({ pid: body.pid }).exec())) !== null && _b !== void 0 ? _b : (yield models_1.Product.findById(body.id).exec());
        if (!prod)
            return res.status(404).json({ msg: "Product not found" });
        for (let key of Object.keys(body)) {
            prod[key] = body[key];
        }
        prod.last_modified = new Date();
        yield prod.save();
        console.log("Product edited!");
        res.json({ pid: prod.pid });
    }
    catch (err) {
        console.log(err);
        res.status(500).send("tuned:Something went wrong");
    }
}));
router.post("/delete", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { pid } = req.query;
        const { pids } = req.body;
        if (pid) {
            const product = yield models_1.Product.findOneAndRemove({ pid }).exec();
            if (!product)
                return res.status(404).send("tuned:Product not found!");
            res.status(200).send("Product deleted successfully!");
        }
        else if (pids) {
            for (let _pid of pids) {
                try {
                    yield models_1.Product.findOneAndRemove({ pid: _pid }).exec();
                }
                catch (e) {
                    console.log(e);
                    continue;
                }
            }
            const newProducts = yield models_1.Product.find().exec();
            return res.json({ products: yield (0, functions_1.parseProducts)(newProducts) });
        }
    }
    catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong!");
    }
}));
exports.default = router;
