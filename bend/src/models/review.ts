import { Schema, Document, InferSchemaType } from "mongoose";

enum EReviewStatus {
    pending = 'pending',
    approved = 'approved',
    rejected = 'rejected',
    
}

const ReviewSchema = new Schema( {
    title: {type: String, required: true},
    name: {type: String, required: true},
    body: {type: String, required: true},
    reject_reason: {type: String},
    status: {type: typeof EReviewStatus.pending, default: EReviewStatus.pending, enum: EReviewStatus},
    rating: {type: Number, required: true, default: 0},
    user: {type: Schema.ObjectId, ref: 'User', required: true},
    product: {type: Schema.ObjectId, ref: 'Product', required: true},
   /*  last_modified: {
        type: Object,
         required: true
    } */
}, {timestamps: true})
export interface IReview extends Document, InferSchemaType<typeof ReviewSchema> {
}
export { ReviewSchema, EReviewStatus}