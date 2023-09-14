const router = require("express").Router();
const { User } = require("../../models");
router.get("/", (req, res) => {
    res.send("OTP endpoint");
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
            return res
                .status(404)
                .send(`tuned:Account with email: ${email} does not exist!`);
        if (user.otp != otp)
            return res.status(400).send("tuned:Incorrect OTP.");
        user.email_verified = true;
    }
    await user.save();
    res.send("verified");
});
module.exports = router;
