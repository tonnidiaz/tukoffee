"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Car = exports.CarColor = void 0;
const mongoose_1 = require("mongoose");
var CarColor;
(function (CarColor) {
    CarColor["red"] = "red";
    CarColor["green"] = "green";
    CarColor["blue"] = "blue";
})(CarColor || (exports.CarColor = CarColor = {}));
const CarSchema = new mongoose_1.Schema({
    name: { type: String, required: true },
    speed: { type: Number, required: true },
    color: { type: String, enum: CarColor },
});
exports.Car = (0, mongoose_1.model)("Car", CarSchema);
