import 'package:flutter/material.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/functions.dart';
import 'package:get/get.dart';
import '../../utils/constants2.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';
import '/utils/constants.dart';

class HomeTab extends StatefulWidget {
  final String q;
  const HomeTab({super.key, this.q = "trending"});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final StoreCtrl _storeCtrl = Get.find();
  final _appCtrl = MainApp.appCtrl;
  Future<void> getProducts() async {
    //if (_storeCtrl.products.isNotEmpty) return;
    _storeCtrl.setProductsFetched(false);
    try {
      clog("Fetching products...");
      final res = await dio.get("$apiURL/products?q=${widget.q}");
      _storeCtrl.setProducts(res.data["data"]);
      _storeCtrl.setProductsFetched(true);
    } catch (e) {
      clog(e);
      _storeCtrl.setProductsFetched(true);
    }
  }

  _init() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appCtrl.setActions([
        PopupMenuItem(
            onTap: () {
              _init();
            },
            child: const Text("Refresh"))
      ]);
      // Reset the sorting and filtering
      _storeCtrl.setSortBy(SortBy.name);
      _storeCtrl.setStatus(ProductStatus.all);
      _storeCtrl.setSortOrder(SortOrder.ascending);
      if (_appCtrl.user.isNotEmpty) {
        setupCart(_appCtrl.user['phone']);
      }

      getProducts();
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getProducts();
      },
      child: SingleChildScrollView(
        child: Container(
          padding: defaultPadding,

          ///height: screenSize(context).height - 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("FILTER",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                  Obx(() => IconButton(
                        splashRadius: 15,
                        onPressed: () {
                          _storeCtrl.sortOrder.value == SortOrder.descending
                              ? _storeCtrl.setSortOrder(SortOrder.ascending)
                              : _storeCtrl.setSortOrder(SortOrder.descending);
                        },
                        icon: Icon(
                            _storeCtrl.sortOrder.value == SortOrder.descending
                                ? Icons.arrow_drop_down
                                : Icons.arrow_drop_up),
                        color: Colors.black87,
                      )),
                ],
              ),
              LayoutBuilder(builder: (context, c) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => TuDropdownButton(
                          label: "Sort by",
                          labelFontSize: 14,
                          width: (c.maxWidth / 2) - 2.5,
                          height: 40,
                          value: _storeCtrl.sortBy.value,
                          radius: 2,
                          items: [
                            SelectItem("name", SortBy.name),
                            SelectItem("price", SortBy.price),
                            SelectItem("date", SortBy.dateCreated),
                          ],
                          onChanged: (p0) {
                            _storeCtrl.setSortBy(p0);
                          },
                        )),
                    Obx(() => TuDropdownButton(
                          label: "Status",
                          labelFontSize: 14,
                          width: (c.maxWidth / 2) - 2.5,
                          radius: 2,
                          height: 40,
                          value: _storeCtrl.status.value,
                          items: [
                            SelectItem("All", ProductStatus.all),
                            SelectItem("in stock", ProductStatus.instock),
                            SelectItem("out of stock", ProductStatus.out),
                          ],
                          onChanged: (p0) {
                            _storeCtrl.setStatus(p0);
                          },
                        )),
                  ],
                );
              }),
              mY(10),
              Obx(() => !_storeCtrl.productsFetched.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          h3("Please wait..."),
                        ],
                      ),
                    )
                  : _storeCtrl.products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              mY(30),
                              h3("Nothing to show"),
                              IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    await getProducts();

                                    //setupUser();
                                  })
                            ],
                          ),
                        )
                      : Container(
                          color: Colors.transparent,
                          //height: screenSize(context).height,
                          child: Builder(builder: (context) {
                            return Obx(() => Wrap(
                                    children: ([
                                  ..._storeCtrl.sortedProducts,
                                ]).map((it) {
                                  return ProductCard(
                                    product: it,
                                  );
                                }).toList()));
                          }),
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
