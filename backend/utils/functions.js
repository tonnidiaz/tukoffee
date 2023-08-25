const jwt = require("jsonwebtoken");

const onGetGenToken = async (req, res)=>{

    const purchase_units = [{
        amount: {
            value: 40,
            currency_code: "USD"
        }
    }]
    const data = {purchase_units}
    const tkn = genToken(data)
    res.send(tkn)
}

const genToken = (data, exp) =>{
    const { PRIVATE_KEY} = process.env;
    return exp ? jwt.sign({
        data, 
    }, PRIVATE_KEY, {expiresIn: exp}) : jwt.sign({data}, PRIVATE_KEY )
}

module.exports = { genToken, onGetGenToken}