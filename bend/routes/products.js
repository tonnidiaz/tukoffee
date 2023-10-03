const express = require("express");
const { Product, Order, Review } = require("../models");
const { parseProducts, tunedErr } = require("../utils/functions");
const { auth, lightAuth } = require("../utils/middleware");
const router = express.Router();

const genPID = async () => {
    const pid = Math.floor(Math.random() * 999999) + 1;
    const exists = await Product.findOne({ pid }).exec();
    if (exists != null) return genPID();
    return pid;
};

router.get("/", lightAuth, async (req, res, next) => {
    const args = req.query;
    const { pid, q } = args;

    try {
        let prods = (pid && !q)
            ? await Product.find({ pid }).exec()
            : await Product.find().exec();

        switch (q) {
            case "top-selling":
                prods = prods.filter((it) => it.top_selling);
                break;
            case "special":
                prods = prods.filter((it) => it.on_special);
                break;
            
            case "sale":
                prods = prods.filter((it) => it.on_sale);
                break;
            case "received":
                let orders = await Order.find({customer: req.user._id, status: 'completed'}).exec()
                orders = await  Promise.all(orders.map(async it=> await it.populate('products.product')))//
                
                
                return res.json(orders.map(it=> {return {date: it.last_modified, items: it.products.map(p=>p.product).filter(it=> it)}}))
                
        }
        let data = parseProducts(prods);

        res.json({ data });
    } catch (err) {
        console.log(err);
        res.status(500).json({ msg: "Something went wrong" });
    }
});

router.post("/add", auth, async (req, res) => {
    try {
        const body = req.body;
        const prod = new Product();
        for (let key of Object.keys(body)) {
            prod[key] = body[key];
        }

        prod.pid = await genPID();
        await prod.save();
        console.log("Product added!");
        res.json({ pid: prod.pid });
    } catch (err) {
        console.log(err);
        res.status(500).send("tuned:Something went wrong");
    }
});

router.get('/reviews', auth, async (req, res)=>{
    try {

        const { id } = req.query
        let reviews = id ? [await Review.findById(id).exec()] : await Review.find({user: req.user._id}).exec()
        reviews = await Promise.all(reviews.map(async it=> (await it.populate('product')).toJSON()))
        res.json({reviews})
    } catch (error) {
        console.log(error)
        return tunedErr(res, 500, 'Something went wrong')
    }
})

router.post('/review', auth, async (req, res)=>{
    try {
        const { act } = req.query
        const { pid, id, review } = req.body
        const prod = await Product.findOne({ pid }).exec() ?? await Product.findById(id).exec();
        if (!prod) return tunedErr(res, 404, 'Product not found')
        if (act == 'add'){
            const _review = new Review()
            for (let key of Object.keys(review)){
                _review.set(key, review[key])
            }
            _review.user = req.user._id
            await _review.save()
            prod.reviews.push(_review)
        }

        await prod.save()
        res.json({reviews: prod.reviews})

    } catch (e) {
        tunedErr(res, 500, 'Something went wrong')
        
    }
})
router.post("/edit", auth, async (req, res) => {
    try {
        const { body } = req;

        const prod = await Product.findOne({ pid: body.pid }).exec() ?? await Product.findById(body.id).exec();
        if (!prod) return res.status(404).json({ msg: "Product not found" });

        for (let key of Object.keys(body)) {
            prod[key] = body[key];
        }
        prod.last_modified = new Date();
        await prod.save();
        console.log("Product edited!");
        res.json({ pid: prod.pid });
    } catch (err) {
        console.log(err);
        res.status(500).send("tuned:Something went wrong");
    }
});

router.post("/delete", auth, async (req, res) => {
    try {
        const { pid } = req.query;
        const {pids} = req.body
        if (pid) {
            const product = await Product.findOneAndRemove({ pid }).exec();
            if (!product)
                return res.status(404).send("tuned:Product not found!");
            res.status(200).send("Product deleted successfully!");
        } else if (pids) {
            for (let _pid of pids) {
                try {
                    await Product.findOneAndRemove({ pid: _pid }).exec();
                } catch (e) {
                    console.log(e);
                    continue;
                }
            }

            const newProducts = await Product.find().exec();
            return res.json({ products: parseProducts(newProducts) });
        }
    } catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong!");
    }
});

router.post("/rate", auth, async (req, res) => {
    // remove existing rating by user and add new one or add the rating
    try {
        const { pid } = req.query;
        const { rating } = req.body;

        const product = await Product.findOne({ pid }).exec();
        if (!product) return res.status(404).json({ msg: "Product not found" });

        product.ratings = [
            ...product.ratings.filter((it) => it.customer != req.user),
            { ...rating, customer: req.user },
        ];
        product.last_modified = new Date();
        await product.save();
        res.status(200).send("Product rated successfully!");
    } catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
});
module.exports = router;
