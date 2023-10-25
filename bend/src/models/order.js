"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrderSchema = void 0;
const mongoose_1 = require("mongoose");
const constants_1 = require("../utils/constants");
const OrderSchema = new mongoose_1.Schema({
    oid: { type: Number, required: true },
    customer: {
        type: mongoose_1.Schema.ObjectId, ref: "User", required: true
    },
    mode: { type: Number, default: constants_1.OrderMode.delivery },
    store: { type: mongoose_1.Schema.ObjectId, ref: "Store" },
    collector: { type: { name: String, phone: String } },
    collection_time: {
        type: String
    },
    delivery_time: {
        type: String
    },
    yocoData: { type: Object },
    paystackData: { type: Object },
    shiplogic: { type: Object },
    products: {
        type: [{
                product: { type: Object, },
                quantity: { type: Number, default: 1 }
            }], default: []
    },
    status: {
        type: typeof constants_1.OrderStatus.pending, default: constants_1.OrderStatus.pending, required: true, enum: constants_1.OrderStatus
    },
    delivery_address: {
        type: {}, required: false
    },
    fee: {
        type: Number,
        default: 0
    },
    date_created: {
        type: Date,
        required: true,
        default: new Date()
    },
    last_modified: {
        type: Date,
        required: true,
        default: new Date()
    },
    date_delivered: {
        type: Date,
        required: false,
    },
});
exports.OrderSchema = OrderSchema;
