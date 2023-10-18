import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/order/checkout.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/tu/select.dart';

class CheckoutStep1 extends StatelessWidget {
  final CheckoutCtrl ctrl;
  const CheckoutStep1({super.key, required this.ctrl});

  static String title = "Method";
  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    final storeCtrl = MainApp.storeCtrl;
    return Column(
      children: [
        TuCard(
            child: Obx(
          () => TuSelect(
            label: 'Method:',
            value: ctrl.mode.value,
            items: [
              SelectItem('Collect', OrderMode.collect),
              SelectItem('Delivery', OrderMode.deliver),
            ],
            onChanged: (v) {
              clog(v);
              ctrl.setOrderMode(v);
            },
          ),
        )),
        mY(5),
        Obx(
          () => ctrl.mode.value == OrderMode.collect
              ? Container(
                  color: appBGLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TuCard(
                        child: Obx(() {
                          return storeCtrl.stores.value == null
                              ? none()
                              : TuSelect(
                                  label: "Store:",
                                  value: ctrl.store['_id'],
                                  items: storeCtrl.stores.value!.map((e) {
                                    return SelectItem(
                                        e['location']['name'], e['_id']);
                                  }).toList(),
                                  onChanged: (val) {
                                    var store = storeCtrl.stores.value!
                                        .where(
                                            (element) => element['_id'] == val)
                                        .first;
                                    ctrl.setStore(store);
                                  },
                                );
                        }),
                      ),
                      mY(topMargin),
                      TuCard(
                        child: Obx(
                          () => TuListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.black12,
                              child: svgIcon(
                                  name: 'br-user', color: TuColors.text2),
                            ),
                            title: Text(
                              ctrl.collector['name'] ?? "",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              ctrl.collector['phone'] ?? "",
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: SizedBox(
                              width: 24,
                              child: IconButton(
                                splashRadius: 20,
                                onPressed: () {
                                  TuFuncs.showBottomSheet(
                                      context: context,
                                      widget: editCollectorModal(context));
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: TuColors.text2,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
              : Obx(
                  () => appCtrl.user['delivery_addresses'].isNotEmpty
                      ? Column(
                          children: (appCtrl.user['delivery_addresses'] as List)
                              .map((e) {
                          return addressCard(context: context, address: e);
                        }).toList())
                      : Center(
                          child: SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: InkWell(
                            onTap: () {
                              TuFuncs.showBottomSheet(
                                  context: context,
                                  widget: const EditAddressForm());
                            },
                            child: const Card(
                                elevation: .5,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.black87,
                                  // size: 50,
                                )),
                          ),
                        )),
                ),
        ),
        mY(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(
              () => TuButton(
                text: "next",
                height: 35,
                //width: double.infinity,
                bgColor: TuColors.primary,
                onPressed: (ctrl.mode.value == OrderMode.collect &&
                            ctrl.store.isEmpty) ||
                        (ctrl.mode.value == OrderMode.deliver &&
                            ctrl.selectedAddr.isEmpty)
                    ? null
                    : () {
                        clog("Next up");
                        /* TODO: MAKE API REQUEST TO THECOURIE GUY FOR FEES */
                        ctrl.step++;
                      },
              ),
            ),
          ],
        )
      ],
    );
  }
}
