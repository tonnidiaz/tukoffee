const { Schema } = require("mongoose");

const StoreSchema = new Schema({
    location: {
        type: {
            name: String,
            center: [Number]
        }, required: true
    },
   
    open_time: {
        type: String,
        required: true
    },
    close_time: {
        type: String,
        required: true
    },
    open_time_weekends: {
        type: String,
        required: true
    },
    close_time_weekends: {
        type: String,
        required: true
    },
})

module.exports = {StoreSchema}