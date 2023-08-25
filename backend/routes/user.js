var express = require("express");
const { Cart, User } = require("../models");
var router = express.Router();

/* GET users listing. */
router.get("/", function (req, res, next) {
    res.send("respond with a resource");
});

router
    .route("/cart")
    .get(async (req, res) => {
        try {
            const { user } = req.query;
            const _user = await User.findOne({email: user}).exec()
            const cart = await Cart.findOne( {user: _user} ).exec();
            if (!cart) return res.status(404).json({ msg: "Cart not found" });
            let c = await cart.populate("products")

            res.json({ cart: c.toJSON() });
        } catch (e) {
            console.log(e);
            res.status(500).json({ msg: "Something went wrong" });
        }
    })
    .post(async (req, res) => {
        try {
           const { action } = req.query;
           const {product, user} = req.body;
           const _user = await User.findOne({email: user}).exec()
           const cart = _user.cart ? await Cart.findById( _user.cart).exec() : new Cart();
           if (action == "add"){
            //return res.json({cart: {}})
            cart.user = _user;
            if (!cart.products.includes(product))
            {cart.products.push(product)}
            await cart.save()
            _user.cart = cart;
            _user.save();
            
            let c = await cart.populate("products")

            res.json({ cart: {...c.toJSON(), user: {}} });
           } else if (action == "remove"){
                if (_user.cart){
                    cart.products = cart.products.filter(it=> it != product);
                    await cart.save();
                    let c = await cart.populate("products")

                    res.json({ cart: {...c.toJSON(), user: {}} });
                }
                else res.status(400).json({msg: "User has no cart"})
           }
           else if (action == "edit"){}
        } catch (e) {
            console.log(e);
            res.status(500).json({ msg: "Something went wrong" });
        }
    });

module.exports = router;
