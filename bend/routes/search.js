const express = require('express');
const { tunedErr } = require('../utils/functions');
const { Product } = require('../models');
const router = express.Router();

router.get('/',async (req, res)=>{
    try {
        const {q} = req.query;

        let products = await Product.find({name: {$regex: q, $options: 'i'}}).exec()
        products = [...products, ...await Product.find({description: {$regex: q, $options: 'i'}}).exec()]
        products  = [...new Set(products)]
        res.json({products: products.map(it=> it.toJSON())})
    } catch (e) {
        return tunedErr(res, 500, "Something went wrong")
    }
})
module.exports = router