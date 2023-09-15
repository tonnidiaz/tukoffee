var express = require('express');
const { Product } = require('../models');
const { parseProducts } = require('../utils/functions');
const { auth, lightAuth } = require('../utils/middleware');
var router = express.Router();


const genPID = async () => {
        const pid = Math.floor(( Math.random() * 999999)) + 1;
        const exists = await Product.findOne({ pid }).exec();
        if (exists != null) return genPID();
        return pid;
}


router.get('/', async (req, res, next) => {

    const args = req.query
    const { pid, q } = args;

    try{let prods = pid ? await Product.find({pid}).exec() : await Product.find().exec();

    switch (q){
        case "top-selling":
            prods = prods.filter(it=> it.top_selling);
            break;
        case "special":
            prods = prods.filter(it=> it.on_special);
            break;
        case "sale":
            prods = prods.filter(it=> it.on_sale);
            break;
    }
    let data = parseProducts(prods);

    res.json({data})}
    catch(err){
        console.log(err);
        res.status(500).json({ msg: "Something went wrong"})
    }
});

router.post("/add", auth, async (req, res)=>{
    
    try{
    const body = req.body;
    const prod = new Product()
    for (let key of Object.keys(body)){
        prod[key] = body[key]
    }
    prod.pid = await genPID();
    await prod.save();
    console.log("Product added!");
    res.json({pid: prod.pid})
    }
    catch(err){
        console.log(err);
        res.status(500).send("tuned:Something went wrong")
    }
})

router.post("/edit",auth, async (req, res)=>{
    
    try{
    const { body } = req
    
    const prod = await Product.findOne({pid: body.pid}).exec();
    if (!prod) return res.status(404).json({ msg: "Product not found"});

    for (let key of Object.keys(body)){
        prod[key] = body[key]
    }
    prod.last_modified = new Date();
    await prod.save();
    console.log("Product edited!");
    res.json({pid: prod.pid})
    }
    catch(err){
        console.log(err);
        res.status(500).send("tuned:Something went wrong")
    }
})

router.post("/delete",auth, async (req, res)=>{
    try{
        const { pid, pids } = req.query;
        if (pid){
        const product = await Product.findOneAndRemove({pid}).exec();
        if (!product) return   res.status(404).send("tuned:Product not found!")
        res.status(200).send("Product deleted successfully!");
        }
        else if (pids){
            const _pids = JSON.parse(pids)
            for (let _pid of _pids){
                try{
                   await Product.findOneAndRemove({pid: _pid}).exec();
                }
                catch(e){
                    console.log(e);
                    continue
                }
            }

            const newProducts = await Product.find().exec();
            return res.json({products: parseProducts(newProducts) });
        }
    }
    catch(e){
        console.log(e);
        res.status(500).send("tuned:Something went wrong!")
    }
})

router.post("/rate", auth, async (req, res)=>{

    // remove existing rating by user and add new one or add the rating
    try{
        const { pid } = req.query;
        const { rating } = req.body;
        
        const product = await Product.findOne({pid},).exec();
        if (!product) return res.status(404).json({msg: "Product not found"}); 
        
        product.ratings = [...product.ratings.filter(it=> it.customer != req.user), {...rating, customer: req.user}];
        product.last_modified = new Date()
        await product.save()
        res.status(200).send("Product rated successfully!");
        
    } 
    catch(e){
        console.log(e);
        res.status(500).send("tuned:Something went wrong")
    }
})
module.exports = router;
