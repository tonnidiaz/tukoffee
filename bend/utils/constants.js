const { Schema } = require("mongoose")
const multer = require("multer")

const OrderStatus = {
    pending: "pending",
    completed: "completed",
    cancelled: "cancelled",
}
const OrderMode  = {
    deliver: 0,
    collect: 1
}
const UserPermissions = {
    read: 0,
    write: 1,
    delete: 2
}
const AddressSchema = {
   location:   {
    name: String,
    center: [Number]
   },
    phone: String,
    name: String,
}

const parser = multer().none()

const DEV = process.env.NODE_ENV != 'production'
module.exports = {OrderStatus, UserPermissions,DEV, parser,  AddressSchema, OrderMode}