const { Schema } = require("mongoose");
const { UserPermissions, AddressSchema } = require("../utils/constants");

const UserSchema = new Schema({
        first_name: {
            type: String,
        },
        last_name: {
            type: String,
        },
        phone_verified: {
            type: Boolean,
            default: false
        },
        otp:{type: Number},
        email_verified: {
            type: Boolean,
            default: false
        },
        new_email_verified: {
            type: Boolean,
            default: false
        },
        phone: {
            type: String,
            required: true
        },
        permissions: {
            type: typeof UserPermissions,
            default: UserPermissions.read,
            required: true
        },
        email: {
            type: String,
            required: true,
            unique: true
        },
        new_email: {
            type: String
        },
        password: {
            type: String,
            required: true,
        },
        deviceID: {
            type:String,
            required: false
        },
        delivery_addresses: {
            type: [AddressSchema]
        },
        address: {
            type: AddressSchema
        },

        cart: {
            type: Schema.ObjectId, ref: "Cart"
        },
        orders: {
            type: [Schema.ObjectId], ref: "Order"
        }
})


module.exports = { UserSchema, }