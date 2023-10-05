const { sendMail, tunedErr } = require('../utils/functions')

const router = require('express').Router()

router.post('/send', async(req, res)=>{
    const {body} = req
console.log(body)
const r = await sendMail("ToKoffee message", `
<h2>TuKoffee app</h2>
<h4>Message from: <a href='mailto:${body.email}'>${body.email}</a> </h4>
${body.msg}`, process.env.EMAIL)
if (!r) return tunedErr(res, 500, 'Failed to send email')
res.send('ok')
})

module.exports = router