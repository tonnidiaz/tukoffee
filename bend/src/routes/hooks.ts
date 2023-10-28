import { Router } from "express"
import io from "../utils/io"

const router = Router()
enum EGateway {yoco, paystack}
router.post('/yoco', async (req, res)=>{
    console.log(req.body)
    io.emit('payment', {
        gateway: EGateway.yoco,
        data: req.body
    })
    res.send("")
})
router.get('/paystack', async (req, res)=>{
    io.emit('payment', {
        gateway: EGateway.paystack,
        data: req.query
    })
    res.send("")
})

export default router

