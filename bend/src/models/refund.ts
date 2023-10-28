import { Document, HydratedDocument, InferSchemaType, Model, Schema } from "mongoose";

export const RefundSchema = new Schema({
    paystackId: {
        type: Number
    },
    yocoId: {
        type: Number
    },

    userId: {
        type: Schema.ObjectId, ref: "User",
        required: true
    },
    date_created: {
        type: Date,
        default: new Date()
    },
    last_modified: {
        type: Date,
        default: new Date()
    },
})

export type TRefund = Document<InferSchemaType<typeof RefundSchema>>