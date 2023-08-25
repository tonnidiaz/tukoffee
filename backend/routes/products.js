var express = require('express');
const { Product } = require('../models');
var router = express.Router();


const genPID = async () => {
        const pid = Math.floor(( Math.random() * 999999)) + 1;
        const exists = await Product.findOne({ pid }).exec();
        if (exists != null) return genPID();
        return pid;
}

const parseProducts = (products) =>{
    let data = []
    products.forEach(it=>{
        let r = 0;
            it.ratings.forEach(i=>{
                r += i.value
                console.log(i)
            });
            r = r / it.ratings.length
        data.push({...it.toJSON(), rating: r})
    });
   
    return data;
}
router.get('/', async (req, res, next) => {

    const args = req.query
    const { pid } = args;

    try{const prods = pid ? await Product.find({pid}).exec() : await Product.find().exec();
    let data = parseProducts(prods);

    res.json({data})}
    catch(err){
        console.log(err);
        res.status(500).json({ msg: "Something went wrong"})
    }
});

router.post("/add", async (req, res)=>{
    
    try{
    const { name, quantity, description,price} = req.body;
    const prod = new Product()
    prod.name = name;
    prod.price = price;
    prod.description = description;
    prod.quantity = quantity;
    prod.pid = await genPID();
    await prod.save();
    console.log("Product added!");
    res.json({pid: prod.pid})
    }
    catch(err){
        console.log(err);
        res.status(500).json({msg: "Something went wrong"})
    }
})

router.post("/edit", async (req, res)=>{
    
    try{
    const { name, quantity, description,price, ratings, pid} = req.body;

    if (!(name && quantity && description && price && pid)) return res.status(400).json({msg: "Not enought arguments"})

    const prod = await Product.findOne({pid}).exec();
    if (!prod) return res.status(404).json({ msg: "Product not found"});

    prod.name = name;
    prod.price = price;
    prod.description = description;
    prod.quantity = quantity;
    prod.ratings = ratings;
    prod.last_modified = new Date();
    await prod.save();
    console.log("Product added!");
    res.json({pid: prod.pid})
    }
    catch(err){
        console.log(err);
        res.status(500).json({msg: "Something went wrong"})
    }
})

router.post("/delete", async (req, res)=>{
    try{
        const { pid, pids } = req.query;
        if (pid){
        const product = await Product.findOneAndRemove({pid}).exec();
        if (!product) return res.status(404).json({msg: "Product not found"});
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
        res.status(500).json({msg: "Something went wrong"});
    }
})

router.post("/rate", async (req, res)=>{

    // remove existing rating by user and add new one or add the rating
    try{
        const { pid } = req.query;
        const { rating } = req.body;
        
        const product = await Product.findOne({pid},).exec();
        if (!product) return res.status(404).json({msg: "Product not found"}); 
        
        product.ratings = [...product.ratings.filter(it=> it.user != rating.user), rating];
        product.last_modified = new Date()
        await product.save()
        res.status(200).send("Product rated successfully!");
        
    } 
    catch(e){
        console.log(e);
        res.status(500).json({msg: "Something went wrong"});
    }
})
module.exports = router;
