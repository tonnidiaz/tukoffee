var express = require("express");
const { Cart, User } = require("../models");
const { Schema, Mongoose, default: mongoose } = require("mongoose");
const { auth, lightAuth } = require("../utils/middleware");
const bcrypt = require("bcrypt");
const { parser } = require("../utils/constants");
const { randomInRange, tunedErr, sendMail } = require("../utils/functions");
const router = express.Router();

/* GET users listing. */
router.get("/", async (req, res, next) => {
    const { email, id } = req.query;

    let user;
    user = email
        ? await User.findOne({ email }).exec()
        : await User.findById(id).exec();

    res.json({ user: user.toJSON() });
});

router
    .route("/cart")
    .get( async (req, res) => {
        try {
            const { user } = req.query;
            const _user = await User.findOne({ phone: user }).exec();
            const cart = await Cart.findOne({ customer: _user }).exec();
            if (!cart) return res.status(404).send("tuned:Cart not found");
            let c = await cart.populate("products.product");
            c = {
                ...c.toJSON(),
                products: c.products.filter((it) => it.product != null && it.product.quantity > 0),
            };
            res.json({ cart: c });
        } catch (e) {
            console.log(e);
            res.status(500).send("tuned:Something went wrong");
        }
    })
    .post(auth, async (req, res) => {
        try {
            const { action } = req.query;
            const { product, quantity } = req.body;
            console.log(product, action, quantity);
            const _user = req.user;
            let cart = null;
            if (_user.cart) {
                cart = (await Cart.findById(_user.cart).exec()) ?? new Cart();
            } else {
                cart = new Cart();
            }

            if (action == "add") {
                cart.customer = _user;
                const prod = cart.products.find((it) => it.product == product);

                if (!prod) {
                    console.log("Adding");
                    //add product to cart if the cart does not have the product
                    cart.products.push({ product });
                } else if (prod && quantity) {
                    // Increase the product's quantiry
                    prod.quantity = quantity;
                }
                await cart.save();
                _user.cart = cart;
                await _user.save();

                //let c = await cart.populate("products.product")
                let c = await cart.populate("products.product");
                c = {
                    ...c.toJSON(),
                    products: c.products.filter((it) => it.product != null && it.product.quantity > 0),
                    customer: {},
                };
                res.json({ cart: c });
            } else if (action == "remove") {
                if (_user.cart) {
                    cart.products = cart.products.filter(
                        (it) => it.product != product
                    );
                    await cart.save();
                    let c = await cart.populate("products.product");

                    c = {
                        ...c.toJSON(),
                        products: c.products.filter((it) => it.product != null && it.product.quantity > 0),
                        customer: {},
                    };
                    res.json({ cart: c });
                } else res.status(400).send("tuned:User has no cart");
            }
            else if (action == 'clear'){
                cart.products = []
                await cart.save()
                let c = await cart.populate("products.product");

                    c = {
                        ...c.toJSON(),
                        products: c.products.filter((it) => it.product != null && it.product.quantity > 0),
                        customer: {},
                    };
                res.json({cart: c})
            }
        } catch (e) {
            console.log(e);
            res.status(500).send("tuned:Something went wrong");
        }
    }); 

router.post("/delivery-address", parser, auth, async (req, res) => {
    try {
        const { action } = req.query;
        const { address } = req.body;
        let u = req.user;
        if (action == "add") {
            if (!address) return res.status(400).send("tuned:Provide address");
            u.delivery_addresses.push(address);
        } else {
            u.delivery_addresses = u.delivery_addresses.filter(
                (it) => it["_id"] != address["_id"]
            );
        }
        await u.save();
        res.json({ user: u.toJSON() });
    } catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
});
router.post("/edit", auth, async (req, res) => {
    try {
        const { field } = req.query;
        const { value, userId, data } = req.body;
        console.log(userId)
        const _user = userId ? await User.findById(userId).exec() : req.user;
        if (!field) {
            for (let key of Object.keys(value)) {
                _user[key] = value[key];
            }
        } else {
            if (field == 'email'){

                // Check password
                if ( !bcrypt.compareSync(data.password, _user.password))
                    return tunedErr(res, 401, 'Incorrect password')
                _user.new_email = data.email;
                _user.otp = randomInRange(1000,9999)
               await sendMail("Tukoffee Verification Email",
                `<h2 style="font-weight: 500">Here is your Email verification One-Time-PIN:</h2>
                    <p style="font-size: 20px; font-weight: 600">${_user.otp}</p>
                ` , _user.new_email
               )
            }else{
                 _user[field] = value;
            }
           
        }
        await _user.save();
        res.json({ user: _user.toJSON() });
    } catch (error) {
        console.log(error);
        res.status(500).send("tuned:Something went wrong");
    }
});

router.post("/delete", auth, async (req, res) => {
    try {
        const { password } = req.body;
        const passValid = bcrypt.compareSync(password, req.user.password);
        if (!passValid) {
            return res.status(401).send("tuned:Incorrect password!");
        }
        // delete the user
        console.log(req.user.email);
        await User.findByIdAndDelete(req.user._id).exec();
        res.send("tuned:Account deleted successfully!");
    } catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
});
module.exports = router;
