const express = require("express");
const { Cart, Order, User } = require("../models");
const { auth } = require("../utils/middleware");
const { OrderStatus } = require("../utils/constants");
const router = express.Router();

const genOID = async () => {
    const oid = Math.floor(Math.random() * 999999) + 1;
    const exists = await Order.findOne({ oid }).exec();
    if (exists != null) return genOID();
    return oid;
};

router.post("/cancel", auth, async (req, res) => {
    const { ids, userId } = req.body;
    const { action } = req.query;
    try {
        for (let id of ids) {
            try {
                console.log(action);
                if (action == "delete") {
                    // Remove order from user document
                    const order = await Order.findById(id).exec();

                    const user = await User.findById(order.customer).exec();
                    await Order.findByIdAndDelete(id).exec();
                    if (user) {
                        user.orders = user.orders.filter((o) => o != id);
                        await user.save();
                        console.log(`Order #${id} deleted!`);
                    }
                } else {
                    await Order.findByIdAndUpdate(id, {
                        status: OrderStatus.cancelled,
                        last_modified: new Date(),
                    }).exec();
                    console.log(`Order #${id} cancelled!`);
                }
            } catch (e) {
                console.log(e);
                continue;
            }
        }

        const orders = userId
            ? await Order.find({ customer: userId }).exec()
            : await Order.find().exec();
        let populatedOrders = [];
        for (let o of orders) {
            let ord = await (
                await o.populate("customer")
            ).populate("products.product");
            populatedOrders.push(ord);
        }
        res.json({ orders: populatedOrders.map((it) => it.toJSON()) });
    } catch (e) {
        console.log(e);
        res.json({ msg: "Something went wrong" });
    }
});
router.post("/create", auth, async (req, res) => {
    const { cartId, mode } = req.query;
    const { address, store } = req.body;
    try {
        if (cartId) {
            // The customer has paid. so get the cart and create an order
            // Also delete the user cart
            console.log("Creating order for cart: " + cartId);
            const cart = await Cart.findById(cartId).exec();
            if (!cart) return res.status(400).json({ msg: "Cart not found" });
            const user = await User.findById(cart.customer).exec();
            if (!user)
                return res.status(400).json({ msg: "Customer not found" });

            const order = new Order();

            order.oid = await genOID();
            order.customer = user;
            order.products = cart.products;
            order.delivery_address = address;
            order.mode = mode;
            order.store = store;
            await order.save();
            // add order to user's orders
            user.orders.push(order);
            await user.save();

            // delete the cart
            //await Cart.findByIdAndDelete(cartId).exec()
            //user.cart = null
            //await user.save()
            console.log("Cart deleted");
            res.json({ order: { ...order.toJSON(), customer: null } });
        } else {
            res.status(400).json({ msg: "Provide cart id" });
        }
    } catch (e) {
        console.log(e);
        res.json({ msg: "Something went wrong" });
    }
});

router.post('/edit', auth, async (req, res)=>{
    try{
        const { id } = req.query;
        const { body } = req
        const order = await Order.findById(id).exec()
        if (!order) return res.status(404).send("Order not found!");
        for (let key of Object.keys(body)){
            order[key] = body[key]
        }  
        order.last_modified = new Date()
        await order.save()
        res.json({id: order.oid})
    }
    catch(e){
        res.status(500).send("tuned:Something went wrong!")
    }
})
module.exports = router;
