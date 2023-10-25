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
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const functions_1 = require("../utils/functions");
const router = (0, express_1.Router)();
router.post('/send', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { body } = req;
    console.log(body);
    let buff = (0, functions_1.getStoreDetails)();
    const r = yield (0, functions_1.sendMail)(`${buff.store.name} app Feedback message`, `
<h2>${buff.store.name} app</h2>
<h4>Message from: <b>${body.name},</b>&nbsp;&nbsp;<a href='mailto:${body.email}'>${body.email}</a></h4>
${body.msg}`, buff.store.email, body.email);
    if (!r)
        return (0, functions_1.tunedErr)(res, 500, 'Failed to send email');
    res.send('ok');
}));
exports.default = router;
