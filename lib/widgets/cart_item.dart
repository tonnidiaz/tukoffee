// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/order/index.dart';
import 'package:get/get.dart';

import '../controllers/products_ctrl.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'common.dart';

class CartItem extends StatelessWidget {
  final Map<String, dynamic> product;
  CartItem({
    super.key,
    required this.product,
  });
  final ProductsCtrl _productsCtrl = Get.find();

  void _selectItem(Map<String, dynamic> product) {
    !_productsCtrl.selectedProducts.contains(product)
        ? _productsCtrl
            .set_selectedProducts([..._productsCtrl.selectedProducts, product])
        : _productsCtrl.set_selectedProducts(_productsCtrl.selectedProducts
            .where((el) => el != product)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final prod = product["product"];
    final storeCtrl = Get.find<StoreCtrl>();
    updateCart(String act, dynamic val) async {
      try {
        final res = await apiDio().post("/user/cart?action=$act",
            data: {"product": prod["_id"], "quantity": val});
        storeCtrl.setcart(res.data["cart"]);
        // t.dismiss();
        clog("Item quantity updated");
      } catch (e) {
        clog(e);
        if (e.runtimeType == DioException) {
          handleDioException(context: context, exception: e as DioException);
          return;
        }
        showToast("Something went wrong!", isErr: true).show(context);
      }
    }

    return SizedBox(
        width: double.infinity,
        //height: 110,
        child: TuCard(
            radius: 8,
            my: 2.5,
            onTap: () {
              // Navigate  to product
              Navigator.pushNamed(context, "/product",
                  arguments: {"pid": prod["pid"]});
            },
            child: Column(
              children: [
                Row(
                  //Checkbox, cover, content, deleteBtn
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Row(
                          // cover and checkbox
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _productsCtrl.selectedProducts.isNotEmpty
                                ? SizedBox(
                                    width: 30,
                                    child: Checkbox(
                                        activeColor: orange,
                                        value: _productsCtrl.selectedProducts
                                            .contains(product),
                                        onChanged: (val) {
                                          _selectItem(product);
                                        }),
                                  )
                                : none(),
                            Container(
                              // id=image-wrap
                              width: 80,
                              height: 80,
                              //margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                              decoration: BoxDecoration(
                                  color: imgBG,
                                  borderRadius: BorderRadius.circular(1)),
                              child: Center(
                                child: product['product']['images'].isNotEmpty
                                    ? Image.network(product['product']['images']
                                            [0][
                                        'url']) //"https://loremflickr.com/g/320/240/tea?random=${Random().nextInt(100)}")
                                    : const Icon(
                                        Icons.coffee_outlined,
                                        size: 45,
                                        color: Colors.black54,
                                      ),
                              ),
                            ),
                          ],
                        )),
                    mX(5),
                    Expanded(
                      //Content
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${prod["name"]}",
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "R${prod["price"]}",
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TuDropdownButton(
                                  height: 30,
                                  label: "Quantity",
                                  radius: 1,
                                  borderColor: Colors.black12,
                                  labelFontSize: 14,
                                  value: product["quantity"],
                                  onChanged: (val) async {
                                    try {
                                      const act = "add";
                                      updateCart(act, val);
                                    } catch (e) {
                                      clog(e);
                                      showToast("Something went wrong!",
                                              isErr: true)
                                          .show(context);
                                    }
                                  },
                                  items: List.generate(
                                      prod["quantity"],
                                      (index) => SelectItem(
                                          "Qty: ${index + 1}", index + 1)),
                                ),
                              ),
                              Container(
                                  //id=deletebtn
                                  width: 23,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                      splashRadius: 23,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        const act = "remove";
                                        updateCart(act, null);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.black87,
                                      )))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
