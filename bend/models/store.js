const { Schema } = require("mongoose");
const { AddressSchema } = require("../utils/constants");

const StoreSchema = new Schema({
    address: {
        type: AddressSchema,
        required: true
    },
   
    open_time: {
        type: String,
        required: true
    },
    close_time: {
        type: String,
        required: true
    },

    open_time_weekend: {
        type: String,
        required: true
    },
    close_time_weekend: {
        type: String,
        required: true
    },
})

module.exports = {StoreSchema}