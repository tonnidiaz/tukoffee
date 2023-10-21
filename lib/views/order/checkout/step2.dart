import 'package:flutter/cupertino.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/main.dart';

import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common3.dart';

class CheckoutStep2 extends StatelessWidget {
  const CheckoutStep2({super.key});

  static String title = "Summary";
  @override
  Widget build(BuildContext context) {
    final storeCtrl = MainApp.storeCtrl;
    return Column(
      children: [
        Column(
          //id=ordersummarysec
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mY(topMargin),
            TuCard(
              padding: 14,
              child: true
                  ? Column(
                      children: [
                        tuTableRow(
                          const Text("Items"),
                          Obx(
                            () => Text(
                                "${storeCtrl.cart['products']?.length ?? 0}"),
                          ),
                          my: 10,
                        ),
                        devider(),
                        tuTableRow(
                          const Text("Subtotal"),
                          Obx(
                            () {
                              double total = 0;
                              if (storeCtrl.cart["products"] != null) {
                                for (var it in storeCtrl.cart["products"]) {
                                  total +=
                                      (it["product"]["price"] * it["quantity"])
                                          .toDouble();
                                }
                              }
                              return Text("R${roundDouble(total, 2)}");
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
                    )
                  : Table(
                      border: TableBorder.all(
                          width: 1,
                          color: const Color.fromRGBO(0, 0, 0, 0.15),
                          borderRadius: BorderRadius.circular(0)),
                      children: [
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Subtotal"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Obx(() {
                              double total = 0;
                              if (storeCtrl.cart["products"] != null) {
                                for (var it in storeCtrl.cart["products"]) {
                                  total +=
                                      (it["product"]["price"] * it["quantity"])
                                          .toDouble();
                                }
                              }

                              return Text("R${roundDouble(total, 2)}");
                            }),
                          )
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Delivery fee"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Obx(() => Text("R${storeCtrl.deliveryFee}")),
                          )
                        ]),
                      ],
                    ),
            )
          ],
        )
      ],
    );
  }
}
