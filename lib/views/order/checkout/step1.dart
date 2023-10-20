import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/functions2.dart';
import 'package:lebzcafe/views/order/checkout.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/views/rf.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:lebzcafe/widgets/tu/select.dart';

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
                                              e['place_name'], e['_id']);
                                        }).toList(),
                                        onChanged: (val) {
                                          var store = storeCtrl.stores.value!
                                              .where((element) =>
                                                  element['_id'] == val)
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
                            () => appCtrl.user['delivery_addresses'].isNotEmpty
                                ? Column(
                                    children: (appCtrl
                                            .user['delivery_addresses'] as List)
                                        .map((e) {
                                    return addressCard(
                                        context: context, address: e);
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
                        ],
                      ),
              ),
              mY(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => TuButton(
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
                              showProgressSheet(msg: "Calculating total...");

                              double total = 0;
                              for (var it in storeCtrl.cart["products"]) {
                                total +=
                                    (it["product"]["price"] * it["quantity"])
                                        .toDouble();
                              }

                              final res = await getCourierGuyRates(
                                  items: storeCtrl.cart['products']
                                      .map((pr) => pr['product'])
                                      .toList(),
                                  total: total,
                                  from: storeCtrl.stores.value?[0]['address'],
                                  to: ctrl.selectedAddr);
                              gpop();
                              if (res == null) return;
                              Get.bottomSheet(DatesRatesSheet(
                                rates: res['rates'],
                              ));
                              // ctrl.step++;
                            },
                    ),
                  ),
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
                'When would you like your order delivered?',
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
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 1.5),
                  color: appBGLight,
                  child: ListTile(
                    onTap: () {
                      clog("TAPPED");
                      storeCtrl.setDeliveryFee(rate['rate'].toDouble());
                      gpop();
                      ctrl.step++;
                    },
                    title: Text("${rate['service_level']['delivery_date_from']}"
                        .split('T')
                        .first),
                    subtitle: Text("${rate['service_level']['name']} delivery"),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        "R${rate['rate']}",
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

Map<String, dynamic> addrToCourierGuyAddr(Map<String, dynamic> addr) {
  return {
    "street_address": addr['street'],
    "local_area": addr['suburb'],
    "city": addr['city'],
    "zone": addr['state'],
    "country": "ZA",
    "code": "${addr['postcode']}",
    "lat": addr['center'].first,
    "lng": addr['center'].last
  };
}

getCourierGuyRates(
    {required Map<String, dynamic> from,
    required Map<String, dynamic> to,
    required double total,
    required List items}) async {
  try {
    final today = DateTime.now().toLocal();
    final collectionDate = "${today.year}-${today.month}-${today.day}";
    final reqData = {
      "collection_min_date": collectionDate,
      "delivery_min_date": collectionDate,
      "collection_address": {
        "company": MainApp.appCtrl.store['name'],
        "type": "business",
        ...addrToCourierGuyAddr(from)
      },
      "declared_value": total,
      "delivery_address": {"type": "residential", ...addrToCourierGuyAddr(to)},
      "parcels": items
          .map(
            (e) => {
              "submitted_width_cm": 13.5,
              "submitted_height_cm": 27.5,
              "submitted_weight_kg": e['weight']
            },
          )
          .toList()
    };
    clog(collectionDate);
    final r = await shiplogicDio().post('/rates', data: reqData);

    return r.data;
  } catch (e) {
    errorHandler(e: e, context: appCtx!);
    return null;
  }
}

const Map<String, dynamic> courierGuyRatesRes = {
  "message": "Success",
  "rates": [
    {
      "rate": 85,
      "rate_excluding_vat": 73.91304347826087,
      "base_rate": {
        "charge_per_parcel": [85],
        "charge": 85,
        "group_name": "Default group",
        "vat": 11.086956521739125,
        "vat_type": "standard",
        "rate_formula_type": "flat",
        "total_calculated_weight": 2
      },
      "service_level": {
        "id": 18051,
        "code": "ECO",
        "name": "Economy",
        "description": "Delivered within 2-3 days",
        "delivery_date_from": "2023-10-20T08:00:00+02:00",
        "delivery_date_to": "2023-10-23T08:00:00+02:00",
        "collection_date": "2023-10-18T14:55:56.631274531+02:00",
        "collection_cut_off_time": "2023-10-18T15:00:00+02:00",
        "vat_type": "standard",
        "insurance_disabled": false
      },
      "service_day_tags": {
        "collection_service_day_tags": null,
        "delivery_service_day_tags": null
      },
      "surcharges": [],
      "rate_adjustments": [],
      "time_based_rate_adjustments": [],
      "extras": [
        {"id": 11701, "insurance_charge": 0, "vat": 0, "vat_type": "standard"}
      ],
      "charged_weight": 2
    },
    {
      "rate": 258.75,
      "rate_excluding_vat": 225.00000000000003,
      "base_rate": {
        "charge_per_parcel": [86.25, 86.25, 86.25],
        "charge": 258.75,
        "group_name": "Default group",
        "vat": 33.74999999999997,
        "vat_type": "standard",
        "rate_formula_type": "formula",
        "total_calculated_weight": 3
      },
      "service_level": {
        "id": 18053,
        "code": "LSF",
        "name": "Local Sameday Flyer",
        "description": "",
        "delivery_date_from": "2023-10-19T09:00:00+02:00",
        "delivery_date_to": "2023-10-19T15:00:00+02:00",
        "collection_date": "2023-10-19T08:00:00+02:00",
        "collection_cut_off_time": "2023-10-18T10:30:00+02:00",
        "vat_type": "standard",
        "insurance_disabled": false
      },
      "service_day_tags": {
        "collection_service_day_tags": null,
        "delivery_service_day_tags": null
      },
      "surcharges": [],
      "rate_adjustments": [],
      "time_based_rate_adjustments": [],
      "extras": [
        {"id": 11701, "insurance_charge": 0, "vat": 0, "vat_type": "standard"}
      ],
      "charged_weight": 3
    },
    {
      "rate": 258.75,
      "rate_excluding_vat": 225.00000000000003,
      "base_rate": {
        "charge_per_parcel": [86.25, 86.25, 86.25],
        "charge": 258.75,
        "group_name": "Default group",
        "vat": 33.74999999999997,
        "vat_type": "standard",
        "rate_formula_type": "formula",
        "total_calculated_weight": 3
      },
      "service_level": {
        "id": 18054,
        "code": "LOF",
        "name": "Local Overnight Flyer",
        "description": "",
        "delivery_date_from": "2023-10-19T16:00:00+02:00",
        "delivery_date_to": "2023-10-20T15:00:00+02:00",
        "collection_date": "2023-10-19T08:00:00+02:00",
        "collection_cut_off_time": "2023-10-18T14:00:00+02:00",
        "vat_type": "standard",
        "insurance_disabled": false
      },
      "service_day_tags": {
        "collection_service_day_tags": null,
        "delivery_service_day_tags": null
      },
      "surcharges": [],
      "rate_adjustments": [],
      "time_based_rate_adjustments": [],
      "extras": [
        {"id": 11701, "insurance_charge": 0, "vat": 0, "vat_type": "standard"}
      ],
      "charged_weight": 3
    },
    {
      "rate": 310.5,
      "rate_excluding_vat": 270,
      "base_rate": {
        "charge_per_parcel": [103.5, 103.5, 103.5],
        "charge": 310.5,
        "group_name": "Default group",
        "vat": 40.5,
        "vat_type": "standard",
        "rate_formula_type": "formula",
        "total_calculated_weight": 3
      },
      "service_level": {
        "id": 18055,
        "code": "LSE",
        "name": "Local Same Day Economy",
        "description": "",
        "delivery_date_from": "2023-10-19T09:00:00+02:00",
        "delivery_date_to": "2023-10-19T15:00:00+02:00",
        "collection_date": "2023-10-19T08:00:00+02:00",
        "collection_cut_off_time": "2023-10-18T10:30:00+02:00",
        "vat_type": "standard",
        "insurance_disabled": false
      },
      "service_day_tags": {
        "collection_service_day_tags": null,
        "delivery_service_day_tags": null
      },
      "surcharges": [],
      "rate_adjustments": [],
      "time_based_rate_adjustments": [],
      "extras": [
        {"id": 11701, "insurance_charge": 0, "vat": 0, "vat_type": "standard"}
      ],
      "charged_weight": 3
    },
    {
      "rate": 730,
      "rate_excluding_vat": 634.7826086956522,
      "base_rate": {
        "charge_per_parcel": [560, 85, 85],
        "charge": 730,
        "group_name": "Default group",
        "vat": 95.21739130434776,
        "vat_type": "standard",
        "rate_formula_type": "flat",
        "total_calculated_weight": 3
      },
      "service_level": {
        "id": 18056,
        "code": "LSX",
        "name": "Local Sameday Express",
        "description":
            "Collection sameday after 8:00 but before 15:00, delivery within 90 minutes.  ",
        "delivery_date_from": "2023-10-19T09:00:00+02:00",
        "delivery_date_to": "2023-10-19T15:00:00+02:00",
        "collection_date": "2023-10-19T08:00:00+02:00",
        "collection_cut_off_time": "2023-10-18T14:00:00+02:00",
        "vat_type": "standard",
        "insurance_disabled": false
      },
      "service_day_tags": {
        "collection_service_day_tags": null,
        "delivery_service_day_tags": null
      },
      "surcharges": [],
      "rate_adjustments": [],
      "time_based_rate_adjustments": [],
      "extras": [
        {"id": 11701, "insurance_charge": 0, "vat": 0, "vat_type": "standard"}
      ],
      "charged_weight": 3
    }
  ]
};
