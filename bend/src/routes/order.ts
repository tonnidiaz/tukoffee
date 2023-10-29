import express, { Request } from "express";
import { Cart, Order, User, Product, Refund } from "../models";
import { paystackAxios, tunedErr, yocoAxios } from "../utils/functions";
import io from "../utils/io";
import { IObj } from "../utils/interfaces";
import { authMid } from "@/middleware/auth.mid";
import { OrderStatus } from "@/utils/enums";
import auth from "./auth";
const router = express.Router();
 
const genOID = async () => {
    const oid = Math.floor(Math.random() * 999999) + 1;
    const exists = await Order.findOne({ oid }).exec();
    if (exists != null) return genOID();
    return oid;
};

router.post("/cancel", authMid, async (req: Request, res) => {
    const { ids, userId } = req.body;
    console.log(userId)
    const { action } = req.query;
    try {
        for (let id of ids) {
            try {
                if (action == "delete") {
                    // Remove order from user document
                    const order = await Order.findById(id).exec();

                    const user = await User.findById(order?.customer).exec();
                    await Order.findByIdAndDelete(id).exec();
                    if (user) {
                        user.orders = user.orders.filter((o) => o != id);
                        await user.save();
                        console.log(`Order #${id} deleted!`);
                    }
                } else {

                    //Apply for refund first
                    const order = await Order.findById(id).exec()
                    if (!order) return tunedErr(res, 400, 'Order not found');
                    if (order.status == OrderStatus.cancelled){
                        continue;
                    }
                    try{
                        if (order.paystackData?.reference){
                            console.log("REQUESTING PAYSTACK REFUND...")
                            const refundRes = await paystackAxios().post('/refund', {transaction: order.paystackData.reference});
                            if (refundRes.data.status){
                                const refund = new Refund()
                                refund.userId = order.customer;
                                refund.paystackId = refundRes.data.data.id
                                await refund.save()
                                await User.findByIdAndUpdate(order.customer, {$push: {
                                    refunds: refund._id
                                }}).exec()
                            }
     
                        }
                        else if (order.yocoData?.payload?.id){
                            console.log("REQUESTING YOCO REFUND...")
                            const refundRes = await yocoAxios().post(`/checkouts/${order.yocoData?.payload?.id}/refund`);
                            console.log(refundRes)
                            const refund = new Refund()
                            refund.userId = order.customer;
                            refund.yocoId = refundRes.data.refundId
                            await refund.save()
                            await User.findByIdAndUpdate(order.customer, {$push: {
                                refunds: refund._id
                            }}).exec()
                        }
                        
                    }catch(e: any){
                        console.log(e)
                        const msg = e?.response?.data?.message
                        console.log(msg)
                        order.status = OrderStatus.cancelled
                        await order.save()
                        continue
                     
                    }
                   
           
                    order.status = OrderStatus.cancelled
                    await order?.save()
                    console.log(`Order #${id} cancelled!`);
                     //Update inventory
            for (let item of order.products){
                await Product.findByIdAndUpdate(item.product._id, {$inc: {
                    quantity:  item.quantity
                }}).exec()
            }
                }
            } catch (e) {
                console.log(e);
                continue;
            }
        }

        const orders = userId
            ? await Order.find({ customer: userId }).exec()
            : await Order.find().exec();
        let populatedOrders = <IObj>[];
        for (let o of orders) {
            let ord = await (
                await o.populate("customer")
            ).populate("products.product");
            populatedOrders.push(ord);
        }
        res.json({ orders: populatedOrders.map((it) => it.toJSON()) });
    } catch (e) {
        console.log(e);
        return tunedErr(res, 500, 'Something went wrong')
    }
});
router.post("/create", auth, async (req, res) => {
    const { cartId, mode } = req.query;
    const { address, store, collector, yocoData, paystackData, form } = req.body;
    try {
        if (cartId) {
            // The customer has paid. so get the cart and create an order
            // Also delete the user cart
            console.log("Creating order for cart: " + cartId);
            let cart = await Cart.findById(cartId).exec();
            if (!cart) return tunedErr(res, 400, "Carr not found")
            const user = await User.findById(cart.customer).exec();
            if (!user)
                return tunedErr(res, 400, "Customer not found")
            
            cart = await cart.populate('products.product')
            
            const order = new Order();
            order.oid = await genOID();
            order.customer = user._id;
            order.products = cart.products;
            order.delivery_address = address;
            order.mode = Number(mode);
            order.store = store;
            order.collector = collector;
            order.yocoData = yocoData
            order.paystackData = paystackData
            if (form){
                for (let key of Object.keys(form)){
                order.set(key, form[key])
            }
            }
            
            await order.save();
            // add order to user's orders
            user.orders.push(order._id);
            await user.save();

            //Update inventory
            for (let item of order.products){
                await Product.findByIdAndUpdate(item.product._id, {$inc: {
                    quantity: - item.quantity
                }}).exec()
            }
            // delete the cart
            await Cart.findByIdAndUpdate(cartId, {$set: {
                products: []
            }}).exec()
            await cart.save()
            //user.cart = null
            //await user.save()
            console.log("Cart deleted");
            io.emit('order', {
                orderId: order.oid, userId: order.customer})
            console.log("On order emitted")
            res.json({ order: { ...order.toJSON(), customer: null } });
        } else {
            res.status(400).json({ msg: "Provide cart id" });
        }
    } catch (e) {
        console.log(e);
        return tunedErr(res, 500, "Something went wrong")
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
        await order.save()
        res.json({id: order.oid, order: await  (await order.populate("customer")).populate('store')}) 
    }
    catch(e){
       tunedErr(res, 500, "Something went wrong!",e)
    }
})
export default router;
