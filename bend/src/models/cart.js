"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CartSchema = void 0;
const mongoose_1 = require("mongoose");
const CartSchema = new mongoose_1.Schema({
    customer: {
        type: mongoose_1.Schema.ObjectId, ref: "User",
        required: true
    },
    products: {
        type: [{
                product: { type: mongoose_1.Schema.ObjectId, ref: "Product" },
                quantity: { type: Number, default: 1 }
            }], default: []
    }
});
exports.CartSchema = CartSchema;
