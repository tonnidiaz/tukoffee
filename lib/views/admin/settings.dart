// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/map.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/form_view.dart';
import 'package:get/get.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final appCtrl = Get.find<AppCtrl>();
  final formCtrl = Get.find<FormViewCtrl>();
  final storeCtrl = MainApp.storeCtrl;

  _init() async {
    getStores(storeCtrl: storeCtrl);
  }

  editFields() async {
    try {
      final res =
          await apiDio().post('/store/update', data: {'data': formCtrl.form});
      setupStoreDetails(data: res.data['store']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: childAppbar(showCart: false),
      body: SingleChildScrollView(
        child: Container(
          padding: defaultPadding,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            /* Text("Store settings", style: Styles.h1),
            mY(10), */
            TuCard(
                child: Column(
              children: [
                tuTableRow(
                    Text(
                      "Store details",
                      style: Styles.h2(),
                    ),
                    Obx(
                      () => Visibility(
                        visible: appCtrl.user['permissions'] > 0,
                        child: InkWell(
                          onTap: () {
                            // Edit name and phone
                            formCtrl.setForm({
                              'name': appCtrl.storeName.value,
                              'phone': appCtrl.storePhone.value,
                            });
                            showDialog(
                                context: context,
                                builder: (context) => FormView(
                                    title: "Edit store details",
                                    fields: [
                                      TuFormField(
                                        label: "Store name:",
                                        hint: "Enter store name...",
                                        isRequired: true,
                                        hasBorder: false,
                                        value: formCtrl.form['name'],
                                        onChanged: (val) {
                                          formCtrl.setFormField('name', val);
                                        },
                                      ),
                                      TuFormField(
                                        label: "Store phone:",
                                        hasBorder: false,
                                        hint: "Enter store phone number...",
                                        isRequired: true,
                                        keyboard: TextInputType.phone,
                                        value: formCtrl.form['phone'],
                                        onChanged: (val) {
                                          formCtrl.setFormField('phone', val);
                                        },
                                      ),
                                      TuFormField(
                                        label: "Store website:",
                                        hasBorder: false,
                                        hint: "Enter store website url...",
                                        isRequired: false,
                                        keyboard: TextInputType.url,
                                        value: formCtrl.form['site'],
                                        onChanged: (val) {
                                          formCtrl.setFormField('site', val);
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
                      "Store name:",
                      style: Styles.label(isBold: true),
                    ),
                    Obx(
                      () => Text(
                        appCtrl.storeName.value,
                        style: Styles.label(isLight: true),
                      ),
                    )),
                tuTableRow(
                    Text(
                      "Store phone:",
                      style: Styles.label(isBold: true),
                    ),
                    Obx(
                      () => SelectableText(
                        appCtrl.storePhone.value,
                        style: Styles.label(isLight: true),
                      ),
                    )),
                tuTableRow(
                    Text(
                      "Store website:",
                      style: Styles.label(isBold: true),
                    ),
                    Obx(
                      () => SizedBox(
                        width: 100,
                        child: SelectableText(
                          appCtrl.storeSite.value,
                          maxLines: 1,
                          //overflow: TextOverflow.ellipsis,
                          style: Styles.label(isLight: true),
                        ),
                      ),
                    )),
                mY(10),
                TuCard(
                    child: Column(
                  children: [
                    tuTableRow(
                        Text(
                          "Store owner",
                          style: Styles.h2(),
                        ),
                        Obx(
                          () => Visibility(
                            visible: appCtrl.user['permissions'] > 0,
                            child: InkWell(
                              onTap: () {
                                formCtrl.setForm({
                                  'ownerName': appCtrl.ownerName.value,
                                  'ownerPhone': appCtrl.ownerPhone.value,
                                });
                                showDialog(
                                    context: context,
                                    builder: (context) => FormView(
                                        title: "Edit owner details",
                                        fields: [
                                          TuFormField(
                                            label: "Owner name:",
                                            hint: "Enter owner name...",
                                            isRequired: true,
                                            hasBorder: false,
                                            value: formCtrl.form['ownerName'],
                                            onChanged: (val) {
                                              formCtrl.setFormField(
                                                  'ownerName', val);
                                            },
                                          ),
                                          TuFormField(
                                            label: "Owner phone:",
                                            hasBorder: false,
                                            hint: "Enter owner phone number...",
                                            isRequired: true,
                                            value: formCtrl.form['ownerPhone'],
                                            onChanged: (val) {
                                              formCtrl.setFormField(
                                                  'ownerPhone', val);
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
                          style: Styles.label(isBold: true),
                        ),
                        Obx(
                          () => Text(
                            appCtrl.ownerName.value,
                            style: Styles.label(isLight: true),
                          ),
                        )),
                    tuTableRow(
                        Text(
                          "Phone:",
                          style: Styles.label(isBold: true),
                        ),
                        Obx(
                          () => SelectableText(
                            appCtrl.ownerPhone.value,
                            style: Styles.label(isLight: true),
                          ),
                        )),
                  ],
                )),
                mY(10),
                TuCard(child: Obx(
                  () {
                    return Column(
                      children: [
                        tuTableRow(
                            Text(
                              "Locations",
                              style: Styles.h2(),
                            ),
                            Obx(
                              () => Visibility(
                                visible: appCtrl.user['permissions'] > 0,
                                child: InkWell(
                                  onTap: () {
                                    formCtrl.setForm({});
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) =>
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
                            ? const Text("Loading...")
                            : Column(
                                children: storeCtrl.stores.value!.map((it) {
                                  return storeCard(context, it);
                                }).toList(),
                              )
                      ],
                    );
                  },
                ))
              ],
            ))
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
    final formCtrl = MainApp.formViewCtrl;
    final storeCtrl = MainApp.storeCtrl;
    return FormView(
      title: "Add store location",
      useBottomSheet: true,
      onSubmit: () async {
        var form = formCtrl.form;

        if (form['location'] == null) {
          return showToast("Valid store location is requred", isErr: true)
              .show(context);
        }
        try {
          final res = await apiDio().post('/stores/add', data: formCtrl.form);
          storeCtrl.setStores(res.data['stores']);

          /// Navigator.pop(context);
          showToast("Store added successfully").show(context);
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        Obx(() {
          var location = formCtrl.form['location'];
          return TuFormField(
            label: "Address:",
            prefixIcon: TuIcon(Icons.location_on),
            readOnly: true,
            value: location != null ? location['name'] : null,
            isRequired: true,
            onTap: () {
              pushTo(context, const MapPage());
            },
          );
        }),
        mY(10),
        Text(
          "Weekdays",
          style: Styles.h3(),
        ),
        mY(10),
        LayoutBuilder(builder: (context, c) {
          return tuTableRow(
              Obx(() => TuFormField(
                    label: "Open time:",
                    hasBorder: true,
                    readOnly: true,
                    isRequired: true,
                    width: (c.maxWidth / 2) - 5,
                    // formCtrl.form represents the store
                    value: formCtrl.form['open_time'],
                    onTap: () async {
                      final val = await TuFuncs.showTDialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField(
                            'open_time', (val as TimeOfDay).format(context));
                      }
                    },
                  )),
              Obx(() => TuFormField(
                    label: "Close time:",
                    hasBorder: true,
                    readOnly: true,
                    isRequired: true,
                    width: (c.maxWidth / 2) - 5,
                    // formCtrl.form represents the store
                    value: formCtrl.form['close_time'],
                    onTap: () async {
                      final val = await TuFuncs.showTDialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField(
                            'close_time', (val as TimeOfDay).format(context));
                      }
                    },
                  )));
        }),
        mY(10),
        Text(
          "Weekends",
          style: Styles.h3(),
        ),
        mY(10),
        LayoutBuilder(builder: (context, c) {
          return tuTableRow(
              Obx(() => TuFormField(
                    label: "Open time:",
                    hasBorder: true,
                    readOnly: true,
                    isRequired: true,
                    width: (c.maxWidth / 2) - 5,
                    // formCtrl.form represents the store
                    value: formCtrl.form['open_time_weekends'],
                    onTap: () async {
                      final val = await TuFuncs.showTDialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField('open_time_weekends',
                            (val as TimeOfDay).format(context));
                      }
                    },
                  )),
              Obx(() => TuFormField(
                    label: "Close time:",
                    hasBorder: true,
                    readOnly: true,
                    isRequired: true,
                    width: (c.maxWidth / 2) - 5,
                    // formCtrl.form represents the store
                    value: formCtrl.form['close_time_weekends'],
                    onTap: () async {
                      final val = await TuFuncs.showTDialog(context,
                          TimePickerDialog(initialTime: TimeOfDay.now()));
                      if (val != null) {
                        formCtrl.setFormField('close_time_weekends',
                            (val as TimeOfDay).format(context));
                      }
                    },
                  )));
        }),
      ],
    );
  }
}
