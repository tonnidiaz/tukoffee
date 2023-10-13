const express = require('express');
const { Cart, Order, User } = require('../models');
const router = express.Router();


router.get("/", async (req, res)=>{
    try{

        const { oid, user } = req.query
        let orders = [];
        if (oid){
            const order = await Order.findOne({oid}).exec()
            if (!order) return res.status(404).json({msg: "Order not found"})
            orders = [order]
        }
        else if (user){
            orders = await Order.find({customer: user}).exec()
        }
        else{
            orders = await Order.find().exec()
        }
        
        let populatedOrders = []
        for (let o of orders){
            let ord = await (await (await o.populate("customer")).populate("products.product")).populate('store')
            populatedOrders.push({...ord.toJSON(), products: ord.products.filter((it) => it.product != null)})
        }
        orders = populatedOrders//.map(it=> it.toJSON())
        res.json({orders: orders})
    }
    catch(e){
        console.log(e);
        res.status(500).json({msg: "Something went wrong!"})
    }
})
module.exports = router