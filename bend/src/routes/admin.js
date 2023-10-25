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
const router = express_1.default.Router();
/* GET home page. */
router.get('/dash', function (req, res, next) {
    return __awaiter(this, void 0, void 0, function* () {
        let products = yield models_1.Product.find().exec();
        let customers = (yield models_1.User.find().exec()).filter(it => it.email_verified && it.first_name);
        customers = customers.map(it => it.toJSON());
        let orders = yield models_1.Order.find().exec();
        orders = orders.map(it => it.toJSON());
        let reviews = yield models_1.Review.find().exec();
        reviews = reviews.map(it => it.toJSON());
        let stores = yield models_1.Store.find().exec();
        stores = stores.map(it => it.toJSON());
        const data = { products: yield (0, functions_1.parseProducts)(products), customers, orders, reviews, stores };
        res.json(data);
    });
});
exports.default = router;
