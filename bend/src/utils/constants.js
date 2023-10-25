"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrderMode = exports.parser = exports.DEV = exports.UserPermissions = exports.OrderStatus = void 0;
const multer_1 = __importDefault(require("multer"));
var OrderStatus;
(function (OrderStatus) {
    OrderStatus["pending"] = "pending";
    OrderStatus["awaitingPickup"] = "awaitingPickup";
    OrderStatus["completed"] = "completed";
    OrderStatus["cancelled"] = "cancelled";
})(OrderStatus || (exports.OrderStatus = OrderStatus = {}));
var OrderMode;
(function (OrderMode) {
    OrderMode[OrderMode["delivery"] = 0] = "delivery";
    OrderMode[OrderMode["collect"] = 1] = "collect";
})(OrderMode || (exports.OrderMode = OrderMode = {}));
var UserPermissions;
(function (UserPermissions) {
    UserPermissions[UserPermissions["read"] = 0] = "read";
    UserPermissions[UserPermissions["write"] = 1] = "write";
    UserPermissions[UserPermissions["delete"] = 2] = "delete";
})(UserPermissions || (exports.UserPermissions = UserPermissions = {}));
const parser = (0, multer_1.default)().none();
exports.parser = parser;
const DEV = process.env.NODE_ENV != 'production';
exports.DEV = DEV;
