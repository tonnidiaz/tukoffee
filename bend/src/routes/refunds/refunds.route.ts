import { authMid, lightAuthMid } from "@/middleware/auth.mid"
import { tunedErr } from "@/utils/functions"
import { Router } from "express"
import { RefundsService } from "./refunds.service"

const router = Router()

router.get("/", lightAuthMid, async (req, res)=>{
    const { q } = req.query
    
    try{
        if (q == 'all'){
            const data = await RefundsService.getAll()
            res.json( data )
        }
        else{
            const data = await RefundsService.getFor(req.user?._id)
            res.json(data)
        }
    }
    catch(e){
        tunedErr(res, 500, 'Something wrong', e)
    }
})

export default router