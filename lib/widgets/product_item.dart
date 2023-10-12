// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/products_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/admin/index.dart';
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
          tileColor: cardBGLight,
          leading: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: product['images'].isEmpty
                  ? const Icon(
                      Icons.coffee_outlined,
                      size: 45,
                      color: Colors.black54,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(product['images'][0]['url'])),
            ),
          ),
          title: Text(
            product['name'],
            style: Styles.h4(),
          ),
          subtitle: Text(
            "R${product["price"]}",
            style: TextStyle(fontSize: 14),
          ),
          trailing: PopupMenuButton(
              splashRadius: 20,
              icon: Icon(
                Icons.more_vert,
                color: TuColors.text,
              ),
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

                                    _ctrl.setProducts(_ctrl.products.value!
                                        .where(
                                            (it) => it["pid"] != product["pid"])
                                        .toList());

                                    _appBarCtrl.setSelected([]);
                                  } catch (e) {
                                    if (e.runtimeType == DioException) {
                                      handleDioException(
                                          context: context,
                                          exception: e as DioException,
                                          msg: "Error deleting product!");
                                    } else {
                                      clog(e);
                                      showToast("Error deleting product!",
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
              }),
        ));
  }
}
