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
const models_1 = require("../models");
const functions_1 = require("../utils/functions");
const middleware_1 = require("../utils/middleware");
const router = require('express').Router();
router.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    let stores = yield models_1.Store.find().exec();
    stores = stores.map(it => it.toJSON());
    res.json({ stores });
}));
router.post('/add', middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { body } = req;
        const store = new models_1.Store();
        for (let key of Object.keys(body)) {
            store[key] = body[key];
        }
        yield store.save();
        let stores = yield models_1.Store.find().exec();
        stores = stores.map(it => it.toJSON());
        res.json({ stores });
    }
    catch (e) {
        console.log(e);
        (0, functions_1.tunedErr)(res, 500, "Something went wrong");
    }
}));
router.post('/del', middleware_1.auth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.query;
        const store = yield models_1.Store.findByIdAndDelete(id).exec();
        if (!store)
            return (0, functions_1.tunedErr)(res, 404, 'Store does not exist');
        let stores = yield models_1.Store.find().exec();
        stores = stores.map(it => it.toJSON());
        res.json({ stores });
    }
    catch (e) {
        console.log(e);
        (0, functions_1.tunedErr)(res, 500, "Something went wrong");
    }
}));
exports.default = router;
