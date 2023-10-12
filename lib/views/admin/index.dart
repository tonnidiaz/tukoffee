import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/admin/accounts.dart';
import 'package:frust/views/admin/dashboard.dart';
import 'package:frust/views/admin/orders.dart';
import 'package:frust/views/admin/products.dart';
import 'package:frust/widgets/common3.dart';
import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';

class DashCtrl extends GetxController {
  RxInt selectedTab = 0.obs;
  RxList<dynamic> orders = [].obs;
  RxList<dynamic> customers = [].obs;
  RxDouble revenue = 0.0.obs;

  final RxList<dynamic> selectedProducts = [].obs;
  void setSelectedProducts(List<dynamic> val) {
    selectedProducts.value = val;
  }

  final RxBool productsFetched = false.obs;
  void setProductsFetched(bool val) {
    productsFetched.value = val;
  }

  Rx<Map<String, dynamic>?> data = (null as Map<String, dynamic>?).obs;
  setData(Map<String, dynamic>? val) {
    data.value = val;
  }
}

class DashboardPageArgs {
  final int tab;
  const DashboardPageArgs({this.tab = 0});
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _ctrl = Get.put(DashCtrl());

  DashboardPageArgs? _args;

  void _onBottonNavitemTap(int val) {
    _ctrl.selectedTab.value = val;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var args = ModalRoute.of(context)!.settings.arguments;
      _args =
          args != null ? args as DashboardPageArgs : const DashboardPageArgs();
      _ctrl.selectedTab.value = _args!.tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      const Tab(label: 'Dashboard', icon: 'br-apps.svg'),
      const Tab(label: 'Products', icon: 'br-box-open-full.svg'),
      const Tab(label: 'Orders', icon: 'br-person-dolly.svg'),
      const Tab(label: 'Accounts', icon: 'br-users.svg'),
    ];
    return Scaffold(
      bottomNavigationBar: Obx(() {
        var index = _ctrl.selectedTab.value;
        return BottomNavigationBar(
            currentIndex: index,
            onTap: _onBottonNavitemTap,
            items: tabs
                .asMap()
                .entries
                .map(
                  (e) => BottomNavigationBarItem(
                    icon: e.value.icon.runtimeType == String
                        ? svgIcon(
                            name: "assets/icons/${e.value.icon}",
                            color: index != e.key
                                ? TuColors.note
                                : TuColors.primary,
                          )
                        : Icon(
                            e.value.icon,
                            color: index != e.key
                                ? TuColors.text2
                                : TuColors.primary,
                          ),
                    label: e.value.label,
                  ),
                )
                .toList());
      }),
      body: WillPopScope(
        onWillPop: () async {
          clog("On will pop");
          if (_ctrl.selectedTab.value != 0) {
            _ctrl.selectedTab.value = 0;
            return false;
          }
          return true;
        },
        child: Obx(() => adminPages.elementAt(_ctrl.selectedTab.value)),
      ),
    );
  }
}

class Tab {
  final String label;
  final String? route;
  final dynamic icon;
  const Tab({required this.label, this.route, required this.icon});
}

final List<Widget> adminPages = [
  const Dashboard(),
  const Products(),
  const OrdersPage(),
  const Accounts(),
];
