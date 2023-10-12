// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/products_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/views/admin/dashboard.dart';
import 'package:frust/views/admin/products.dart';
import 'package:get/get.dart';

import '../controllers/appbar.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/constants2.dart';
import '../utils/functions.dart';
import 'add_product_form.dart';
import 'common.dart';
import 'common2.dart';
import 'prompt_modal.dart';

class ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool dev;
  ProductItem({super.key, required this.product, this.dev = true});
  final AppBarCtrl _appBarCtrl = Get.find();
  final ProductsCtrl _ctrl = Get.find();
  final _formViewCtrl = MainApp.formViewCtrl;
  void _selectItem(Map<String, dynamic> product) {
    !_appBarCtrl.selected.contains(product)
        ? _appBarCtrl.setSelected([..._appBarCtrl.selected, product])
        : _appBarCtrl.setSelected(
            _appBarCtrl.selected.where((el) => el != product).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color.fromRGBO(10, 10, 10, .05)))),
        child: ListTile(
            onTap: () async {
              if (_appBarCtrl.selected.isEmpty) {
                Navigator.pushNamed(context, "/product",
                    arguments: {"pid": product["pid"]});
              } else {
                _selectItem(product);
              }
            },
            onLongPress: () {
              _selectItem(product);
            },
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _appBarCtrl.selected.isNotEmpty
                                ? TuLabeledCheckbox(
                                    activeColor: orange,
                                    value:
                                        _appBarCtrl.selected.contains(product),
                                    onChanged: (val) {
                                      _selectItem(product);
                                    })
                                : none(),
                            mX(5),
                            Center(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black12,
                                backgroundImage: product['images'].isEmpty
                                    ? null
                                    : Image.network(product['images'][0]['url'])
                                        .image,
                                child: product['images'].isNotEmpty
                                    ? null
                                    : const Icon(
                                        Icons.coffee_outlined,
                                        size: 45,
                                        color: Colors.black54,
                                      ),
                              ),
                            ),
                            mX(10),
                            Visibility(
                                visible: true,
                                child: Expanded(
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${product["name"]}",
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "\$${product["price"]}",
                                          style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        ),
                                        Visibility(
                                          visible: false,
                                          child: Text(
                                            "${DateTime.parse(product["date_created"]).toLocal()}"
                                                .split(" ")
                                                .first,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 11),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${product["quantity"]} ",
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                            ),
                                            const Text(
                                              "in stock",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      )),
                  Container(
                      width: 23,
                      alignment: Alignment.center,
                      child: dev
                          ? PopupMenuButton(
                              padding: EdgeInsets.zero,
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    onTap: () {
                                      _formViewCtrl.setForm({
                                        "name": product['name'],
                                        "description": product['description'],
                                        "price": product['price'],
                                        "quantity": product['quantity'],
                                        "images": product["images"],
                                        "pid": product["pid"]
                                      });

                                      pushTo(
                                          context,
                                          const AddProductForm(
                                            title: "Edit product",
                                            mode: "edit",
                                            btnTxt: "Edit product",
                                          ));
                                    },
                                    child: iconText(
                                      "Edit",
                                      Icons.edit,
                                      alignment: MainAxisAlignment.start,
                                      fontSize: 15,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return PromptDialog(
                                                title: "Delete product",
                                                msg:
                                                    "Are you sure you want to delete this product?",
                                                onOk: () async {
                                                  try {
                                                    var res = await apiDio().post(
                                                        "/products/delete?pid=${product["pid"]}");
                                                    clog(res.data);
                                                    var imgs =
                                                        product['images'];
                                                    //Delete the product images
                                                    for (var img in imgs) {
                                                      try {
                                                        var cloudinaryRes =
                                                            await signedCloudinary
                                                                .destroy(
                                                          img['publicId'],
                                                        );
                                                        clog(cloudinaryRes
                                                            .result);
                                                      } catch (err) {
                                                        clog(err);
                                                      }
                                                    }

                                                    _ctrl.setProducts(_ctrl
                                                        .products.value!
                                                        .where((it) =>
                                                            it["pid"] !=
                                                            product["pid"])
                                                        .toList());

                                                    _appBarCtrl.setSelected([]);
                                                  } catch (e) {
                                                    if (e.runtimeType ==
                                                        DioException) {
                                                      handleDioException(
                                                          context: context,
                                                          exception:
                                                              e as DioException,
                                                          msg:
                                                              "Error deleting product!");
                                                    } else {
                                                      clog(e);
                                                      showToast(
                                                              "Error deleting product!",
                                                              isErr: true)
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
                                ];
                              })
                          : IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                              icon: const Icon(
                                Icons.add_shopping_cart_outlined,
                                color: Colors.white70,
                              )))
                ],
              ),
            )));
  }
}
