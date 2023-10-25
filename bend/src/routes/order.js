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
const middleware_1 = require("../utils/middleware");
const constants_1 = require("../utils/constants");
const functions_1 = require("../utils/functions");
const io_1 = __importDefault(require("../utils/io"));
const router = express_1.default.Router();
const genOID = () => __awaiter(void 0, void 0, void 0, function* () {
    const oid = Math.floor(Math.random() * 999999) + 1;
    const exists = yield models_1.Order.findOne({ oid }).exec();
    if (exists != null)
        return genOID();
    return oid;
});
router.post("/cancel", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { ids, userId } = req.body;
    const { action } = req.query;
    try {
        for (let id of ids) {
            try {
                if (action == "delete") {
                    // Remove order from user document
                    const order = yield models_1.Order.findById(id).exec();
                    const user = yield models_1.User.findById(order === null || order === void 0 ? void 0 : order.customer).exec();
                    yield models_1.Order.findByIdAndDelete(id).exec();
                    if (user) {
                        user.orders = user.orders.filter((o) => o != id);
                        yield user.save();
                        console.log(`Order #${id} deleted!`);
                    }
                }
                else {
                    const order = yield models_1.Order.findByIdAndUpdate(id, {
                        status: constants_1.OrderStatus.cancelled,
                        last_modified: new Date(),
                    }).exec();
                    console.log(`Order #${id} cancelled!`);
                    //Update inventory
                    for (let item of order.products) {
                        yield models_1.Product.findByIdAndUpdate(item.product._id, { $inc: {
                                quantity: item.quantity
                            } }).exec();
                    }
                }
            }
            catch (e) {
                console.log(e);
                continue;
            }
        }
        const orders = userId
            ? yield models_1.Order.find({ customer: userId }).exec()
            : yield models_1.Order.find().exec();
        let populatedOrders = [];
        for (let o of orders) {
            let ord = yield (yield o.populate("customer")).populate("products.product");
            populatedOrders.push(ord);
        }
        res.json({ orders: populatedOrders.map((it) => it.toJSON()) });
    }
    catch (e) {
        console.log(e);
        return (0, functions_1.tunedErr)(res, 500, 'Something went wrong');
    }
}));
router.post("/create", middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { cartId, mode } = req.query;
    const { address, store, collector, yocoData, paystackData, form } = req.body;
    try {
        if (cartId) {
            // The customer has paid. so get the cart and create an order
            // Also delete the user cart
            console.log("Creating order for cart: " + cartId);
            let cart = yield models_1.Cart.findById(cartId).exec();
            if (!cart)
                return (0, functions_1.tunedErr)(res, 400, "Carr not found");
            const user = yield models_1.User.findById(cart.customer).exec();
            if (!user)
                return (0, functions_1.tunedErr)(res, 400, "Customer not found");
            cart = yield cart.populate('products.product');
            const order = new models_1.Order();
            order.oid = yield genOID();
            order.customer = user._id;
            order.products = cart.products;
            order.delivery_address = address;
            order.mode = Number(mode);
            order.store = store;
            order.collector = collector;
            order.yocoData = yocoData;
            order.paystackData = paystackData;
            if (form) {
                for (let key of Object.keys(form)) {
                    order.set(key, form[key]);
                }
            }
            yield order.save();
            // add order to user's orders
            user.orders.push(order._id);
            yield user.save();
            //Update inventory
            for (let item of order.products) {
                yield models_1.Product.findByIdAndUpdate(item.product._id, { $inc: {
                        quantity: -item.quantity
                    } }).exec();
            }
            // delete the cart
            yield models_1.Cart.findByIdAndUpdate(cartId, { $set: {
                    products: []
                } }).exec();
            yield cart.save();
            //user.cart = null
            //await user.save()
            console.log("Cart deleted");
            io_1.default.emit('order', order.oid);
            console.log("On order emitted");
            res.json({ order: Object.assign(Object.assign({}, order.toJSON()), { customer: null }) });
        }
        else {
            res.status(400).json({ msg: "Provide cart id" });
        }
    }
    catch (e) {
        console.log(e);
        return (0, functions_1.tunedErr)(res, 500, "Something went wrong");
    }
}));
router.post('/edit', middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.query;
        const { body } = req;
        const order = yield models_1.Order.findById(id).exec();
        if (!order)
            return res.status(404).send("Order not found!");
        for (let key of Object.keys(body)) {
            order[key] = body[key];
        }
        order.last_modified = new Date();
        yield order.save();
        res.json({ id: order.oid, order: yield (yield order.populate("customer")).populate('store') });
    }
    catch (e) {
        (0, functions_1.tunedErr)(res, 500, "Something went wrong!", e);
    }
}));
exports.default = router;
