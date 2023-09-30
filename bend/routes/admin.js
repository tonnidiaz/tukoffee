const express = require('express');
const { Product, User, Order, Store } = require('../models');
const { parseProducts } = require('../utils/functions');
const router = express.Router();

/* GET home page. */
router.get('/dash', async function(req, res, next) {

    let products = await Product.find().exec()
    let customers = (await User.find().exec()).filter(it=> it.phone_verified && it.first_name != null)
    customers = customers.map(it=>it.toJSON())
    let orders = await Order.find().exec()
    orders = orders.map(it=>it.toJSON())
  
    const data = {products: parseProducts(products), customers, orders}
  res.json(data)
});

module.exports = router;
