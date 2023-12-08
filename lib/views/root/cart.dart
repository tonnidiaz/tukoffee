import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/controllers/store_ctrl.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/views/auth/login.dart";
import "package:lebzcafe/widgets/cart_item.dart";
import "package:lebzcafe/widgets/prompt_modal.dart";
import "package:lebzcafe/widgets/tu/common.dart";
import "package:tu/tu.dart";

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final StoreCtrl _storeCtrl = Get.find();
  final AppCtrl _appCtrl = Get.find();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _init0();
    });
  }

  _init0() async {
    if (_appCtrl.user.isEmpty) {
      gpop();
      pushTo(const LoginPage(
        to: "/cart",
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
        _storeCtrl.setcart(res.data["cart"]);
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
      appBar: AppBar(titleSpacing: 14, title: const Text("Cart"), actions: [
        PopupMenuButton(
            itemBuilder: (context) => [
                  PopupMenuItem(
                      enabled: _storeCtrl.cart["products"].isNotEmpty,
                      onTap: () async {
                        Tu.dialog(PromptDialog(
                          title: "Clear cart",
                          msg: "Are you sure you want  to clear cart?",
                          okTxt: "Yes",
                          onOk: () async {
                            try {
                              gpop();
                              showProgressSheet();
                              final res = await apiDio().post('/user/cart',
                                  queryParameters: {"action": "clear"});
                              _storeCtrl.setcart(res.data["cart"]);
                              gpop();
                            } catch (e) {
                              errorHandler(e: e, msg: "Failed to clear cart");
                            }
                          },
                        ));
                      },
                      child: Text("Clear cart"))
                ])
      ]),
      bottomNavigationBar: TuBottomSheet(
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
                    style: styles.h4(),
                  ),
                  Obx(
                    () => Text(
                      "R${roundDouble(_storeCtrl.total.value, 2)}",
                      style: styles.h4(),
                    ),
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
                      style: styles.h3(isLight: true, color: colors.text2),
                    ),
                  )
                : Column(
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
                  )),
      ),
    );
  }
}
