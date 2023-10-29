// ignore_for_file: use_build_context_synchronously

import "dart:convert";
import "package:via_logger/logger.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/utils/styles.dart";
import "package:lebzcafe/views/map.dart";
import "package:lebzcafe/views/order/index.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/common4.dart";
import "package:lebzcafe/widgets/form_view.dart";
import "package:get/get.dart";
import "package:lebzcafe/widgets/tu/common.dart";
import "package:lebzcafe/widgets/tu/form_field.dart";

class StoreInfoPage extends StatefulWidget {
  const StoreInfoPage({super.key});

  @override
  State<StoreInfoPage> createState() => _StoreInfoPageState();
}

class _StoreInfoPageState extends State<StoreInfoPage> {
  final appCtrl = Get.find<AppCtrl>();
  final formCtrl = Get.find<FormCtrl>();
  final storeCtrl = MainApp.storeCtrl;

  _init() async {
    getStores(storeCtrl: storeCtrl);
  }

  editFields() async {
    try {
      //Logger.info(formCtrl.form);
      final res =
          await apiDio().post("/store/update", data: {"data": formCtrl.form});
      // Logger.info(res);
      setupStoreDetails(data: res.data["store"]);
      Navigator.pop(context);
    } catch (e) {
      errorHandler(e: e, context: context);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      _init();
    });
  }

  _onBtnImportImgClick() async {
    //Import img  -> upload it to cloudinary -> update db store image -> display it
    try {
      final file = await importFile();
      if (file != null) {
        if (appCtrl.store["image"]["publicId"] != null) {
          Logger.info("Deleting old...");
          try {
            await signedCloudinary.destroy(appCtrl.store["image"]["publicId"]);
          } catch (e) {
            errorHandler(
                e: e, context: context, msg: "Failed to delete old image");
          }
        }

        Logger.info("Uploading...");
        showToast("Uploading image...").show(context);
        final res = await uploadImg(file, appCtrl: appCtrl);
        if (res.isResultOk) {
          Logger.info("Updating...");
          final res2 = await apiDio().post("/store/update", data: {
            "data": {
              "image": {"url": res.secureUrl, "publicId": res.publicId}
            }
          });
          setupStoreDetails(data: res2.data["store"]);
        }
      }
    } catch (e) {
      Logger.info(e);
      errorHandler(e: e, context: context, msg: "Failed to upload image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          childAppbar(showCart: false, title: "About ${appCtrl.store["name"]}"),
      body: RefreshIndicator(
        onRefresh: () async {
          await _init();
        },
        child: TuScrollview(
          child: Container(
            padding: EdgeInsets.all(topMargin),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...[appCtrl.store, appCtrl.owner, appCtrl.developer]
                  .asMap()
                  .entries
                  .map((e) => TuCard(
                      padding: 4,
                      radius: 0,
                      my: .5,
                      child: TuCollapse(
                          expanded: e.key == 0,
                          title:
                              "${(e.key == 0 ? "Store" : e.key == 1 ? "Owner" : "Developer")} details",
                          child: tuColumn(children: [
                            tuColumn(
                              children: [
                                h4("Name:", isLight: true),
                                mY(8),
                                Obx(() => Text(
                                      e.value["name"],
                                      style: TextStyle(color: TuColors.text2),
                                    )),
                                mY(4),
                                devider(),
                                mY(7)
                              ],
                            ),
                            tuColumn(
                              children: [
                                h4("Phone:", isLight: true),
                                mY(8),
                                Obx(() => SelectableText(
                                      e.value["phone"],
                                      style: TextStyle(color: TuColors.text2),
                                    )),
                                mY(4),
                                devider(),
                                mY(7)
                              ],
                            ),
                            tuColumn(
                              children: [
                                h4("Email:", isLight: true),
                                mY(8),
                                Obx(() => SelectableText(
                                      e.value["email"],
                                      style: TextStyle(color: TuColors.text2),
                                    )),
                                mY(4),
                                devider(),
                                mY(7)
                              ],
                            ),
                            Visibility(
                              visible: e.value["site"] != null,
                              child: tuColumn(
                                children: [
                                  h4("Website:", isLight: true),
                                  mY(8),
                                  Obx(() => SelectableText(
                                        e.value["site"],
                                        style: TextStyle(color: TuColors.text2),
                                      )),
                                  mY(4),
                                  devider(),
                                  mY(7)
                                ],
                              ),
                            ),
                          ]))))
                  .toList(),
              mY(topMargin),
              Visibility(
                visible: true,
                child: TuCard(
                    child: Column(
                  children: [
                    TuCard(child: Obx(
                      () {
                        return Column(
                          children: [
                            tuTableRow(
                                Text(
                                  "Locations & times",
                                  style: Styles.h3(),
                                ),
                                Obx(
                                  () => appCtrl.user.isEmpty
                                      ? none()
                                      : Visibility(
                                          visible:
                                              appCtrl.user["permissions"] > 0,
                                          child: InkWell(
                                            onTap: () {
                                              formCtrl.setForm({});
                                              TuFuncs.showBottomSheet(
                                                  context: context,
                                                  widget: const AddStoreView());
                                            },
                                            child: const Icon(
                                              CupertinoIcons.add,
                                              size: 27,
                                            ),
                                          ),
                                        ),
                                )),
                            mY(10),
                            storeCtrl.stores.value == null
                                ? const CircularProgressIndicator()
                                : Column(
                                    children: storeCtrl.stores.value!.reversed
                                        .map((it) {
                                      return storeCard(context, it);
                                    }).toList(),
                                  )
                          ],
                        );
                      },
                    ))
                  ],
                )),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class AddStoreView extends StatelessWidget {
  const AddStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formCtrl;
    final storeCtrl = MainApp.storeCtrl;
    return FormView(
      title: "Add store location",
      useBottomSheet: true,
      onSubmit: () async {
        var form = formCtrl.form;

        if (form["address"] == null) {
          return showToast("Valid store location is requred", isErr: true)
              .show(context);
        }
        try {
          showProgressSheet();

          final res = await apiDio().post("/stores/add", data: formCtrl.form);
          storeCtrl.setStores(res.data["stores"]);
          gpop();

          /// Navigator.pop(context);
          showToast("Store added successfully").show(context).then((value) {
            gpop();
          });
        } catch (e) {
          gpop();
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        Obx(() {
          var address = formCtrl.form["address"] ?? {};
          return TuFormField(
            label: "Address:",
            prefixIcon: TuIcon(Icons.location_on),
            readOnly: true,
            value: address != null ? address["place_name"] : null,
            required: true,
            onTap: () {
              pushTo(const MapPage());
            },
          );
        }),
        Obx(
          () => TuFormField(
            label: "Address line 2:",
            hint: "Apt / Suite / Bldng / Unit",
            value: formCtrl.form["address"]?["line2"],
            required: true,
            keyboard: TextInputType.streetAddress,
            onChanged: (val) {
              formCtrl.setFormField(
                  "address", {...formCtrl.form["address"] ?? {}, "line2": val});
            },
          ),
        ),
        mY(10),
        Text(
          "Weekdays",
          style: Styles.h3(isLight: true),
        ),
        mY(10),
        LayoutBuilder(builder: (context, c) {
          return tuTableRow(
              Obx(() => TuFormField(
                    label: "Open time:",
                    hasBorder: true,
                    readOnly: true,
                    required: true,
                    width: (c.maxWidth / 2) - 2.5,
                    // formCtrl.form represents the store
                    value: formCtrl.form["open_time"],
                    onTap: () async {
                      final val = await TuFuncs.dialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField(
                            "open_time", (val as TimeOfDay).format(context));
                      }
                    },
                  )),
              Obx(() => TuFormField(
                    label: "Close time:",
                    hasBorder: true,
                    readOnly: true,
                    required: true,
                    width: (c.maxWidth / 2) - 2.5,
                    // formCtrl.form represents the store
                    value: formCtrl.form["close_time"],
                    onTap: () async {
                      final val = await TuFuncs.dialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField(
                            "close_time", (val as TimeOfDay).format(context));
                      }
                    },
                  )),
              crossAxisAlignment: WrapCrossAlignment.start);
        }),
        mY(10),
        Text(
          "Weekend",
          style: Styles.h3(isLight: true),
        ),
        mY(10),
        LayoutBuilder(builder: (context, c) {
          return tuTableRow(
              Obx(() => TuFormField(
                    label: "Open time:",
                    hasBorder: true,
                    readOnly: true,
                    required: true,
                    width: (c.maxWidth / 2) - 2.5,
                    // formCtrl.form represents the store
                    value: formCtrl.form["open_time_weekend"],
                    onTap: () async {
                      final val = await TuFuncs.dialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField("open_time_weekend",
                            (val as TimeOfDay).format(context));
                      }
                    },
                  )),
              Obx(() => TuFormField(
                    label: "Close time:",
                    hasBorder: true,
                    readOnly: true,
                    required: true,
                    width: (c.maxWidth / 2) - 2.5,
                    // formCtrl.form represents the store
                    value: formCtrl.form["close_time_weekend"],
                    onTap: () async {
                      final val = await TuFuncs.dialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField("close_time_weekend",
                            (val as TimeOfDay).format(context));
                      }
                    },
                  )),
              crossAxisAlignment: WrapCrossAlignment.start);
        }),
      ],
    );
  }
}
