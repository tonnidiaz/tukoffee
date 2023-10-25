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
const express_1 = require("express");
const io_1 = __importDefault(require("../utils/io"));
const router = (0, express_1.Router)();
const yocoResp = {
    createdDate: '2023-10-15T17:12:20.936383Z',
    id: 'evt_ZgnMyBeRk5DtAAlUOJACjNEn',
    payload: {
        amount: 2500,
        createdDate: '2023-10-15T17:11:51.742571Z',
        currency: 'ZAR',
        id: 'p_Kg7b2Q95B8JS6jWf2zdhj0DE',
        metadata: {
            checkoutId: 'ch_ngopyGvWBwXIG9u6jnCpdkxB',
            productType: 'checkout'
        },
        mode: 'test',
        paymentMethodDetails: { card: [Object], type: 'card' },
        status: 'succeeded',
        type: 'payment'
    },
    type: 'payment.succeeded'
};
router.post('/yoco', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log(req.body);
    io_1.default.emit('payment', {
        gateway: 'yoco',
        data: req.body
    });
    res.send("OK");
}));
exports.default = router;
