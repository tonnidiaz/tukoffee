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
const functions_1 = require("../utils/functions");
const models_1 = require("../models");
const router = express_1.default.Router();
router.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { q, by } = req.query;
        console.log(q);
        let products = [];
        if (by == "pid") {
            products = yield models_1.Product.find({ pid: q }).exec();
        }
        else {
            products = yield models_1.Product.find({ name: { $regex: q, $options: 'i' } }).exec();
            products = [...products, ...yield models_1.Product.find({ description: { $regex: q, $options: 'i' } }).exec()];
            products = [...new Set(products)];
        }
        res.json({ products: products.map(it => it.toJSON()) });
    }
    catch (e) {
        return (0, functions_1.tunedErr)(res, 500, "Something went wrong");
    }
}));
exports.default = router;
