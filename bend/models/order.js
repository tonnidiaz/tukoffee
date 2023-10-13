const { Schema } = require("mongoose")
const { OrderStatus, AddressSchema, OrderMode } = require("../utils/constants")


const OrderSchema = new Schema({
    oid: {type: Number, required: true},
    customer: {
        type: Schema.ObjectId, ref: "User", required: true
    },
    mode: {type: Number, default: OrderMode.deliver},
    store: { type: Schema.ObjectId, ref: "Store"},
    collector: {type: {name: String, phone: String}} ,
    collection_time: {
        type: String
    },
    delivery_time: {
        type: String
    },
    products: {
        type: [{
            product: {type: Schema.ObjectId, ref: "Product"},
            quantity: {type:Number, default: 1}
        }], default: []
    },
    status: {
        type: String, default: OrderStatus.pending, required: true
    },
   delivery_address: {
        type: AddressSchema, required: false
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
    date_delivered: {
        type: Date,
        required: false,
    },
})

module.exports = {OrderSchema}