const jwt = require("jsonwebtoken");
const { User } = require("../models");

const auth = async (req, res, next) => {
    return await authenticator(req, res, next, true)
};
const lightAuth = async (req, res, next) => {
    return await authenticator(req, res, next, false)
};

const authenticator = async (req, res,next, isRequired)=>{
    const { authorization } = req.headers;
    if (authorization) {
        const tkn = authorization.split(" ")[1];      
     if (tkn){
         try {
            const {payload} = jwt.verify(tkn, process.env.PRIVATE_KEY);
            if (payload && payload.id){
                const user =  await User.findById(payload.id).exec()
                    req.user = user
            }
        } catch (e) {
            console.log(e)
        }
      }
       
    } else {
        console.log("Not authenticated")
    }
    if (!req.user && isRequired) return res.status(401).send("tuned:Not authenticated!");
    next()
}
module.exports = { auth, lightAuth };
