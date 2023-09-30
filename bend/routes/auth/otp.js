const router = require("express").Router();
const { User } = require("../../models");
const { tunedErr, randomInRange, genToken } = require("../../utils/functions");
router.post("/resend", async (req, res) => {
    try {
        const {phone, email} = req.body
        const user =
        phone ? (await User.findOne({ phone }).exec()) : email ?
        (await User.findOne({ email }).exec()) : null;

      if (!user) return tunedErr(res, 400, "User does not exist")
            const otp = randomInRange(1000, 9999)
            console.log(otp)
            //TODO: Send OTP via SMS
            user.otp = otp;
            await user.save();
        
        res.send("OTP endpoint");
    } catch (e) {
        return tunedErr(res, 500, "Something went wrong")
    }
});
router.post("/verify", async (req, res) => {
    const { phone, email, otp } = req.body;
    let user;
    if (!otp) return res.status(400).send("tuned:Please provide OTP.");
    if (phone) {
        // Phone verification
        user = await User.findOne({ phone }).exec();
        if (!user)
            return res
                .status(404)
                .send(`tuned:Account with number: ${phone} does not exist!`);
        if (user.otp != otp)
            return res.status(400).send("tuned:Incorrect OTP.");
        user.phone_verified = true;
        user.otp = null
    } else if (email) {
        // Email verification
        user = await User.findOne({ email }).exec();
        if (!user)
            return tunedErr(res, 400, `Account with email: ${email} does not exist!`)
        if (user.otp != otp)
            return tunedErr(res, 400, "tuned:Incorrect OTP.");
        user.email_verified = true;
    }
    await user.save();
    const token = genToken({ id: user._id });
                res.json({ user: { ...user.toJSON() }, token });
});
module.exports = router;
