import { paystackAxios, tunedErr } from "@/utils/functions"
import axios from "axios"
import { Router } from "express"

const router = Router()

const refundData = {
    status: true,
    message: 'Refund has been queued for processing',
    data: {
      transaction: {
        id: 3222745103,
        domain: 'test',
        reference: 'ccyeymtr9t',
        receipt_number: null,
        amount: 16000,
        paid_at: '2023-10-25T15:19:29.000Z',
        channel: 'card',
        currency: 'ZAR',
        authorization: [Object],
        customer: [Object],
        plan: {},
        subaccount: [Object],
        split: {},
        order_id: null,
        paidAt: '2023-10-25T15:19:29.000Z',
        pos_transaction_data: null,
        source: null,
        fees_breakdown: null
      },
      integration: 1055553,
      deducted_amount: 0,
      channel: null,
      merchant_note: 'Refund for transaction ccyeymtr9t by clickbait4587@gmail.com',
      customer_note: 'Refund for transaction ccyeymtr9t',
      status: 'pending',
      refunded_by: 'clickbait4587@gmail.com',
      expected_at: '2023-11-03T15:23:10.412Z',
      currency: 'ZAR',
      domain: 'test',
      amount: 16000,
      fully_deducted: false,
      id: 10956827,
      createdAt: '2023-10-25T15:23:10.414Z',
      updatedAt: '2023-10-25T15:23:10.414Z'
    }
  }
router.post("/paystack/refund", async (req, res)=>{
    try{
        
        const _res = await paystackAxios().post('/refund', {transaction: 'ccyeymtr9t'});
        console.log(_res.data)
        res.send("OK")
    }
    catch(e){
        return tunedErr(res, 500, 'Something went wrong', e)
    }
})
router.get("/paystack/refund", async (req, res)=>{
    try{
        
        const _res = await paystackAxios().get(`/refund/10956827`,);
        console.log(_res.data)
        res.send("OK")
    }
    catch(e){
        return tunedErr(res, 500, 'Something went wrong', e)
    }
})
router.post("/paystack/transaction", async (req, res)=>{
    try{
        
        const _res = await paystackAxios().post('/transaction/initialize', {
            email: "clickbait4587@gmail.com",
            amount: 100 * 100,
            currency: "ZAR",
            callback_url: "http://localhost:8000/test/paystack"
        });
        res.json(_res.data) 

    }
    catch(e){
        return tunedErr(res, 500, 'Something went wrong', e)
    }
})

router.get('/paystack', (req, res)=>{
    console.log(req.query)
    res.send( "OK")
})





export default router
