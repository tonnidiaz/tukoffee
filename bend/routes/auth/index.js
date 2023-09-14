const router = require("express").Router();
const bcrypt = require("bcrypt");
const { User } = require("../../models");
const {
    genToken,
    genOTP,
    randomInRange,
    sendSMS,
} = require("../../utils/functions");
const { auth, lightAuth } = require("../../utils/middleware");
const { UserPermissions } = require("../../utils/constants");
const otpRouter = require("./otp");
const passwordRouter = require("./password");
const importantEmails = ["tonnidiazed@gmail.com", "clickbait4587@gmail.com"];

router.post("/signup", async (req, res) => {
    try {
        const { email, first_name, last_name, phone } = req.body;

        //Email not required / not yet verified
        //Find user by number and add the other fields
        //Save user ,gen token

        const user = await User.findOne({ phone }).exec();
        user.email = email;
        user.first_name = first_name;
        user.last_name = last_name;
        await user.save();
        /* 
            Verify email route
            if (importantEmails.indexOf(email) != -1)
                user.permissions = UserPermissions.delete;
            await user.save(); */

        const token = genToken({ id: user._id });
        res.json({ token });
    } catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
});

router.post("/login", lightAuth, async (req, res) => {
    try {
        const { email, password, phone } = req.body;

        if (req.user && !password) {
            //Loging in with token
            res.json({ user: { ...req.user.toJSON() } });
            return;
        } else if (phone && password) {
            let user = await User.findOne({ phone }).exec();
            if (user) {
                const passValid = bcrypt.compareSync(password, user.password);

                if (!passValid)
                    return res.status(401).send("tuned:Incorrect password.");
                const token = genToken({ id: user._id });
                res.json({ user: { ...user.toJSON() }, token });
            } else {
                user = new User();
                user.phone = phone;
                user.password = bcrypt.hashSync(password, 10);

                const otp = randomInRange(1000, 9999);
                user.otp = otp;
                console.log(otp);
                // Send the otp && save user
                const number = phone.startsWith("+")
                    ? phone
                    : "+27" + phone.slice(1);

                // const smsRes = await sendSMS(number, `Tukoffee - your code is: ${otp}`)
                //console.log(smsRes.data)
                await user.save();
                res.json({ msg: "OTP Generated" });
            }
        } else if (email && password) {
            const user = await User.findOne({ email }).exec();
            if (!user)
                return res.status(401).send("tuned:Account does not exists.");
            const passValid = bcrypt.compareSync(password, user.password);

            if (!passValid)
                return res.status(401).send("tuned:Incorrect password.");

            const token = genToken({ id: user._id });
            res.json({ user: { ...user.toJSON(), password: password }, token });
        } else {
            res.status(400).send("tuned:Provide all fields");
        }
    } catch (e) {
        console.log(e);
        res.status(500).send("tuned:Something went wrong");
    }
});

router.post("/verify-email", async (req, res) => {
    const { email, otp } = req.body;

    try {
        const user = await User.findOne({ email }).exec();
        if (!otp) {
            const pin = randomInRange(1000, 9999);
            //TODO: Send real pin
            console.log(pin)
            user.otp = pin;
        } else {
            if (user.otp == otp) {
                user.email_verified = true;
                if (importantEmails.includes(email))
                    user.permissions = UserPermissions.delete;
            } else {
                return res.status(400).send("tuned:Incorrect OTP");
            }
        }
        await user.save();
        res.json({user: user.toJSON()})
    } catch (e) {
        console.log(e)
        res.status(500).send('tuned:Something went wrong')
    }
});
router.use("/password", passwordRouter);

router.use("/otp", otpRouter);
module.exports = router;
