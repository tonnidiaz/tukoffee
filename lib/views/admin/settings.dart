// ignore_for_file: use_build_context_synchronously

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
import "package:lebzcafe/widgets/form_view.dart";
import "package:get/get.dart";
import "package:lebzcafe/widgets/tu/common.dart";
import "package:tu/tu.dart";

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final appCtrl = Get.find<AppCtrl>();
  final formCtrl = Get.find<FormCtrl>();
  final storeCtrl = MainApp.storeCtrl;

  _init() async {
    getStores(storeCtrl: storeCtrl);
  }

  editFields() async {
    try {
      //clog(formCtrl.form);
      final res =
          await apiDio().post("/store/update", data: {"data": formCtrl.form});
      // clog(res);
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
          clog("Deleting old...");
          try {
            await signedCloudinary.destroy(appCtrl.store["image"]["publicId"]);
          } catch (e) {
            errorHandler(
                e: e, context: context, msg: "Failed to delete old image");
          }
        }

        clog("Uploading...");
        showToast("Uploading image...").show(context);
        final res = await uploadImg(file, appCtrl: appCtrl);
        if (res.isResultOk) {
          clog("Updating...");
          final res2 = await apiDio().post("/store/update", data: {
            "data": {
              "image": {"url": res.secureUrl, "publicId": res.publicId}
            }
          });
          setupStoreDetails(data: res2.data["store"]);
        }
      }
    } catch (e) {
      clog(e);
      errorHandler(e: e, context: context, msg: "Failed to upload image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          childAppbar(showCart: false, title: "About ${appCtrl.store["name"]}"),
      body: SingleChildScrollView(
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
                        title:
                            "${(e.key == 0 ? "Store" : e.key == 1 ? "Owner" : "Developer")} details",
                        child: tuColumn(children: [
                          tuColumn(
                            children: [
                              h4("Name:", isLight: true),
                              mY(8),
                              Obx(() => Text(
                                    e.value["name"],
                                    style: TextStyle(color: colors.text2),
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
                                    style: TextStyle(color: colors.text2),
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
                                    style: TextStyle(color: colors.text2),
                                  )),
                              mY(4),
                              devider(),
                              mY(7)
                            ],
                          ),
                        ]))))
                .toList(),
            Visibility(
              visible: false,
              child: TuCard(
                  child: Column(
                children: [
                  Column(
                    children: [
                      /*     tuTableRow(
                          Text(
                            "Store details",
                            style: styles.h3(),
                          ),
                      ) */
                      tuTableRow(
                          Text(
                            "Name:",
                            style: styles.label(isBold: true),
                          ),
                          Obx(
                            () => Text(
                              appCtrl.store["name"],
                              style: styles.label(isLight: true),
                            ),
                          )),
                      tuTableRow(
                          Text(
                            "Phone:",
                            style: styles.label(isBold: true),
                          ),
                          Obx(
                            () => SelectableText(
                              appCtrl.store["phone"],
                              style: styles.label(isLight: true),
                            ),
                          )),
                      tuTableRow(
                          Text(
                            "Email:",
                            style: styles.label(isBold: true),
                          ),
                          Obx(
                            () => SizedBox(
                              width: 100,
                              child: SelectableText(
                                appCtrl.store["email"],
                                maxLines: 1,
                                style: styles.label(isLight: true),
                              ),
                            ),
                          )),
                      tuTableRow(
                          Text(
                            "Website:",
                            style: styles.label(isBold: true),
                          ),
                          Obx(
                            () => SizedBox(
                              width: 100,
                              child: SelectableText(
                                appCtrl.store["site"],
                                maxLines: 1,
                                style: styles.label(isLight: true),
                              ),
                            ),
                          )),
                    ],
                  ),
                  mY(10),
                  TuCard(
                    child: Column(
                      children: [
                        tuTableRow(
                            Text(
                              "Store owner",
                              style: styles.h3(),
                            ),
                            Obx(
                              () => appCtrl.user.isEmpty
                                  ? none()
                                  : Visibility(
                                      visible: appCtrl.user["permissions"] > 0,
                                      child: InkWell(
                                        onTap: () {
                                          formCtrl.setFormField("owner", {
                                            "name": appCtrl.owner["name"],
                                            "phone": appCtrl.owner["phone"],
                                            "email": appCtrl.owner["email"],
                                            "site": appCtrl.owner["site"],
                                          });
                                          showDialog(
                                              context: context,
                                              builder: (context) => FormView(
                                                  title: "Edit owner details",
                                                  fields: [
                                                    TuFormField(
                                                      label: "Owner name:",
                                                      hint:
                                                          "Enter owner name...",
                                                      required: true,
                                                      hasBorder: false,
                                                      value:
                                                          formCtrl.form["owner"]
                                                              ["name"],
                                                      onChanged: (val) {
                                                        Map owner = formCtrl
                                                            .form["owner"];
                                                        formCtrl.setFormField(
                                                            "owner", {
                                                          ...owner,
                                                          "name": val
                                                        });
                                                      },
                                                    ),
                                                    TuFormField(
                                                      label: "Owner phone:",
                                                      hasBorder: false,
                                                      hint:
                                                          "Enter owner phone number...",
                                                      keyboard:
                                                          TextInputType.phone,
                                                      required: true,
                                                      value:
                                                          formCtrl.form["owner"]
                                                              ["phone"],
                                                      onChanged: (val) {
                                                        Map owner = formCtrl
                                                            .form["owner"];
                                                        formCtrl.setFormField(
                                                            "owner", {
                                                          ...owner,
                                                          "phone": val
                                                        });
                                                      },
                                                    ),
                                                    TuFormField(
                                                      label: "Owner email:",
                                                      hasBorder: false,
                                                      hint:
                                                          "Enter owner email number...",
                                                      keyboard: TextInputType
                                                          .emailAddress,
                                                      required: true,
                                                      value:
                                                          formCtrl.form["owner"]
                                                              ["email"],
                                                      onChanged: (val) {
                                                        Map owner = formCtrl
                                                            .form["owner"];
                                                        formCtrl.setFormField(
                                                            "owner", {
                                                          ...owner,
                                                          "email": val
                                                        });
                                                      },
                                                    ),
                                                    mY(10),
                                                    TuFormField(
                                                      label: "Owner website:",
                                                      hasBorder: false,
                                                      hint:
                                                          "Enter owner website...",
                                                      keyboard:
                                                          TextInputType.url,
                                                      required: true,
                                                      value:
                                                          formCtrl.form["owner"]
                                                              ["site"],
                                                      onChanged: (val) {
                                                        Map owner = formCtrl
                                                            .form["owner"];
                                                        formCtrl.setFormField(
                                                            "owner", {
                                                          ...owner,
                                                          "site": val
                                                        });
                                                      },
                                                    ),
                                                    mY(10)
                                                  ],
                                                  onSubmit: () async {
                                                    editFields();
                                                  }));
                                        },
                                        child: const Icon(
                                          Icons.edit,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                            )),
                        tuTableRow(
                            Text(
                              "Name:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => Text(
                                appCtrl.owner["name"],
                                style: styles.label(isLight: true),
                              ),
                            )),
                        tuTableRow(
                            Text(
                              "Phone:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => SelectableText(
                                appCtrl.owner["phone"],
                                style: styles.label(isLight: true),
                              ),
                            )),
                        tuTableRow(
                            Text(
                              "Email:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => SizedBox(
                                width: 100,
                                child: SelectableText(
                                  appCtrl.owner["email"],
                                  maxLines: 1,
                                  style: styles.label(isLight: true),
                                ),
                              ),
                            )),
                        tuTableRow(
                            Text(
                              "Website:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => SizedBox(
                                width: 100,
                                child: SelectableText(
                                  appCtrl.owner["site"],
                                  maxLines: 1,
                                  style: styles.label(isLight: true),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  mY(10),
                  TuCard(
                    child: tuColumn(
                      children: [
                        Text(
                          "Developer",
                          style: styles.h3(),
                        ),
                        mY(7),
                        tuTableRow(
                            Text(
                              "Name:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => Text(
                                appCtrl.developer["name"],
                                style: styles.label(isLight: true),
                              ),
                            )),
                        tuTableRow(
                            Text(
                              "Phone:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => SelectableText(
                                appCtrl.developer["phone"],
                                style: styles.label(isLight: true),
                              ),
                            )),
                        tuTableRow(
                            Text(
                              "Email:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => SizedBox(
                                width: 100,
                                child: SelectableText(
                                  appCtrl.developer["email"],
                                  maxLines: 1,
                                  style: styles.label(isLight: true),
                                ),
                              ),
                            )),
                        tuTableRow(
                            Text(
                              "Website:",
                              style: styles.label(isBold: true),
                            ),
                            Obx(
                              () => SizedBox(
                                width: 100,
                                child: SelectableText(
                                  appCtrl.developer["site"],
                                  maxLines: 1,
                                  style: styles.label(isLight: true),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  mY(10),
                  TuCard(child: Obx(
                    () {
                      return Column(
                        children: [
                          tuTableRow(
                              Text(
                                "Locations",
                                style: styles.h3(),
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
                                            Get.bottomSheet(
                                                const AddStoreView());
                                          },
                                          child: const Icon(
                                            CupertinoIcons.add_circled,
                                            size: 27,
                                          ),
                                        ),
                                      ),
                              )),
                          mY(5),
                          storeCtrl.stores.value == null
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: storeCtrl.stores.value!.map((it) {
                                    return StoreCard(context, store: it);
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

        if (form["location"] == null) {
          return showToast("Valid store location is requred", isErr: true)
              .show(context);
        }
        try {
          final res = await apiDio().post("/stores/add", data: formCtrl.form);
          storeCtrl.setStores(res.data["stores"]);

          /// Navigator.pop(context);
          showToast("Store added successfully").show(context);
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        Obx(() {
          var location = formCtrl.form["location"];
          return TuFormField(
            label: "Address:",
            prefixIcon: TuIcon(Icons.location_on),
            readOnly: true,
            value: location != null ? location["name"] : null,
            required: true,
            onTap: () {
              pushTo(const MapPage());
            },
          );
        }),
        mY(10),
        Text(
          "Weekdays",
          style: styles.h3(),
        ),
        mY(10),
        LayoutBuilder(builder: (context, c) {
          return tuTableRow(
              Obx(() => TuFormField(
                    label: "Open time:",
                    hasBorder: true,
                    readOnly: true,
                    required: true,
                    width: (c.maxWidth / 2) - 5,
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
                    width: (c.maxWidth / 2) - 5,
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
                  )));
        }),
        mY(10),
        Text(
          "Weekends",
          style: styles.h3(),
        ),
        mY(10),
        LayoutBuilder(builder: (context, c) {
          return tuTableRow(
              Obx(() => TuFormField(
                    label: "Open time:",
                    hasBorder: true,
                    readOnly: true,
                    required: true,
                    width: (c.maxWidth / 2) - 5,
                    // formCtrl.form represents the store
                    value: formCtrl.form["open_time_weekends"],
                    onTap: () async {
                      final val = await TuFuncs.dialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField("open_time_weekends",
                            (val as TimeOfDay).format(context));
                      }
                    },
                  )),
              Obx(() => TuFormField(
                    label: "Close time:",
                    hasBorder: true,
                    readOnly: true,
                    required: true,
                    width: (c.maxWidth / 2) - 5,
                    // formCtrl.form represents the store
                    value: formCtrl.form["close_time_weekends"],
                    onTap: () async {
                      final val = await TuFuncs.dialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField("close_time_weekends",
                            (val as TimeOfDay).format(context));
                      }
                    },
                  )));
        }),
      ],
    );
  }
}
