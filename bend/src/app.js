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
const http_errors_1 = __importDefault(require("http-errors"));
const express_1 = __importDefault(require("express"));
const path_1 = __importDefault(require("path"));
const cookie_parser_1 = __importDefault(require("cookie-parser"));
const morgan_1 = __importDefault(require("morgan"));
const index_1 = __importDefault(require("./routes/index"));
const order_1 = __importDefault(require("./routes/order"));
const admin_1 = __importDefault(require("./routes/admin"));
const users_1 = __importDefault(require("./routes/users"));
const message_1 = __importDefault(require("./routes/message"));
const orders_1 = __importDefault(require("./routes/orders"));
const products_1 = __importDefault(require("./routes/products"));
const auth_1 = __importDefault(require("./routes/auth"));
const search_1 = __importDefault(require("./routes/search"));
const stores_1 = __importDefault(require("./routes/stores"));
const user_1 = __importDefault(require("./routes/user"));
const hooks_1 = __importDefault(require("./routes/hooks"));
const app = (0, express_1.default)();
const mongoose_1 = __importDefault(require("mongoose"));
const multer_1 = __importDefault(require("multer"));
const cors_1 = __importDefault(require("cors"));
const constants_1 = require("./utils/constants");
const envPath = constants_1.DEV ? path_1.default.resolve(process.cwd(), '.env') : '/etc/secrets/prod.env';
require("dotenv").config({ path: envPath });
// view engine setup
app.set('views', path_1.default.join(__dirname, 'views'));
app.set('view engine', 'pug');
app.use((0, cors_1.default)());
app.use((0, cors_1.default)({
    origin: '*'
}));
/*------------------ mongodb ----------------------- */
function connectMongo() {
    return __awaiter(this, void 0, void 0, function* () {
        let mongoURL = process.env.MONGO_URL + "tukoffee";
        try {
            console.log(mongoURL);
            yield mongoose_1.default.connect(mongoURL);
            console.log('Connection established');
        }
        catch (e) {
            console.log('Could not establish connection');
            console.log(e);
        }
    });
}
(function () {
    return __awaiter(this, void 0, void 0, function* () { yield connectMongo(); });
})();
/*------------------ End mongodb ----------------------- */
app.use((0, morgan_1.default)('dev'));
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: false }));
app.use((0, cookie_parser_1.default)());
app.use(express_1.default.static(path_1.default.join(__dirname, 'public')));
const parser = (0, multer_1.default)().none();
app.use('/', index_1.default);
app.use('/users', users_1.default);
app.use('/admin', admin_1.default);
app.use('/order', order_1.default);
app.use('/orders', orders_1.default);
app.use('/hooks', hooks_1.default);
app.use('/products', parser, products_1.default);
app.use('/auth', parser, auth_1.default);
app.use('/search', parser, search_1.default);
app.use('/user', parser, user_1.default);
app.use('/stores', parser, stores_1.default);
app.use('/message', parser, message_1.default);
// catch 404 and forward to error handler
app.use(function (req, res, next) {
    next((0, http_errors_1.default)(404));
});
// error handler
app.use(function (err, req, res, next) {
    // set locals, only providing error in development
    res.locals.message = err.message;
    res.locals.error = req.app.get('env') === 'development' ? err : {};
    // render the error page
    res.status(err.status || 500);
    res.render('error');
});
exports.default = app;
