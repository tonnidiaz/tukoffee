"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserSchema = void 0;
const mongoose_1 = require("mongoose");
const constants_1 = require("../utils/constants");
const UserSchema = new mongoose_1.Schema({
    first_name: {
        type: String,
    },
    last_name: {
        type: String,
    },
    phone_verified: {
        type: Boolean,
        default: false
    },
    otp: { type: Number },
    email_verified: {
        type: Boolean,
        default: false
    },
    new_email_verified: {
        type: Boolean,
        default: false
    },
    phone: {
        type: String,
        required: false
    },
    permissions: {
        type: Number,
        default: constants_1.UserPermissions.read,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    new_email: {
        type: String
    },
    password: {
        type: String,
        required: true,
    },
    deviceID: {
        type: String,
        required: false
    },
    delivery_addresses: {
        type: [{}]
    },
    address: {
        type: {}
    },
    cart: {
        type: mongoose_1.Schema.ObjectId, ref: "Cart"
    },
    orders: {
        type: [mongoose_1.Schema.ObjectId], ref: "Order"
    }
});
exports.UserSchema = UserSchema;
