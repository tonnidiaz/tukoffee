const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');

const indexRouter = require('./routes/index');
const orderRouter = require('./routes/order');
const adminRouter = require('./routes/admin');
const usersRouter = require('./routes/users');
const ordersRouter = require('./routes/orders');
const productsRouter = require('./routes/products');
const authRouter = require('./routes/auth');
const searchRouter = require('./routes/search');
const storesRouter = require('./routes/stores');
const userRouter = require('./routes/user');
const { onGetGenToken } = require("./utils/functions")
const app = express();
const { default: mongoose } = require('mongoose');
const multer = require('multer');
const cors = require('cors');
require("dotenv").config();
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');


app.use(cors()) 
 app.use(cors({
  origin: '*'
}))
/*------------------ mongodb ----------------------- */
async function connectMongo(){
    let mongoURL = process.env.MONGO_URL + "tukoffee"
    try {
        console.log(mongoURL);
      await mongoose.connect(mongoURL);
      console.log('Connection established');
    }
    catch(e) {
      console.log('Could not establish connection')
     console.log(e); 
    }
  }
  (async function(){await connectMongo()})()
  /*------------------ End mongodb ----------------------- */
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

const parser = multer().none();
app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/admin', adminRouter);
app.use('/order', orderRouter);
app.use('/orders', ordersRouter);
app.use('/products', parser, productsRouter);
app.use('/auth', parser, authRouter);
app.use('/search', parser, searchRouter);
app.use('/user', parser, userRouter);
app.use('/stores', parser, storesRouter);
app.get("/gen-token", onGetGenToken)
// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
