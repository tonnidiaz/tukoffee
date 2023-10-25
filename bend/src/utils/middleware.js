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
exports.lightAuth = exports.auth = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const models_1 = require("../models");
const auth = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    return yield authenticator(req, res, next, true);
});
exports.auth = auth;
const lightAuth = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    return yield authenticator(req, res, next, false);
});
exports.lightAuth = lightAuth;
const authenticator = (req, res, next, isRequired) => __awaiter(void 0, void 0, void 0, function* () {
    const { authorization } = req.headers;
    if (authorization) {
        const tkn = authorization.split(" ")[1];
        if (tkn) {
            try {
                const { payload } = jsonwebtoken_1.default.verify(tkn, process.env.PRIVATE_KEY);
                if (payload && payload.id) {
                    const user = yield models_1.User.findById(payload.id).exec();
                    req.user = user;
                }
            }
            catch (e) {
                console.log(e);
            }
        }
    }
    else {
        console.log("Not authenticated");
    }
    if (!req.user && isRequired)
        return res.status(401).send("tuned:Not authenticated!");
    next();
});
