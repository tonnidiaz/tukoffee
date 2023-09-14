var express = require('express');
var router = express.Router();
const { User } =  require("../models/index")
/* GET users listing. */
router.get('/', async function(req, res, next) {

    const { id } = req.query

    let users = []
    try{
    if (id){
        const user = await User.findById(id).exec()
        if (!user) return res.status(404).json({msg: "User not found"})
        users.push(user)
    }
    else {
        users = await User.find().exec()
    }
  res.json({users: users.map(it=>it.toJSON())})}
  catch(e){
    console.log(e)
    res.status(500).json({msg: "Something went wrong!"})
  }
});

router.post('/delete', async (req, res)=>{
    try {
        const{ ids } = req.body;
        // Delete all users from the provided ids
        for (let id of ids){
            try{
                console.log(`Deleting ${id}`);
                await User.findByIdAndDelete(id).exec() 
            }
             catch(e){
                console.log(e);
                continue
             }
        }
        res.send("Users deleted")
       
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: "Something went wrong"})
    }
})

module.exports = router;
