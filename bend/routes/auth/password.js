const { User } = require("../../models");
const { genOTP, randomInRange } = require("../../utils/functions");
const { auth, lightAuth } = require("../../utils/middleware");
const bcrypt = require("bcrypt");
const router = require("express").Router();

router.post("/reset", async (req, res) => {
    try {
        // If phone/email && no otp, genotp else verify otp
        const { act } = req.query;
        const { email, phone, otp, password } = req.body;
        const user =
            (await User.findOne({ phone }).exec()) ??
            (await User.findOne({ email }).exec());
        if (!user) {
            return res.status(400).send("tuned:Account does not exist");
        }
        if (act == "reset") {
            console.log("password reset");
            user.password = bcrypt.hashSync(password, 10);
        } else if (act == "verify-otp") {
            if (otp == user.otp) {
                console.log("OTP Verified");
                user.otp = null;
            }else{
            return res.status(400).send("tuned:Incorrect OTP");}
        } else if (act == "gen-otp") {
            const _otp = randomInRange(1000, 9999);
            user.otp = _otp;
            //send the sms
            console.log(_otp);
        }

        await user.save();
        return res.send("OTP sent");
    } catch (e) {
        console.log(e);
        res.status(500).send("Something went wrong!");
    }
});
router.post("/verify", lightAuth, async (req, res) => {
    try {
        const { password } = req.body;
        const oldPassValid = bcrypt.compareSync(password, req.user.password);
        if (!oldPassValid) {
            return res.status(401).send("tuned:Incorrect password!");
        }
        res.send("Password Ok");
    } catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
});
router
    .route("/change")

    .post(auth, async (req, res) => {
        try {
            const { old: oldPass, new: newPass } = req.body;
            const oldPassValid = bcrypt.compareSync(oldPass, req.user.password);
            if (!oldPassValid) {
                res.status(401).send("tuned:Incorrect password!");
            } else {
                const newHash = bcrypt.hashSync(newPass, 10);
                req.user.password = newHash;
                await req.user.save();
                res.send(newPass);
            }
        } catch (e) {
            console.log(e);
            res.status(500).send("tuned:Something went wrong");
        }
    });

module.exports = router;
