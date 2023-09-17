import 'package:flutter/material.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/admin/accounts.dart';
import 'package:frust/views/admin/orders.dart';
import 'package:frust/views/order/index.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/constants2.dart';
import '../../widgets/common2.dart';
import '/utils/constants.dart';
import '/widgets/common.dart';
import 'products.dart';

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

  void _setupDash() async {
    try {
      _ctrl.setProductsFetched(false);
      var res = await dio.get("$apiURL/admin/dash");
      final data = res.data;
      _ctrl.setProducts(data["products"]);
      _ctrl.orders.value = data["orders"];
      _ctrl.customers.value = data["customers"];
    } catch (e) {
      clog(e);
    }
    _ctrl.setProductsFetched(true);
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
    _setupDash();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(showCart: false),
      bottomNavBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _ctrl.selectedTab.value,
          selectedItemColor: orange,
          unselectedItemColor: Colors.black45,
          showUnselectedLabels: true,
          unselectedFontSize: 10,
          onTap: _onBottonNavitemTap,
          items: const [
            /*  BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ), */

            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.production_quantity_limits),
              label: "Products",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_sharp),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts),
              label: "Accounts",
            ),
          ],
        ),
      ),
      child: WillPopScope(
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

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final DashCtrl ctrl = Get.find();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black87,
          child: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/admin/settings');
          }),
      body: Container(
        padding: defaultPadding2,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              mY(5),
              Text(
                "Dashboard",
                style: Styles.h1,
              ),
              mY(10),
              Obx(
                () => Column(
                  children: [
                    ItemCard(
                      title: "Revenue",
                      avatarTxt: "\$",
                      subtitle: "\$${ctrl.revenue.roundToDouble()}",
                      avatarBG: const Color.fromRGBO(76, 175, 79, 0.3),
                      avatarFG: Colors.green,
                    ),
                    ItemCard(
                      title: "Products",
                      onTap: () {
                        ctrl.selectedTab.value = 1;
                      },
                      avatarTxt: const Icon(
                        Icons.inventory,
                        color: Colors.orange,
                      ),
                      subtitle: "${ctrl.products.length}",
                      avatarBG: const Color.fromRGBO(255, 153, 0, 0.3),
                    ),
                    ItemCard(
                      title: "Orders",
                      onTap: () {
                        ctrl.selectedTab.value = 2;
                      },
                      avatarTxt: const Icon(
                        Icons.shopping_basket,
                        color: Colors.yellow,
                      ),
                      subtitle: "${ctrl.orders.length}",
                      avatarBG: const Color.fromRGBO(255, 235, 59, 0.3),
                    ),
                    ItemCard(
                      title: "Accounts",
                      onTap: () {
                        ctrl.selectedTab.value = 3;
                      },
                      avatarTxt: const Icon(
                        Icons.people,
                        color: Colors.black,
                      ),
                      subtitle: "${ctrl.customers.length}",
                      avatarBG: const Color.fromRGBO(0, 0, 0, 0.3),
                    ),
                  ],
                ),
              )
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
  final dynamic avatarTxt;
  final String title;
  final String subtitle;
  const ItemCard(
      {super.key,
      this.onTap,
      this.avatarBG,
      this.avatarFG,
      this.avatarTxt = "A",
      this.title = "",
      this.subtitle = ""});

  @override
  Widget build(BuildContext context) {
    return TuCard(
        onTap: onTap,
        my: 0,
        borderSize: 0,
        radius: 0,
        child: TuListTile(
          leading: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: avatarBG ?? Colors.blue,
                borderRadius: BorderRadius.circular(100)),
            child: avatarTxt.runtimeType == String
                ? Text(
                    avatarTxt,
                    style: Styles.title(color: avatarFG),
                  )
                : avatarTxt,
          ),
          title: Text(
            title,
            style: Styles.title(),
          ),
          subtitle: Text(
            subtitle,
            style: Styles.subtitle,
          ),
        ));
  }
}
