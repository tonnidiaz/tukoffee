const router = require("express").Router();
const bcrypt = require("bcrypt");
const { User } = require("../../models");
const { genToken } = require("../../utils/functions");

router.post("/signup", async (req, res) => {
        try{
                const {email, password} = req.body;
                if ( email && password){
                    const existingUser = await User.findOne({email}).exec()
                    if (existingUser) return res.status(400).json({msg: "Account already exists."})
                    const hashedPass = await bcrypt.hash(password, 10)
                    const user = new User();
                    user.username = email;
                    user.email = email;
                    user.password = hashedPass;
                    await user.save();
                    const token = genToken({email})
                    res.json({user: {
                        id: user._id.toString(),
                        username: user.username, email: user.email, cart: user.cart, token}})
                }
                else{
                    res.status(400).json({msg: "Provide all fields"})
                }
        }
        catch(e){
            console.log(e);
            res.status(500).json({msg: "Something went wrong"})
        }})

router.post("/login", async (req, res) => {
        try{
                const {email, password} = req.body;
                if ( email && password){
                    const user = await User.findOne({email}).exec()
                    if (!user) return res.status(401).json({msg: "Account does not exists."});
                    const passValid = bcrypt.compareSync(password, user.password)
                    if (!passValid) return res.status(401).json({msg: "Invalid password."});
                    console.log(password, passValid)
                    const token = genToken({email})
                    res.json({user: {  id: user._id.toString(),username: user.username, email: user.email, cart: user.cart, token}})
                }
                else{
                    res.status(400).json({msg: "Provide all fields"})
                }
        }
        catch(e){
            console.log(e);
            res.status(500).json({msg: "Something went wrong"})
        }})
module.exports = router;