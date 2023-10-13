import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/cart_item.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final StoreCtrl _storeCtrl = Get.find();
  final AppCtrl _appCtrl = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  _init() async {
    _storeCtrl.setcartFetched(false);
    var email = _appCtrl.user["email"];
    if (email != null) {
      setupCart(email);
    } else {
      _storeCtrl.setcartFetched(true);
    }
  }

  Future<void> setupCart(String email) async {
    _storeCtrl.setcartFetched(false);
    try {
      final res = await dio.get("$apiURL/user/cart?user=$email");
      _storeCtrl.setcart(res.data["cart"]);
    } catch (e) {
      clog(e);
    }
    _storeCtrl.setcartFetched(true);
  }

  final double _bottomSheetH = 90;
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            color: cardBGLight,
            border: Border(top: BorderSide(color: appBGLight, width: 1.5))),
        padding: defaultPadding,
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
                  Obx(() {
                    double total = 0;
                    if (_storeCtrl.cart.isNotEmpty) {
                      for (var it in _storeCtrl.cart["products"]) {
                        total += (it["product"]["price"] * it["quantity"])
                            .toDouble();
                      }
                    }
                    total += _storeCtrl.deliveryFee.value;
                    return Text(
                      "R${roundDouble(total, 2)}",
                      style: Styles.h4(),
                    );
                  })
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
                          Navigator.pushNamed(context, "/order/checkout");
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
