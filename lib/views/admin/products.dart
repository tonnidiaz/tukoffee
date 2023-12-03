// ignore_for_file: use_build_context_synchronously
import "package:lebzcafe/controllers/products_ctrl.dart";

import "package:cloudinary/cloudinary.dart";
import "package:dio/dio.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/controllers/appbar.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/views/admin/index.dart";
import "package:lebzcafe/views/search.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:tu/tu.dart";
import "package:via_logger/logger.dart";
import "../../widgets/add_product_form.dart";
import "../../widgets/product_item.dart";
import "../../widgets/prompt_modal.dart";

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final DashCtrl _dashCtrl = Get.find();
  final ProductsCtrl _ctrl = Get.find();
  final AppBarCtrl _appBarCtrl = Get.find();
  @override
  void initState() {
    super.initState();
    _getProducts();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarCtrl.setSelectedActions([
        PopupMenuItem(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return PromptDialog(
                      title: "Delete products",
                      msg:
                          "Are you sure you want to delete the selected producta?",
                      onOk: () async {
                        try {
                          var pids = _appBarCtrl.selected
                              .map((element) => element["pid"])
                              .toList();
                          await apiDio().post("/products/delete?pids=$pids");
                          //Delete images for each product
                          for (var product in _appBarCtrl.selected) {
                            var imgs = product["images"];
                            //Delete the product images
                            for (var img in imgs) {
                              try {
                                var cloudinaryRes =
                                    await signedCloudinary.destroy(
                                  img["publicId"],
                                );
                                Logger.info(cloudinaryRes.result);
                              } catch (err) {
                                Logger.info(err);
                              }
                            }
                          }

                          _ctrl.setProducts(_ctrl.products.value!
                              .where((it) => !pids.contains(it["pid"]))
                              .toList());
                          _appBarCtrl.setSelected([]);
                        } catch (e) {
                          if (e.runtimeType == DioException) {
                            handleDioException(
                                context: context,
                                exception: e as DioException,
                                msg: "Error deleting products!");
                          } else {
                            Logger.info(e);
                            showToast("Error deleting products!", isErr: true)
                                .show(context);
                          }
                        }
                      });
                });
          },
          child: iconText(
            "Delete",
            Icons.delete,
            alignment: MainAxisAlignment.start,
            fontSize: 15,
          ),
        ),
      ]);
    });
  }

  _getProducts() async {
    try {
      _ctrl.setProducts(null);
      Logger.info("Getting...");

      final res = await apiDio().get("/products");
      _ctrl.setProducts(res.data["data"]);
    } catch (e) {
      Logger.info(e);
      _ctrl.setProducts([]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarCtrl.setSelected([]);
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    filterModal() {
      return TuBottomSheet(
        child: Container(
          padding: defaultPadding2,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _ctrl.sortOrder.value == SortOrder.descending
                            ? _ctrl.setSortOrder(SortOrder.ascending)
                            : _ctrl.setSortOrder(SortOrder.descending);
                      },
                      icon: Icon(_ctrl.sortOrder.value == SortOrder.descending
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
                        value: _ctrl.sortBy.value,
                        radius: 2,
                        items: [
                          SelectItem("name", SortBy.name),
                          SelectItem("price", SortBy.price),
                          SelectItem("date", SortBy.createdAt),
                        ],
                        onChanged: (p0) {
                          _ctrl.setSortBy(p0);
                        },
                      )),
                  Obx(() => TuSelect(
                        label: "Status",
                        labelFontSize: 14,
                        width: (c.maxWidth / 2) - 2.5,
                        radius: 2,
                        value: _ctrl.status.value,
                        items: [
                          SelectItem("All", ProductStatus.all),
                          SelectItem("Top selling", ProductStatus.topSelling),
                          SelectItem("On special", ProductStatus.special),
                          SelectItem("On sale", ProductStatus.sale),
                          SelectItem("in stock", ProductStatus.instock),
                          SelectItem("out of stock", ProductStatus.out),
                        ],
                        onChanged: (p0) {
                          _ctrl.setStatus(p0);
                        },
                      )),
                ],
              );
            }),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black87,
          child: const Icon(
            Icons.add_outlined,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () async {
            //  pushTo( AddNewProductModal());
            pushTo(const AddProductForm());
          }),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getProducts();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: defaultPadding2,
              sliver: TuSliver(
                child: TuFormField(
                  hasBorder: false,
                  fill: colors.surface,
                  hint: "Search",
                  height: borderlessInpHeight,
                  prefixIcon: TuIcon(Icons.search),
                  radius: 100,
                  readOnly: true,
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
            TuSliver(child: mY(topMargin)),
            SliverFillRemaining(
                hasScrollBody: true,
                child: Obx(() => _ctrl.products.value == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [mY(30), const CircularProgressIndicator()],
                        ),
                      )
                    : _ctrl.sortedProducts.value!.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              h3("Nothing to show"),
                              IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    await _getProducts();
                                  })
                            ],
                          )
                        : ListView.builder(
                            itemCount: _ctrl.sortedProducts.value!.length,
                            itemBuilder: (context, index) => ProductItem(
                                product: _ctrl.sortedProducts.value![index]),
                          ))),
          ],
        ),
      ),
    );
  }
}
