// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/views/order/index.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

import '../controllers/app_ctrl.dart';
import '../controllers/store_ctrl.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'common.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String? cols;
  final double? width;
  const ProductCard({super.key, required this.product, this.cols, this.width});

  @override
  Widget build(BuildContext context) {
    final StoreCtrl storeCtrl = Get.find();
    final AppCtrl appCtrl = Get.find();
    final cardW = width ?? (screenSize(context).width / 2) - 15;
    double rad = 0;
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

                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(rad),
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                  ),
                  child: product['images'].isNotEmpty
                      ? ClipRRect(
                          //borderRadius: BorderRadius.circular(rad),
                          child: Image.network(
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
                          ),
                        ) //"https://loremflickr.com/g/320/240/tea?random=${Random().nextInt(100)}")
                      : const Icon(
                          Icons.coffee_outlined,
                          size: 50,
                          color: Colors.black54,
                        ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Obx(() {
                    bool inCart = storeCtrl.cart.isNotEmpty &&
                        storeCtrl.cart["products"]
                            .where(
                                (el) => el["product"]["_id"] == product["_id"])
                            .isNotEmpty;
                    return Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(105),
                      color: inCart ? TuColors.primary : appBGLight,
                      child: Container(
                        child: product['quantity'] <= 0
                            ? none()
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: inCart
                                    ? const Icon(
                                        Icons.remove_shopping_cart_outlined,
                                        color: Color.fromRGBO(20, 20, 20, 0.7),
                                        size: 25,
                                      )
                                    : const Icon(
                                        LineIcons.addToShoppingCart,
                                        color: Colors.black87,
                                        size: 30,
                                      ),
                                onPressed: product['quantity'] <= 0
                                    ? null
                                    : () async {
                                        addRemoveCart();
                                      },
                              ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          mY(5),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${product['name']}",
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                mY(2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      backgroundColor: TuColors.primary,
                      label: Text(
                        product['quantity'] > 0 ? "In stock" : "out of stock",
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    iconText("${product['rating'] ?? 0}", Icons.star,
                        iconSize: 14,
                        fontSize: 14,
                        iconColor: Colors.amber,
                        fw: FontWeight.w600),
                  ],
                ),
                mY(2.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("R${product['price']}",
                        style: GoogleFonts.poppins(
                            color: product['on_sale']
                                ? TuColors.text2
                                : Colors.black87,
                            fontSize: product['on_sale'] ? 12 : 14,
                            decoration: product['on_sale']
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w600)),
                    Visibility(
                      visible: product['on_sale'],
                      child: Text("R${product['sale_price']}",
                          style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    )
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
