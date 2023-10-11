// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
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
      //clog(formCtrl.form);
      final res =
          await apiDio().post('/store/update', data: {'data': formCtrl.form});
      // clog(res);
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

  _onBtnImportImgClick() async {
    //Import img  -> upload it to cloudinary -> update db store image -> display it
    try {
      final file = await importFile();
      if (file != null) {
        if (appCtrl.store['image']['publicId'] != null) {
          clog("Deleting old...");
          try {
            await signedCloudinary.destroy(appCtrl.store['image']['publicId']);
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
          final res2 = await apiDio().post('/store/update', data: {
            'data': {
              'image': {'url': res.secureUrl, 'publicId': res.publicId}
            }
          });
          setupStoreDetails(data: res2.data['store']);
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
      appBar: childAppbar(showCart: false, title: "Store Config"),
      body: SingleChildScrollView(
        child: Container(
          padding: defaultPadding,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    Container(
                      height: 70,
                      width: 80,
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 1.5, color: Colors.black12)),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Obx(
                            () => appCtrl.store['image'] != null
                                ? Image.network(
                                    appCtrl.store['image']['url'],
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 30,
                                  ),
                          ),
                          Visibility(
                            visible: appCtrl.user.isNotEmpty &&
                                appCtrl.user['permissions'] > 0,
                            child: Positioned(
                                bottom: 0,
                                left: 0,
                                width: 80,
                                child: Container(
                                  color: const Color.fromRGBO(40, 40, 40, .85),
                                  height: 20,
                                  child: InkWell(
                                    onTap: _onBtnImportImgClick,
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                    mX(10),
                    Obx(
                      () => Text(
                        "${appCtrl.store['name']}",
                        style: Styles.h2(),
                      ),
                    ),
                  ],
                )),
            TuCard(
                child: Column(
              children: [
                Column(
                  children: [
                    tuTableRow(
                        Text(
                          "Store details",
                          style: Styles.h2(),
                        ),
                        Obx(
                          () => appCtrl.user.isEmpty
                              ? none()
                              : Visibility(
                                  visible: appCtrl.user['permissions'] > 0,
                                  child: InkWell(
                                    onTap: () {
                                      formCtrl.setFormField(
                                          "store", appCtrl.store);
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
                                                  value: formCtrl.form['store']
                                                      ['name'],
                                                  onChanged: (val) {
                                                    Map owner =
                                                        formCtrl.form['store'];
                                                    formCtrl.setFormField(
                                                        'store', {
                                                      ...owner,
                                                      'name': val
                                                    });
                                                  },
                                                ),
                                                TuFormField(
                                                  label: "Store phone:",
                                                  hasBorder: false,
                                                  hint:
                                                      "Enter store phone number...",
                                                  keyboard: TextInputType.phone,
                                                  isRequired: true,
                                                  value: formCtrl.form['store']
                                                      ['phone'],
                                                  onChanged: (val) {
                                                    Map owner =
                                                        formCtrl.form['store'];
                                                    formCtrl.setFormField(
                                                        'store', {
                                                      ...owner,
                                                      'phone': val
                                                    });
                                                  },
                                                ),
                                                TuFormField(
                                                  label: "Store email:",
                                                  hasBorder: false,
                                                  hint:
                                                      "Enter store email number...",
                                                  keyboard: TextInputType
                                                      .emailAddress,
                                                  isRequired: true,
                                                  value: formCtrl.form['store']
                                                      ['email'],
                                                  onChanged: (val) {
                                                    Map owner =
                                                        formCtrl.form['store'];
                                                    formCtrl.setFormField(
                                                        'store', {
                                                      ...owner,
                                                      'email': val
                                                    });
                                                  },
                                                ),
                                                mY(10),
                                                TuFormField(
                                                  label: "Store website:",
                                                  hasBorder: false,
                                                  hint:
                                                      "Enter store website...",
                                                  keyboard: TextInputType.url,
                                                  isRequired: true,
                                                  value: formCtrl.form['store']
                                                      ['site'],
                                                  onChanged: (val) {
                                                    Map owner =
                                                        formCtrl.form['store'];
                                                    formCtrl.setFormField(
                                                        'store', {
                                                      ...owner,
                                                      'site': val
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
                          style: Styles.label(isBold: true),
                        ),
                        Obx(
                          () => Text(
                            appCtrl.store['name'],
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
                            appCtrl.store['phone'],
                            style: Styles.label(isLight: true),
                          ),
                        )),
                    tuTableRow(
                        Text(
                          "Email:",
                          style: Styles.label(isBold: true),
                        ),
                        Obx(
                          () => SizedBox(
                            width: 100,
                            child: SelectableText(
                              appCtrl.store['email'],
                              maxLines: 1,
                              style: Styles.label(isLight: true),
                            ),
                          ),
                        )),
                    tuTableRow(
                        Text(
                          "Website:",
                          style: Styles.label(isBold: true),
                        ),
                        Obx(
                          () => SizedBox(
                            width: 100,
                            child: SelectableText(
                              appCtrl.store['site'],
                              maxLines: 1,
                              style: Styles.label(isLight: true),
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
                            style: Styles.h2(),
                          ),
                          Obx(
                            () => appCtrl.user.isEmpty
                                ? none()
                                : Visibility(
                                    visible: appCtrl.user['permissions'] > 0,
                                    child: InkWell(
                                      onTap: () {
                                        formCtrl.setFormField("owner", {
                                          'name': appCtrl.owner['name'],
                                          'phone': appCtrl.owner['phone'],
                                          'email': appCtrl.owner['email'],
                                          'site': appCtrl.owner['site'],
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
                                                    value: formCtrl
                                                        .form['owner']['name'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['owner'];
                                                      formCtrl.setFormField(
                                                          'owner', {
                                                        ...owner,
                                                        'name': val
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
                                                    isRequired: true,
                                                    value: formCtrl
                                                        .form['owner']['phone'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['owner'];
                                                      formCtrl.setFormField(
                                                          'owner', {
                                                        ...owner,
                                                        'phone': val
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
                                                    isRequired: true,
                                                    value: formCtrl
                                                        .form['owner']['email'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['owner'];
                                                      formCtrl.setFormField(
                                                          'owner', {
                                                        ...owner,
                                                        'email': val
                                                      });
                                                    },
                                                  ),
                                                  mY(10),
                                                  TuFormField(
                                                    label: "Owner website:",
                                                    hasBorder: false,
                                                    hint:
                                                        "Enter owner website...",
                                                    keyboard: TextInputType.url,
                                                    isRequired: true,
                                                    value: formCtrl
                                                        .form['owner']['site'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['owner'];
                                                      formCtrl.setFormField(
                                                          'owner', {
                                                        ...owner,
                                                        'site': val
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
                            style: Styles.label(isBold: true),
                          ),
                          Obx(
                            () => Text(
                              appCtrl.owner['name'],
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
                              appCtrl.owner['phone'],
                              style: Styles.label(isLight: true),
                            ),
                          )),
                      tuTableRow(
                          Text(
                            "Email:",
                            style: Styles.label(isBold: true),
                          ),
                          Obx(
                            () => SizedBox(
                              width: 100,
                              child: SelectableText(
                                appCtrl.owner['email'],
                                maxLines: 1,
                                style: Styles.label(isLight: true),
                              ),
                            ),
                          )),
                      tuTableRow(
                          Text(
                            "Website:",
                            style: Styles.label(isBold: true),
                          ),
                          Obx(
                            () => SizedBox(
                              width: 100,
                              child: SelectableText(
                                appCtrl.owner['site'],
                                maxLines: 1,
                                style: Styles.label(isLight: true),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                mY(10),
                TuCard(
                  child: Column(
                    children: [
                      tuTableRow(
                          Text(
                            "Developer",
                            style: Styles.h2(),
                          ),
                          Obx(
                            () => appCtrl.user.isEmpty
                                ? none()
                                : Visibility(
                                    visible: appCtrl.user['permissions'] > 0,
                                    child: InkWell(
                                      onTap: () {
                                        formCtrl.setFormField(
                                            "developer", appCtrl.developer);
                                        showDialog(
                                            context: context,
                                            builder: (context) => FormView(
                                                title: "Edit developer details",
                                                fields: [
                                                  TuFormField(
                                                    label: "Developer name:",
                                                    hint:
                                                        "Enter developer name...",
                                                    isRequired: true,
                                                    hasBorder: false,
                                                    value: formCtrl
                                                            .form['developer']
                                                        ['name'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['developer'];
                                                      formCtrl.setFormField(
                                                          'developer', {
                                                        ...owner,
                                                        'name': val
                                                      });
                                                    },
                                                  ),
                                                  TuFormField(
                                                    label: "Developer phone:",
                                                    hasBorder: false,
                                                    hint:
                                                        "Enter developer phone number...",
                                                    keyboard:
                                                        TextInputType.phone,
                                                    isRequired: true,
                                                    value: formCtrl
                                                            .form['developer']
                                                        ['phone'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['developer'];
                                                      formCtrl.setFormField(
                                                          'developer', {
                                                        ...owner,
                                                        'phone': val
                                                      });
                                                    },
                                                  ),
                                                  TuFormField(
                                                    label: "Developer email:",
                                                    hasBorder: false,
                                                    hint:
                                                        "Enter developer email number...",
                                                    keyboard: TextInputType
                                                        .emailAddress,
                                                    isRequired: true,
                                                    value: formCtrl
                                                            .form['developer']
                                                        ['email'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['developer'];
                                                      formCtrl.setFormField(
                                                          'developer', {
                                                        ...owner,
                                                        'email': val
                                                      });
                                                    },
                                                  ),
                                                  mY(10),
                                                  TuFormField(
                                                    label: "Developer website:",
                                                    hasBorder: false,
                                                    hint:
                                                        "Enter developer website...",
                                                    keyboard: TextInputType.url,
                                                    isRequired: true,
                                                    value: formCtrl
                                                            .form['developer']
                                                        ['site'],
                                                    onChanged: (val) {
                                                      Map owner = formCtrl
                                                          .form['developer'];
                                                      formCtrl.setFormField(
                                                          'developer', {
                                                        ...owner,
                                                        'site': val
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
                            style: Styles.label(isBold: true),
                          ),
                          Obx(
                            () => Text(
                              appCtrl.developer['name'],
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
                              appCtrl.developer['phone'],
                              style: Styles.label(isLight: true),
                            ),
                          )),
                      tuTableRow(
                          Text(
                            "Email:",
                            style: Styles.label(isBold: true),
                          ),
                          Obx(
                            () => SizedBox(
                              width: 100,
                              child: SelectableText(
                                appCtrl.developer['email'],
                                maxLines: 1,
                                style: Styles.label(isLight: true),
                              ),
                            ),
                          )),
                      tuTableRow(
                          Text(
                            "Website:",
                            style: Styles.label(isBold: true),
                          ),
                          Obx(
                            () => SizedBox(
                              width: 100,
                              child: SelectableText(
                                appCtrl.developer['site'],
                                maxLines: 1,
                                style: Styles.label(isLight: true),
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
                              style: Styles.h2(),
                            ),
                            Obx(
                              () => appCtrl.user.isEmpty
                                  ? none()
                                  : Visibility(
                                      visible: appCtrl.user['permissions'] > 0,
                                      child: InkWell(
                                        onTap: () {
                                          formCtrl.setForm({});
                                          TuFuncs.showBottomSheet(
                                              context: context,
                                              widget: const AddStoreView());
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
