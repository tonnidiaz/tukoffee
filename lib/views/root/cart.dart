import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/auth/login.dart';
import 'package:lebzcafe/widgets/cart_item.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/widgets/tu/common.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final StoreCtrl _storeCtrl = Get.find();
  final AppCtrl _appCtrl = Get.find();
  Worker? _cartWorker;
  double _total = 0;
  @override
  void dispose() {
    _cartWorker?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _init0();

      _cartWorker = ever(_storeCtrl.cart, (cart) {
        _setupTotal(cart);
      });
    });
  }

  _setupTotal(Map<String, dynamic> cart) {
    double total = 0;
    if (cart.isNotEmpty) {
      for (var it in cart["products"]) {
        total += (it["product"]["price"] * it["quantity"]).toDouble();
      }
    }

    setState(() {
      _total = total;
    });
  }

  _init0() async {
    if (_appCtrl.user.isEmpty) {
      gpop();
      pushTo(const LoginPage(
        to: '/cart',
      ));
      return;
    }
    _init();
  }

  _init() async {
    _storeCtrl.setcartFetched(false);
    var _id = _appCtrl.user["_id"];
    if (_id != null) {
      await setupCart(_id);
    } else {
      _storeCtrl.setcartFetched(true);
    }
  }

  Future<void> setupCart(String uid) async {
    _storeCtrl.setcartFetched(false);
    try {
      final res = await apiDio().get("/user/cart?user=$uid");
      if (context.mounted) {
        //_storeCtrl.setcart(res.data["cart"]);
        _setupTotal(res.data['cart']);
      }
    } catch (e) {
      clog("FETCH CART ERR");
      clog(e);
    }
    _storeCtrl.setcartFetched(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 14, title: const Text('Cart'), actions: [
        PopupMenuButton(
            itemBuilder: (context) => [
                  const PopupMenuItem(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Clear cart'))
                ])
      ]),
      bottomNavigationBar: TuBottomBar(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TOTAL:",
                    style: Styles.h4(),
                  ),
                  Text(
                    "R${roundDouble(_total, 2)}",
                    style: Styles.h4(),
                  )
                ],
              ),
              mY(5),
              Obx(
                () => TuButton(
                  width: double.infinity,
                  bgColor: Colors.black87,
                  text: "Proceed to checkout",
                  onPressed: _storeCtrl.cart.isEmpty ||
                          _storeCtrl.cart["products"].isEmpty
                      ? null
                      : () {
                          pushNamed("/order/checkout");
                        },
                ),
              )
            ]),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _init();
        },
        child: Obx(() => !_storeCtrl.cartFetched.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _storeCtrl.cart.isEmpty || _storeCtrl.cart["products"].isEmpty
                ? Center(
                    child: Text(
                      "Cart empty",
                      style: Styles.h3(isLight: true, color: TuColors.text2),
                    ),
                  )
                : Container(
                    child: Column(
                      children: [
                        mY(topMargin),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return CartItem(
                                  item: _storeCtrl.cart["products"]
                                      .elementAt(index));
                            },
                            itemCount: _storeCtrl.cart["products"].length,
                          ),
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }
}
