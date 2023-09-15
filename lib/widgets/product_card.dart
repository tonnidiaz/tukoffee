// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/views/order/index.dart';
import 'package:get/get.dart';

import '../controllers/app_ctrl.dart';
import '../controllers/store_ctrl.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'common.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String? cols;
  const ProductCard({super.key, required this.product, this.cols});

  @override
  Widget build(BuildContext context) {
    final StoreCtrl storeCtrl = Get.find();
    final AppCtrl appCtrl = Get.find();
    final cardW = (screenSize(context).width / 2) - 13;
    double rad = 8;
    addRemoveCart() async {
      if (appCtrl.user.isEmpty)
        return showToast("Login to add to cart", isErr: true).show(context);
      bool inCart = storeCtrl.cart.isNotEmpty &&
          storeCtrl.cart["products"]
              .where((el) => el["product"]["_id"] == product["_id"])
              .isNotEmpty;

      clog(!inCart ? "Adding to cart..." : "Removing from cart...");

      var act = inCart ? "remove" : "add";
      try {
        final res = await apiDio().post("/user/cart?action=$act",
            data: {"user": appCtrl.user["email"], "product": product["_id"]});
        storeCtrl.setcart(res.data["cart"]);
        // t.dismiss();
        showToast(!inCart
                ? "Product added to cart!"
                : "Product removed from cart!")
            .show(context);
      } catch (e) {
        clog(e);
        if (e.runtimeType == DioException) {
          handleDioException(
              context: context,
              exception: e as DioException,
              msg: "Error adding/removing item to cart");
        } else
          showToast("Something went wrong!", isErr: true).show(context);
      }
    }

    return TuCard(
      //  color: cardBG2,
      //elevation: 0,
      radius: rad,
      height: 180,
      width: cardW,
      padding: 0,
      onTap: () async {
        storeCtrl.setCurrProduct(product);
        await Navigator.pushNamed(context, "/product",
            arguments: {"pid": product["pid"]});
      },
      mx: 2.5,
      my: 2.5,
      child: Container(
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  //id=cover

                  //  color: appBGLight,
                  alignment: Alignment.center,
                  height: cardW,
                  width: cardW,

                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(rad),
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                  ),
                  child: product['images'].isNotEmpty
                      ? CircleAvatar(
                          //borderRadius: BorderRadius.circular(rad),
                          radius: 60,
                          backgroundColor: Colors.black12,
                          backgroundImage: Image.network(
                            product['images'][0]['url'],
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.black54,
                                ),
                              );
                            },
                          ).image,
                        ) //"https://loremflickr.com/g/320/240/tea?random=${Random().nextInt(100)}")
                      : const Icon(
                          Icons.coffee_outlined,
                          size: 50,
                          color: Colors.black54,
                        ),
                ),
                Positioned(
                  bottom: 10,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(13, 13, 13, 01),
                        borderRadius: BorderRadius.circular(5)),
                    child: Obx(() {
                      bool inCart = storeCtrl.cart.isNotEmpty &&
                          storeCtrl.cart["products"]
                              .where((el) =>
                                  el["product"]["_id"] == product["_id"])
                              .isNotEmpty;
                      return product['quantity'] <= 0
                          ? none()
                          : IconButton(
                              padding: EdgeInsets.zero,
                              icon: inCart
                                  ? const Icon(
                                      CupertinoIcons.bag_fill_badge_minus,
                                      color: Colors.orange,
                                      size: 30,
                                    )
                                  : const Icon(
                                      CupertinoIcons.bag_badge_plus,
                                      color: Colors.white70,
                                      size: 30,
                                    ),
                              onPressed: product['quantity'] <= 0
                                  ? null
                                  : () async {
                                      addRemoveCart();
                                    },
                            );
                    }),
                  ),
                )
              ],
            ),
          ),
          mY(5),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${product['name']}",
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  product['quantity'] > 0 ? "In stock" : "out of stock",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                mY(2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TuCard(
                      width: 50,
                      radius: 100,
                      padding: 4,
                      child: Text(
                        "R${product['price']}",
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    iconText("${product['rating'] ?? 0}", Icons.star,
                        iconSize: 12,
                        fontSize: 12,
                        iconColor: Colors.amber,
                        fw: FontWeight.w600),
                  ],
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
