const { Schema } = require("mongoose")

const CartSchema = new Schema({
    customer: {
        type: Schema.ObjectId, ref: "User",
        required: true
    },
    products: {
        type: [{
            product: {type: Schema.ObjectId, ref: "Product"},
            quantity: {type:Number, default: 1}
        }], default: []
    }
})

module.exports = {CartSchema}