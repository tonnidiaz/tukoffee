import "package:flutter/material.dart";

import "package:lebzcafe/views/root/account_tab.dart";
import "package:lebzcafe/views/root/cart.dart";
import "package:lebzcafe/views/root/home.dart";
import "package:lebzcafe/views/root/shop/index.dart";
import "package:tu/tu.dart";

class IndexCtrl extends GetxController {
  RxInt tab = 0.obs;
  setTab(int val) {
    tab.value = val;
  }
}

class IndexPage extends StatefulWidget {
  static IndexCtrl ctrl = Get.put(IndexCtrl());
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final ctrl = IndexPage.ctrl;
  void _onTabTap(int val) {
    ctrl.setTab(val);
  }

  @override
  void initState() {
    super.initState();
    clog("ROOT MOUNTED");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        _onTabTap(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TuPage> indexTabs = [
      TuPage("/~/home", const HomePage(),
          label: "Home", svg: "br-home", icon: none()),
      TuPage("/~/shop", const ShopPage(),
          label: "Shop", svg: "br-shop", icon: none()),
      TuPage("/~/cart", const CartPage(),
          label: "Cart", svg: "br-shopping-cart", icon: none()),
      TuPage("/~/account", const AccountTab(),
          label: "Account", svg: "br-user", icon: none()),
    ];
    return WillPopScope(
      onWillPop: () async {
        if (ctrl.tab.value != 0) {
          ctrl.tab.value = 0;
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Obx(() => indexTabs[ctrl.tab.value].widget),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
              currentIndex: IndexPage.ctrl.tab.value,
              onTap: _onTabTap,
              items: indexTabs
                  .asMap()
                  .entries
                  .map((e) => BottomNavigationBarItem(
                      icon: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                              color: IndexPage.ctrl.tab.value == e.key
                                  ? colors.primaryFade
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100)),
                          child: svgIcon(
                            name: e.value.svg!,
                            size: 18,
                            color: ctrl.tab.value != e.key
                                ? colors.note
                                : colors.onBackground,
                          )),
                      label: e.value.label))
                  .toList()),
        ),
      ),
    );
  }
}
