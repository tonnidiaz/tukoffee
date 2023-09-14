const { Store } = require('../models');
const { tunedErr } = require('../utils/functions')
const { auth} = require('../utils/middleware')
const router = require('express').Router()

router.get('/', async (req, res)=>{
    let stores = await Store.find().exec()
            stores = stores.map(it=>it.toJSON())
            console.log(stores)
        res.json({stores})
})

router.post('/add',  auth, async (req, res)=>{
    try {
        const { body} = req;
        const store = new Store()

        for (let key of Object.keys(body)){
            store[key] = body[key]
        }
        await store.save()
        let stores = await Store.find().exec()
            stores = stores.map(it=>it.toJSON())
        res.json({stores})
    } catch (e) { 
        console.log(e)
        tunedErr(res, 500, "Something went wrong")
    }
})
module.exports = router