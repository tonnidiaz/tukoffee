import "package:flutter/cupertino.dart";
import "package:lebzcafe/controllers/store_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/views/search.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:tu/tu.dart";

import "../../../utils/constants2.dart";
import "../../../widgets/product_card.dart";

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
        setupCart(_appCtrl.user["_id"]);
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
      return TuBottomSheet(
        child: Padding(
          padding: defaultPadding2,
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
                    Obx(() => TuSelect(
                          label: "Sort by",
                          labelFontSize: 14,
                          width: (c.maxWidth / 2) - 2.5,
                          height: 40,
                          value: _storeCtrl.sortBy.value,
                          radius: 2,
                          items: [
                            SelectItem("name", SortBy.name),
                            SelectItem("price", SortBy.price),
                            SelectItem("date", SortBy.createdAt),
                          ],
                          onChanged: (p0) {
                            _storeCtrl.setSortBy(p0);
                          },
                        )),
                    Obx(() => TuSelect(
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
        ),
      );
    }

    return Scaffold(
        appBar: tuAppbar(
            actions: const [CartBtn()],
            title: const Text("Shop"),
            centerTitle: true),
        body: RefreshIndicator(
            onRefresh: () async {
              await getProducts();
            },
            child: Obx(() => SizedBox(
                  height: screenSize(context).height,
                  width: double.infinity,
                  child: TuScrollview(
                    child: SizedBox(
                      height: fullHeight(context) - kBottomNavigationBarHeight,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: topMargin),
                            child: TuCard(
                              color: colors.bg,
                              child: TuFormField(
                                hint: "Search",
                                fill: colors.surface,
                                hasBorder: false,
                                prefixIcon: TuIcon(Icons.search),
                                radius: 5,
                                suffixIcon: IconButton(
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      // show filters
                                      Get.bottomSheet(filterModal());
                                    },
                                    icon: TuIcon(Icons.tune)),
                                onTap: () {
                                  pushTo(const SearchPage());
                                },
                              ),
                            ),
                          ),
                          !_storeCtrl.productsFetched.value
                              ? const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _storeCtrl.products.isEmpty
                                  ? Expanded(
                                      child: Center(
                                        child: Text(
                                          "Nothing to show",
                                          style: styles.h3(),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 8, 8),
                                        child: GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 5.0,
                                              mainAxisSpacing: 5.0,
                                            ),
                                            itemCount: _storeCtrl
                                                .sortedProducts.length,
                                            itemBuilder: (context, i) =>
                                                ProductCard(
                                                  product: _storeCtrl
                                                      .sortedProducts[i],
                                                )),
                                      ),
                                    ),
                          mY(5)
                        ],
                      ),
                    ),
                  ),
                ))));
  }
}
