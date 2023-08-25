const { ProductSchema } = require("./product")
const { model } = require("mongoose");
const { UserSchema, CartSchema, OrderSchema } = require("./user");

const Product = model("Product", ProductSchema)
const User = model("User", UserSchema)
const Order = model("Order", OrderSchema)
const Cart = model("Cart", CartSchema)
module.exports = { Product, Order, User, Cart }