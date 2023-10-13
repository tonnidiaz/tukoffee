import 'package:flutter/cupertino.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/search.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';
import '../../../utils/constants2.dart';
import '../../../widgets/common.dart';
import '../../../widgets/product_card.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with TickerProviderStateMixin {
  final StoreCtrl _storeCtrl = Get.find();
  final _appCtrl = MainApp.appCtrl;
  Future<void> getProducts() async {
    //if (_storeCtrl.products.isNotEmpty) return;
    _storeCtrl.setProductsFetched(false);
    try {
      clog("Fetching products...");
      final res = await apiDio().get("/products");
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
        setupCart(_appCtrl.user['_id']);
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
    filterModal() {
      return Padding(
        padding: defaultPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                              ? CupertinoIcons.sort_down
                              : CupertinoIcons.sort_up),
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
                          SelectItem("Top selling", ProductStatus.topSelling),
                          SelectItem("On special", ProductStatus.special),
                          SelectItem("On sale", ProductStatus.sale),
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
          ],
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          actions: const [CartBtn()],
          title: const Text('Shop'),
          titleSpacing: 14,
        ),
        body: false
            ? Column(
                children: [
                  Expanded(
                    child: Container(
                      /*   width: 200,
                      height: 200, */
                      padding: defaultPadding,
                      color: Colors.red,
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                          ),
                          itemCount: 30,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, i) => Container(
                                color: TuColors.primary,
                                child: Text('ITEM $i'),
                              )),
                    ),
                  )
                ],
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await getProducts();
                },
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: topMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: cardBGLight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TuFormField(
                            hint: "Search",
                            prefixIcon: TuIcon(Icons.search),
                            radius: 5,
                            suffixIcon: IconButton(
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  // show filters
                                  TuFuncs.showBottomSheet(
                                      full: false,
                                      context: context,
                                      widget: filterModal());
                                },
                                icon: TuIcon(Icons.tune)),
                            onTap: () {
                              TuFuncs.showBottomSheet(
                                  context: context, widget: const SearchPage());
                            },
                          ),
                        ),
                        mY(topMargin),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    height:
                                        screenSize(context).height - appBarH - statusBarH(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    //height: screenSize(context).height,
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: GridView.builder(
                                                itemCount: _storeCtrl
                                                    .sortedProducts.length,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      (screenSize(context)
                                                                  .width /
                                                              144)
                                                          .floor(),
                                                  crossAxisSpacing: 5.0,
                                                  mainAxisSpacing: 5.0,
                                                ),
                                                shrinkWrap: true,
                                                itemBuilder: (context, i) {
                                                  return ProductCard(
                                                    product: _storeCtrl
                                                        .sortedProducts[i],
                                                  );
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                    /* child: Builder(builder: (context) {
                            return Obx(() => Wrap(
                                    children: ([
                                  ..._storeCtrl.sortedProducts,
                                ]).map((it) {
                                  return ProductCard(
                                    product: it,
                                  );
                                }).toList()));
                          }), */
                                  ))
                      ],
                    ),
                  ),
                ),
              ));
  }
}
