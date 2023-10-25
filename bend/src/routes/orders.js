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
const router = express_1.default.Router();
router.get("/", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { oid, user } = req.query;
        let orders = [];
        if (oid) {
            const order = yield models_1.Order.findOne({ oid }).exec();
            if (!order)
                return res.status(404).json({ msg: "Order not found" });
            orders = [order];
        }
        else if (user) {
            orders = yield models_1.Order.find({ customer: user }).exec();
        }
        else {
            orders = yield models_1.Order.find().exec();
        }
        let populatedOrders = [];
        for (let o of orders) {
            if (oid) {
                let ord = yield (yield o.populate("customer")).populate('store');
                populatedOrders.push(Object.assign({}, ord.toJSON()));
            }
            else {
                populatedOrders.push(o.toJSON());
            }
        }
        orders = populatedOrders; //.map(it=> it.toJSON())
        res.json({ orders });
    }
    catch (e) {
        console.log(e);
        res.status(500).json({ msg: "Something went wrong!" });
    }
}));
exports.default = router;
