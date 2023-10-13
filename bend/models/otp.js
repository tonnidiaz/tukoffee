const { Schema, model } = require("mongoose");

const OTPSchema = new Schema({
    phone: {
        type: String,
        unique: true
    },
    email: {
        type: String,
        unique: true
    },
    pin: {
        type: Number,
        required: true
    }
})
const OTP = model("OTP", OTPSchema)
module.exports = {OTPSchema, OTP}