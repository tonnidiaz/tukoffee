import { Router } from "express"
import io from "../utils/io"

const router = Router()
enum EGateway {yoco, paystack}
router.post('/yoco', async (req, res)=>{
    console.log(req.body)
    io.emit('payment', {
        gateway: EGateway.yoco,
        user: req.body.payload.metadata.user,
                data: req.body
    })
    res.send("")
})
router.get('/paystack/:user', async (req, res)=>{
   const { user } = req.params
   console.log(user)
    io.emit('payment', {
        user,
        gateway: EGateway.paystack,
        data: req.query
    })
    res.send("")
})

export default router

