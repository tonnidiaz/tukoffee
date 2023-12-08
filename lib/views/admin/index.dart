import "package:flutter/material.dart";
import "package:lebzcafe/views/admin/accounts.dart";
import "package:lebzcafe/views/admin/dashboard.dart";
import "package:lebzcafe/views/admin/orders.dart";
import "package:lebzcafe/views/admin/products.dart";
import "package:tu/tu.dart";

final Map<String, dynamic> initDashData = {
  "products": [],
  "orders": [],
  "customers": [],
  "reviews": [],
};

class DashCtrl extends GetxController {
  RxInt tab = 0.obs;
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

  RxMap<String, dynamic> data = initDashData.obs;
  setData(Map<String, dynamic> val) {
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
    _ctrl.tab.value = val;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var args = ModalRoute.of(context)!.settings.arguments;
      _args =
          args != null ? args as DashboardPageArgs : const DashboardPageArgs();
      _ctrl.tab.value = _args!.tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      const Tab(label: "Dashboard", icon: "br-apps"),
      const Tab(label: "Products", icon: "br-box-open-full"),
      const Tab(label: "Orders", icon: "br-person-dolly"),
      const Tab(label: "Accounts", icon: "br-users"),
    ];
    return Scaffold(
      bottomNavigationBar: Obx(() {
        var index = _ctrl.tab.value;
        return BottomNavigationBar(
            currentIndex: index,
            onTap: _onBottonNavitemTap,
            items: tabs
                .asMap()
                .entries
                .map(
                  (e) => BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          color: index == e.key
                              ? colors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(100)),
                      child: e.value.icon.runtimeType == String
                          ? svgIcon(
                              name: e.value.icon,
                              color: index != e.key
                                  ? colors.note
                                  : colors.onPrimary,
                            )
                          : Icon(
                              e.value.icon,
                              color: index != e.key
                                  ? colors.text2
                                  : colors.primary,
                            ),
                    ),
                    label: e.value.label,
                  ),
                )
                .toList());
      }),
      body: WillPopScope(
        onWillPop: () async {
          if (_ctrl.tab.value != 0) {
            _ctrl.tab.value = 0;
            return false;
          }
          return true;
        },
        child: Obx(() => adminPages.elementAt(_ctrl.tab.value)),
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
