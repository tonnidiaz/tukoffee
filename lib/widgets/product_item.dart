// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:lebzcafe/controllers/products_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/styles.dart";
import "package:get/get.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:tu/tu.dart";

import "../controllers/appbar.dart";
import "../utils/colors.dart";
import "../utils/functions.dart";
import "add_product_form.dart";

class ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool dev;
  ProductItem({super.key, required this.product, this.dev = true});
  final AppBarCtrl _appBarCtrl = Get.find();
  final ProductsCtrl _ctrl = Get.find();
  final _formViewCtrl = MainApp.formCtrl;
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
              pushNamed("/product", arguments: {"pid": product["pid"]});
            } else {
              _selectItem(product);
            }
          },
          onLongPress: () {
            _selectItem(product);
          },
          //tileColor: colors.surface,
          leading: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 60,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: product["images"].isEmpty
                  ? svgIcon(
                      name: "br-image-slash",
                      size: 25,
                      color: Colors.black54,
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          product["images"][0]["url"],
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                                child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ));
                          },
                        ),
                      ),
                    ),
            ),
          ),
          title: Text(
            product["name"],
            style: styles.h4(),
          ),
          subtitle: Text(
            "R${product["price"]}",
            style: const TextStyle(fontSize: 14),
          ),
          trailing: PopupMenuButton(
              splashRadius: 20,
              icon: Icon(
                Icons.more_vert,
                color: colors.text2,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      _formViewCtrl.setForm({...product});
                      pushTo(const AddProductForm(
                        title: "Edit product",
                        mode: "edit",
                        btnTxt: "Save changes",
                      ));
                    },
                    child: const Text(
                      "Edit",
                    ),
                  ),
                ];
              }),
        ));
  }
}
