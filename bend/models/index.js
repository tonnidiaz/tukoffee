const { ProductSchema } = require("./product")
const { model } = require("mongoose");
const { UserSchema } = require("./user");
const { StoreSchema } = require("./store");
const { OrderSchema } = require("./order");
const { CartSchema } = require("./cart");
const { ReviewSchema } = require("./review");

const Product = model("Product", ProductSchema)
const User = model("User", UserSchema)
const Order = model("Order", OrderSchema)
const Cart = model("Cart", CartSchema)
const Store = model("Store", StoreSchema)
const Review = model("Review", ReviewSchema)
module.exports = { Product, Order, User, Cart, Store, Review }