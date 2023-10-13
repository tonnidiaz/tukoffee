import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/root/account_tab.dart';
import 'package:lebzcafe/views/root/cart.dart';
import 'package:lebzcafe/views/root/home.dart';
import 'package:lebzcafe/views/root/shop/index.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:get/get.dart';

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
      TuPage('/~/home', const HomePage(), label: 'Home', svg: 'br-home'),
      TuPage('/~/shop', const ShopPage(), label: 'Shop', svg: 'br-shop'),
      TuPage('/~/cart', const CartPage(),
          label: 'Cart', svg: 'br-shopping-cart'),
      TuPage('/~/account', const AccountTab(),
          label: 'Account', svg: 'br-user'),
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
                      icon: svgIcon(
                          color: IndexPage.ctrl.tab.value != e.key
                              ? TuColors.surface600
                              : TuColors.primary,
                          name: e.value.svg!),
                      label: e.value.label))
                  .toList()),
        ),
      ),
    );
  }
}
