const { Schema, Model } = require("mongoose");

const ReviewStatus = {
    pending: 0,
    approved: 1,
    rejected: 2,
    
}

const ReviewSchema = new Schema( {
    title: {type: String, required: true},
    name: {type: String, required: true},
    body: {type: String, required: true},
    reject_reason: {type: String},
    status: {type: Number, default: ReviewStatus.pending},
    rating: {type: Number, required: true, default: 0},
    user: {type: Schema.ObjectId, ref: 'User', required: true},
    product: {type: Schema.ObjectId, ref: 'Product', required: true},
    date_created: {type: Date, default: new Date(), required: false},
    last_modified: {type: Date, default: new Date(), required: false},
})

module.exports = { ReviewSchema, ReviewStatus}