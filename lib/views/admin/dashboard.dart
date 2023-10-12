import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/admin/accounts.dart';
import 'package:frust/views/admin/orders.dart';
import 'package:frust/views/admin/reviews.dart';
import 'package:frust/views/order/index.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/constants2.dart';
import '../../widgets/common2.dart';
import '/utils/constants.dart';
import '/widgets/common.dart';
import 'products.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  RxList<dynamic> products = [].obs;
  void setProducts(List<dynamic> val) {
    products.value = val;
    setSortedProducts(val);
    _sortProducts();
  }

  RxList<dynamic> sortedProducts = [].obs;
  void setSortedProducts(List<dynamic> val) {
    sortedProducts.value = val;
  }

  Rx<SortBy> sortBy = SortBy.name.obs;
  void setSortBy(SortBy val) {
    sortBy.value = val;
    _sortProducts();
  }

  Rx<SortOrder> sortOrder = SortOrder.ascending.obs;
  void setSortOrder(SortOrder val) {
    sortOrder.value = val;
    _sortProducts();
  }

  Rx<ProductStatus> status = ProductStatus.all.obs;
  void setStatus(ProductStatus val) {
    status.value = val;
    // Filter the  products and sort them
    var prods = products;
    switch (val) {
      case ProductStatus.all:
        setSortedProducts(prods);
        break;
      case ProductStatus.instock:
        setSortedProducts(prods.where((it) => it['quantity'] > 0).toList());
        break;
      case ProductStatus.topSelling:
        setSortedProducts(
            prods.where((it) => it['top_selling'] == true).toList());
        break;
      case ProductStatus.special:
        setSortedProducts(
            prods.where((it) => it['on_special'] == true).toList());
        break;
      case ProductStatus.sale:
        setSortedProducts(prods.where((it) => it['on_sale'] == true).toList());
        break;
      case ProductStatus.out:
        setSortedProducts(prods.where((it) => it['quantity'] == 0).toList());
        break;
      default:
        break;
    }
    _sortProducts();
  }

  void _sortProducts() {
    int dateInMs(dynamic prod) {
      var date = DateTime.parse(prod["date_created"]);
      return date.millisecondsSinceEpoch;
    }

    int sorter(a, b) {
      int s = 1;
      final sortBy = this.sortBy.value;
      final sortOrder = this.sortOrder.value;
      switch (sortBy) {
        case SortBy.name:
          s = sortOrder == SortOrder.ascending
              ? a["name"].compareTo(b["name"])
              : b["name"].compareTo(a["name"]);
          break;
        case SortBy.price:
          s = sortOrder == SortOrder.ascending
              ? a["price"].compareTo(b["price"])
              : b["price"].compareTo(a["price"]);
          break;
        case SortBy.dateCreated:
          s = sortOrder == SortOrder.ascending
              ? dateInMs(a).compareTo(dateInMs(b))
              : dateInMs(b).compareTo(dateInMs(a));
          break;
        default:
          break;
      }
      return s;
    }

    sortedProducts.sort(sorter);
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
    return Scaffold(
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _ctrl.selectedTab.value,
          onTap: _onBottonNavitemTap,
          items: const [
            /*  BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ), */

            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.gaugeSimpleHigh),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.boxOpen),
              label: "Products",
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.truckRampBox),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.users),
              label: "Accounts",
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          clog("On will pop");
          if (_ctrl.selectedTab.value != 0) {
            _ctrl.selectedTab.value = 0;
            return false;
          }
          return true;
        },
        child: SizedBox(
            height: screenSize(context).height -
                (appBarH + statusBarH(context) + appBarH),
            child: Obx(() => adminPages.elementAt(_ctrl.selectedTab.value))),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashCtrl _ctrl = Get.find();
  void _setupDash() async {
    try {
      _ctrl.setData(null);
      var res = await dio.get("$apiURL/admin/dash");
      final data = res.data;
      _ctrl.setData(data);
    } catch (e) {
      clog(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _setupDash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Container(
        padding: EdgeInsets.all(6),
        width: double.infinity,
        child: Obx(
          () => _ctrl.data.value == null
              ? none()
              : StaggeredGrid.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: [
                    ItemCard(
                      title: "Products",
                      onTap: () {
                        _ctrl.selectedTab.value = 1;
                      },
                      icon: Icon(
                        FontAwesomeIcons.boxOpen,
                        color: TuColors.coffee2,
                      ),
                      subtitle: "${_ctrl.data.value!['products'].length}",
                    ),
                    ItemCard(
                      title: "Orders",
                      onTap: () {
                        _ctrl.selectedTab.value = 2;
                      },
                      icon: const Icon(
                        FontAwesomeIcons.truckRampBox,
                        color: Colors.orangeAccent,
                      ),
                      subtitle: "${_ctrl.data.value!['orders'].length}",
                    ),
                    ItemCard(
                      title: "Accounts",
                      onTap: () {
                        _ctrl.selectedTab.value = 3;
                      },
                      icon: const Icon(
                        FontAwesomeIcons.users,
                        color: Colors.black54,
                      ),
                      subtitle: "${_ctrl.data.value!['customers'].length}",
                    ),
                    ItemCard(
                      title: "Product reviews",
                      onTap: () {
                        pushTo(context, const ProductsReviews());
                      },
                      icon: const Icon(
                        FontAwesomeIcons.squarePollVertical,
                        color: Colors.green,
                      ),
                      subtitle: "${_ctrl.data.value!['reviews'].length}",
                    ),
                    ItemCard(
                      title: "Settings",
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/settings');
                      },
                      icon: Icon(
                        FontAwesomeIcons.gear,
                        color: TuColors.text2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

final List<Widget> adminPages = [
  const Dashboard(),
  const Products(),
  const OrdersPage(),
  const Accounts(),
];

class ItemCard extends StatelessWidget {
  final Function()? onTap;
  final Color? avatarBG;
  final Color? avatarFG;
  final dynamic icon;
  final String title;
  final String? subtitle;
  const ItemCard(
      {super.key,
      this.onTap,
      this.avatarBG,
      this.avatarFG,
      this.icon = "A",
      this.title = "",
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    final bRad = BorderRadius.circular(5);
    return Material(
      color: cardBGLight,
      borderRadius: bRad,
      child: InkWell(
          onTap: onTap,
          borderRadius: bRad,
          /*   my: 0,
          borderSize: 0, */
          //radius: 0,
          hoverColor: const Color.fromRGBO(236, 236, 236, 0.5),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: appBGLight,
                      child: icon,
                    ),
                    mY(6),
                    subtitle == null
                        ? none()
                        : Text(
                            subtitle!,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: TuColors.text2),
                          ),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: TuColors.text),
                    ),
                  ]))),
    );
  }
}
