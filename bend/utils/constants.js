const multer = require("multer")

const OrderStatus = {
    pending: "pending",
    delivered: "delivered",
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
module.exports = {OrderStatus, UserPermissions,parser,  AddressSchema, OrderMode}