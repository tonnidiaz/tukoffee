import { Router } from "express"

 const router = Router()

router.get('/', (req, res)=>{
    res.send("WORLD")
})

export { router as helloRouter}
