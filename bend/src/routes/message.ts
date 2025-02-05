import { Router } from 'express'
import { sendMail, tunedErr, getStoreDetails } from '../utils/functions'

const router = Router()

router.post('/send', async(req, res)=>{
    const {body} = req
console.log(body)
let buff = getStoreDetails()

const r = await sendMail(`${buff.store.name} app Feedback message`, `
<h4>Message from: <b>${body.name},</b>&nbsp;&nbsp;<a href='mailto:${body.email}'>${body.email}</a></h4>
${body.msg}`, buff.store.email, body.email)
if (!r) return tunedErr(res, 500, 'Failed to send email')
res.send('ok')
}) 

export default router