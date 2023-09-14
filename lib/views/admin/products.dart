// ignore_for_file: use_build_context_synchronously

import 'package:cloudinary/cloudinary.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/appbar.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/admin/dashboard.dart';
import 'package:frust/widgets/common.dart';
import 'package:get/get.dart';

import '../../widgets/add_product_form.dart';
import '../../widgets/common2.dart';
import '../../widgets/product_item.dart';
import '../../widgets/prompt_modal.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final DashCtrl _dashCtrl = Get.find();
  final AppBarCtrl _appBarCtrl = Get.find();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarCtrl.setSelectedActions([
        PopupMenuItem(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return PromptModal(
                      title: "Delete products",
                      msg:
                          "Are you sure you want to delete the selected producta?",
                      onOk: () async {
                        try {
                          var pids = _appBarCtrl.selected
                              .map((element) => element['pid'])
                              .toList();
                          await apiDio().post("/products/delete?pids=$pids");
                          //Delete images for each product
                          for (var product in _appBarCtrl.selected) {
                            var imgs = product['images'];
                            //Delete the product images
                            for (var img in imgs) {
                              try {
                                var cloudinaryRes =
                                    await signedCloudinary.destroy(
                                  img['publicId'],
                                );
                                clog(cloudinaryRes.result);
                              } catch (err) {
                                clog(err);
                              }
                            }
                          }

                          _dashCtrl.setProducts(_dashCtrl.products
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
                            clog(e);
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
            iconColor: Colors.red,
            labelColor: Colors.red,
            alignment: MainAxisAlignment.start,
            fontSize: 15,
          ),
        ),
      ]);
    });
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: const Icon(
            Icons.add_outlined,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () async {
            //  pushTo(context, AddNewProductModal());
            pushTo(context, const AddProductForm());
          }),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Products ",
                    style: Styles.h1,
                  ),
                  Obx(
                    () {
                      return TuLabeledCheckbox(
                          radius: 40,
                          activeColor: orange,
                          value: _appBarCtrl.selected.isNotEmpty &&
                              _appBarCtrl.selected.length ==
                                  _dashCtrl.products.length,
                          onChanged: (val) {
                            if (val == true) {
                              _appBarCtrl.setSelected(_dashCtrl.products);
                            } else {
                              _appBarCtrl.setSelected([]);
                            }
                          });
                    },
                  ),
                ],
              ),
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
                          _dashCtrl.sortOrder.value == SortOrder.descending
                              ? _dashCtrl.setSortOrder(SortOrder.ascending)
                              : _dashCtrl.setSortOrder(SortOrder.descending);
                        },
                        icon: Icon(
                            _dashCtrl.sortOrder.value == SortOrder.descending
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
                          value: _dashCtrl.sortBy.value,
                          radius: 2,
                          items: [
                            SelectItem("name", SortBy.name),
                            SelectItem("price", SortBy.price),
                            SelectItem("date", SortBy.dateCreated),
                          ],
                          onChanged: (p0) {
                            _dashCtrl.setSortBy(p0);
                          },
                        )),
                    Obx(() => TuDropdownButton(
                          label: "Status",
                          labelFontSize: 14,
                          width: (c.maxWidth / 2) - 2.5,
                          radius: 2,
                          value: _dashCtrl.status.value,
                          items: [
                            SelectItem("All", ProductStatus.all),
                            SelectItem("in stock", ProductStatus.instock),
                            SelectItem("out of stock", ProductStatus.out),
                          ],
                          onChanged: (p0) {
                            _dashCtrl.setStatus(p0);
                          },
                        )),
                  ],
                );
              }),
              mY(5),
              Obx(() => !_dashCtrl.productsFetched.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          mY(30),
                          h3("Please wait..."),
                        ],
                      ),
                    )
                  : _dashCtrl.sortedProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              mY(30),
                              h3("Nothing to show"),
                              IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    /* final res = await _getProducts();
                                    _dashCtrl.set_products(res); */
                                  })
                            ],
                          ),
                        )
                      : Column(
                          children: _dashCtrl.sortedProducts.map((e) {
                            return ProductItem(product: e);
                          }).toList(),
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
