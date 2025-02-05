import { Document, InferSchemaType, Schema } from "mongoose";


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
    images: {
        type: [Object]
    },
    price: {
        type: Number,
        required: true
    },
    weight: {
        type: Number,
        default: 0
    },
    width: {
        type: Number,
        default: 0
    },
    height: {
        type: Number,
        default: 0
    },
    sale_price: {
        type: Number,
    },

   reviews: {
        type: [Schema.ObjectId],
        ref: 'Review',
        default: []
    },
    quantity: {
        type: Number,
        required: true,
        default: 1
    },
    on_special: {type: Boolean, default: false},
    top_selling: {type: Boolean, default: false},
    on_sale: {type: Boolean, default: false},
    description: {
        type: String,
        required: true
    },
    ratings: {
        type: [{
            customer: { type: Schema.ObjectId, required: true},
            value: { type: Number, required: true}
        }],
        default: [],
        required: false
    },

    
},{timestamps: true})

export interface IProduct extends Document, InferSchemaType<typeof ProductSchema>{}
export { ProductSchema }