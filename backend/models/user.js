const { Schema } = require("mongoose");
const UserSchema = new Schema({
        username: {
            type: String,
            required: true,
            unique: true
        },
        email: {
            type: String,
            required: true,
            unique: true
        },
        password: {
            type: String,
            required: true,
        },
        deviceID: {
            type:String,
            required: false
        },

        cart: {
            type: Schema.ObjectId, ref: "Cart"
        },
        orders: {
            type: [Schema.ObjectId], ref: "Order"
        }
})

const CartSchema = new Schema({
    user: {
        type: Schema.ObjectId, ref: "User",
        required: true
    },
    products: {
        type: [Schema.ObjectId], ref: "Product", default: []
    }
})

const OrderSchema = new Schema({
    oid: {type: Number, required: true},
    user: {
        type: Schema.ObjectId, ref: "User", required: true
    },
    products: {
        type: [Schema.ObjectId], ref: "Product", default: []
    },
    status: {
        type: Number, default: 0, required: true
    },
    billing_address: {
        type: {
            street: String,
            town: String,
            province: String,
            phone: String,
        }, required: true
    },
   delivery_address: {
        type: {
            street: String,
            town: String,
            province: String,
            phone: String,
        }, required: true
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
    date_recieved: {
        type: Date,
        required: false,
    },
})

const OrderStatus = {
    Pending: 0,
    Recieved: 1,
    Cancelled: 2,
}
module.exports = { UserSchema, CartSchema, OrderSchema, OrderStatus }