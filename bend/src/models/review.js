"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EReviewStatus = exports.ReviewSchema = void 0;
const mongoose_1 = require("mongoose");
var EReviewStatus;
(function (EReviewStatus) {
    EReviewStatus["pending"] = "pending";
    EReviewStatus["approved"] = "approved";
    EReviewStatus["rejected"] = "rejected";
})(EReviewStatus || (exports.EReviewStatus = EReviewStatus = {}));
const ReviewSchema = new mongoose_1.Schema({
    title: { type: String, required: true },
    name: { type: String, required: true },
    body: { type: String, required: true },
    reject_reason: { type: String },
    status: { type: typeof EReviewStatus.pending, default: EReviewStatus.pending, enum: EReviewStatus },
    rating: { type: Number, required: true, default: 0 },
    user: { type: mongoose_1.Schema.ObjectId, ref: 'User', required: true },
    product: { type: mongoose_1.Schema.ObjectId, ref: 'Product', required: true },
    date_created: { type: Date, default: new Date(), required: false },
    last_modified: { type: Date, default: new Date(), required: false },
});
exports.ReviewSchema = ReviewSchema;
