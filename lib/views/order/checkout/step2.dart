import "package:flutter/cupertino.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:lebzcafe/main.dart";

import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/views/order/index.dart";
import "package:lebzcafe/widgets/common3.dart";

class CheckoutStep2 extends StatelessWidget {
  const CheckoutStep2({super.key});

  static String title = "Summary";
  @override
  Widget build(BuildContext context) {
    final storeCtrl = MainApp.storeCtrl;
    return Column(
      children: [
        storeCtrl.cart["products"].isEmpty
            ? none()
            : Column(
                //id=ordersummarysec
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mY(topMargin),
                  TuCard(
                      padding: 14,
                      child: Column(
                        children: [
                          tuTableRow(
                            const Text("Items"),
                            Obx(
                              () {
                                num totalItems = 0;
                                for (var it in storeCtrl.cart["products"]) {
                                  totalItems += 1 * it["quantity"];
                                }
                                return Text("$totalItems");
                              },
                            ),
                            my: 10,
                          ),
                          devider(),
                          tuTableRow(
                            const Text("Subtotal"),
                            Obx(
                              () {
                                return Text(
                                    "R${roundDouble(storeCtrl.total.value, 2)}");
                              },
                            ),
                            my: 10,
                          ),
                          devider(),
                          tuTableRow(
                            const Text("Delivery fee"),
                            Obx(
                              () => Text("${storeCtrl.deliveryFee}"),
                            ),
                            my: 10,
                          ),
                          devider(),
                        ],
                      ))
                ],
              )
      ],
    );
  }
}
