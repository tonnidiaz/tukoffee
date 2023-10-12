import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/cart.dart';
import 'package:frust/views/home.dart';
import 'package:frust/views/root/account_tab.dart';
import 'package:frust/views/shop/index.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/icons/iconoir.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

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
  Widget build(BuildContext context) {
    List<TuPage> indexTabs = [
      TuPage('/~/home', const HomePage(),
          label: 'Home', ic: const Icon(Icons.home_outlined)),
      TuPage('/~/shop', const ShopPage(),
          label: 'Shop', ic: const Icon(Icons.store_outlined)),
      TuPage('/~/cart', const CartPage(),
          label: 'Cart', ic: const Icon(Icons.shopping_cart_outlined)),
      TuPage('/~/account', const AccountTab(),
          label: 'Account', ic: const Icon(Icons.person_outline)),
    ];
    return WillPopScope(
      onWillPop: () async {
        clog('Willpop');
        return false;
      },
      child: Scaffold(
        body: Obx(() => indexTabs[ctrl.tab.value].widget),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
              currentIndex: IndexPage.ctrl.tab.value,
              onTap: _onTabTap,
              items: indexTabs
                  .map((e) =>
                      BottomNavigationBarItem(icon: e.ic!, label: e.label))
                  .toList()),
        ),
      ),
    );
  }
}
