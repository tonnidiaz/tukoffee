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

} ,{timestamps: true})

export type TRefund = Document<InferSchemaType<typeof RefundSchema>>