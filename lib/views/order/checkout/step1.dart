import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:lebzcafe/controllers/store_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/utils/functions2.dart";
import "package:lebzcafe/views/order/checkout.dart";
import "package:lebzcafe/views/order/index.dart";
import "package:lebzcafe/views/rf.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/tu/common.dart";
import "package:lebzcafe/widgets/tu/select.dart";

class CheckoutStep1 extends StatelessWidget {
  final CheckoutCtrl ctrl;
  const CheckoutStep1({super.key, required this.ctrl});

  static String title = "Method";
  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    final storeCtrl = MainApp.storeCtrl;
    return SingleChildScrollView(
        child: Column(
      children: [
        Container(
          padding: defaultPadding,
          child: Column(
            children: [
              TuCard(
                  child: Obx(
                () => TuSelect(
                  label: "Method:",
                  value: ctrl.mode.value,
                  items: [
                    SelectItem("Collect", OrderMode.collect),
                    SelectItem("Delivery", OrderMode.deliver),
                  ],
                  onChanged: (v) {
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
                                        value: ctrl.store["_id"],
                                        items: storeCtrl.stores.value!.map((e) {
                                          return SelectItem(
                                              "${e["address"]?["place_name"]}",
                                              e["_id"]);
                                        }).toList(),
                                        onChanged: (val) {
                                          var store = storeCtrl.stores.value!
                                              .where((element) =>
                                                  element["_id"] == val)
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
                                        name: "br-user", color: TuColors.text2),
                                  ),
                                  title: Text(
                                    ctrl.collector["name"] ?? "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    ctrl.collector["phone"] ?? "",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: SizedBox(
                                    width: 24,
                                    child: IconButton(
                                      splashRadius: 20,
                                      onPressed: () {
                                        TuFuncs.showBottomSheet(
                                            context: context,
                                            widget:
                                                editCollectorModal(context));
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
                    : Column(
                        children: [
                          tuTableRow(
                              h3("Delivery address", isLight: true),
                              SizedBox(
                                width: 25,
                                child: IconButton(
                                  onPressed: () {
                                    TuFuncs.showBottomSheet(
                                        context: context,
                                        widget: const EditAddressForm());
                                  },
                                  splashRadius: 24,
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add_outlined),
                                ),
                              ),
                              my: 0),
                          Obx(
                            () => appCtrl.user["delivery_addresses"].isNotEmpty
                                ? Column(
                                    children: (appCtrl
                                            .user["delivery_addresses"] as List)
                                        .map((e) {
                                    return addressCard(
                                        context: context, address: e);
                                  }).toList())
                                : Center(
                                    child: TuCard(
                                        height: 70,
                                        onTap: () {
                                          TuFuncs.showBottomSheet(
                                              context: context,
                                              widget: const EditAddressForm());
                                        },
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.black87,
                                          // size: 50,
                                        ))),
                          ),
                        ],
                      ),
              ),
              mY(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    return TuButton(
                      text: "next",
                      width: screenSize(context).width - 20,
                      bgColor: TuColors.primary,
                      onPressed: (ctrl.mode.value == OrderMode.collect &&
                                  ctrl.store.isEmpty) ||
                              (ctrl.mode.value == OrderMode.deliver &&
                                  ctrl.selectedAddr.isEmpty)
                          ? null
                          : () async {
                              clog("Next up");

                              if (ctrl.mode.value == OrderMode.collect) {
                                ctrl.step++;
                                return;
                              }
                              showProgressSheet(msg: "Calculating total...");
                              List items = [];
                              for (var item in storeCtrl.cart["products"]) {
                                for (var pr
                                    in List.filled(item["quantity"], 0)) {
                                  items.add(item["product"]);
                                }
                              }
                              final res = await Shiplogic.getRates(
                                  items: items,
                                  total: storeCtrl.total.value,
                                  from: storeCtrl.stores.value?[0]["address"],
                                  to: ctrl.selectedAddr);
                              gpop();
                              if (res == null) return;
                              Get.bottomSheet(DatesRatesSheet(
                                rates: res["rates"],
                              ));
                              // ctrl.step++;
                            },
                    );
                  }),
                ],
              )
            ],
          ),
        ),
      ],
    ));
  }
}

class DatesRatesSheet extends StatelessWidget {
  final List rates;
  const DatesRatesSheet({super.key, required this.rates});

  @override
  Widget build(BuildContext context) {
    final StoreCtrl storeCtrl = Get.find();
    final CheckoutCtrl ctrl = Get.find();
    return TuCard(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: tuColumn(min: true, children: [
              h3("Dates & Delivery Fees"),
              mY(10),
              Text(
                "When would you like your order delivered?",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              mY(6),
              devider(),
              mY(10)
            ]),
          ),
          SliverList.builder(
              itemCount: rates.length,
              itemBuilder: (context, i) {
                var rate = rates.elementAt(i);
                final String deliveryDateFrom =
                    rate["service_level"]["delivery_date_from"];
                final String deliveryDateTo =
                    rate["service_level"]["delivery_date_to"];
                //final String date1
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 1.5),
                  color: appBGLight,
                  child: ListTile(
                    isThreeLine: true,
                    onTap: () {
                      ctrl.form["shiplogic"] = {
                        "service_level": rate["service_level"]
                      };

                      storeCtrl.setDeliveryFee(rate["rate"].toDouble());
                      gpop();
                      ctrl.step++;
                    },
                    title: Text("${rate["service_level"]["name"]} delivery"),
                    subtitle: tuColumn(
                      min: true,
                      children: [
                        mY(5),
                        const Text(
                          "FROM:",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(formatDate(deliveryDateFrom)),
                        mY(5),
                        const Text(
                          "TO:",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(formatDate(deliveryDateTo)),
                      ],
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        "R${rate["rate"]}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: TuColors.text2),
                      ),
                      const Icon(Icons.chevron_right)
                    ]),
                  ),
                );
              })
        ],
      ),
    );
  }
}
