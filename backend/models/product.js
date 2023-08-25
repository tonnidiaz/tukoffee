const { Schema } = require("mongoose");


const ProductSchema = new Schema({
    pid : {
        type: Number,
        required: true,
        unique: true
    },
    name: { 
        type: String,
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    quantity: {
        type: Number,
        required: true,
        default: 1
    },
    description: {
        type: String,
        required: true
    },
    ratings: {
        type: [{
            user: { type: String, required: true},
            value: { type: Number, required: true}
        }],
        default: [],
        required: false
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
    }
    
})

module.exports = { ProductSchema }