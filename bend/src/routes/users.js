"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const router = express_1.default.Router();
const index_1 = require("../models/index");
/* GET users listing. */
router.get('/', function (req, res, next) {
    return __awaiter(this, void 0, void 0, function* () {
        const { id } = req.query;
        let users = [];
        try {
            if (id) {
                const user = yield index_1.User.findById(id).exec();
                if (!user)
                    return res.status(404).json({ msg: "User not found" });
                console.log(user.address);
                users.push(user);
            }
            else {
                users = (yield index_1.User.find().exec()).filter(it => it.email_verified && it.first_name);
            }
            res.json({ users: users.map(it => it.toJSON()) });
        }
        catch (e) {
            console.log(e);
            res.status(500).json({ msg: "Something went wrong!" });
        }
    });
});
router.post('/delete', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { ids } = req.body;
        // Delete all users from the provided ids
        for (let id of ids) {
            try {
                console.log(`Deleting ${id}`);
                yield index_1.User.findByIdAndDelete(id).exec();
                //Delete cart, orders, and reviews
                yield index_1.Cart.findOneAndDelete({ customer: id }).exec();
                yield index_1.Order.findOneAndDelete({ customer: id }).exec();
                yield index_1.Review.findOneAndDelete({ user: id }).exec();
            }
            catch (e) {
                console.log(e);
                continue;
            }
        }
        res.send("Users deleted");
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ msg: "Something went wrong" });
    }
}));
exports.default = router;
