"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.StoreSchema = void 0;
const mongoose_1 = require("mongoose");
const StoreSchema = new mongoose_1.Schema({
    address: {
        type: {},
        required: true
    },
    open_time: {
        type: String,
        required: true
    },
    close_time: {
        type: String,
        required: true
    },
    open_time_weekend: {
        type: String,
        required: true
    },
    close_time_weekend: {
        type: String,
        required: true
    },
});
exports.StoreSchema = StoreSchema;
