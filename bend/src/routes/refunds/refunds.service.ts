import { Refund } from "@/models";
import { Schema } from "mongoose";

export class RefundsService{
    static async getAll(){
        let refunds = await Refund.find().exec();
       return { refunds:  refunds.map(it=> it.toJSON())}
    }
    static async getFor(userId: Schema.Types.ObjectId){
        let refunds = await Refund.find({userId: userId}).exec();
       return { refunds:  refunds.map(it=> it.toJSON())}
    }
}