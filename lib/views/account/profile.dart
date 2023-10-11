// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/auth/verify_email.dart';
import 'package:frust/views/map.dart';
import 'package:frust/widgets/common2.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../widgets/common.dart';
import '../../widgets/form_view.dart';
import '../order/index.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppCtrl appCtrl = Get.find();
    final FormViewCtrl formViewCtrl = Get.find();
    addEditAddress({String? title}) async {
      TuFuncs.showBottomSheet(
          context: context,
          widget: MapPage(onSubmit: (val) async {
            if (val.isEmpty) return;
            try {
              //showToast("Adding address...").show(context);
              final res =
                  await apiDio().post("/user/edit?field=address", data: {
                "value": {'location': val}
              });
              appCtrl.setUser(res.data["user"]);
              Navigator.pop(context);
            } catch (e) {
              clog(e);
              if (e.runtimeType == DioException) {
                handleDioException(
                    context: context,
                    exception: e as DioException,
                    msg: "Error adding addess!");
              } else {
                showToast("Error adding address", isErr: true).show(context);
              }
            }
          }));
    }

    return Scaffold(
        appBar: childAppbar(title: "Profile"),
        body: SingleChildScrollView(
          child: Container(
            padding: defaultPadding2,
            height: screenSize(context).height,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              mY(5),
              Expanded(
                child: Column(children: [
                  TuCard(
                      my: 5,
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tuTableRow(
                                Text(
                                  "Personal details",
                                  style: Styles.h2(),
                                ),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      final FormViewCtrl ctrl = Get.find();
                                      ctrl.setForm({
                                        "first_name":
                                            appCtrl.user['first_name'],
                                        "last_name": appCtrl.user['last_name'],
                                      });
                                      final form = ctrl.form;
                                      pushTo(
                                          context,
                                          FormView(
                                              title: "Edit personal details",
                                              fields: [
                                                TuFormField(
                                                  label: "First name:",
                                                  hint: "e.g. John",
                                                  radius: 5,
                                                  hasBorder: false,
                                                  isRequired: true,
                                                  value: form["first_name"],
                                                  onChanged: (val) {
                                                    formViewCtrl.setFormField(
                                                        "first_name", val);
                                                  },
                                                ),
                                                TuFormField(
                                                  label: "Last name:",
                                                  hint: "e.g. Doe",
                                                  radius: 5,
                                                  hasBorder: false,
                                                  isRequired: true,
                                                  value: form["last_name"],
                                                  onChanged: (val) {
                                                    formViewCtrl.setFormField(
                                                        "last_name", val);
                                                  },
                                                ),
                                              ],
                                              onSubmit: () async {
                                                try {
                                                  final res = await apiDio()
                                                      .post("/user/edit",
                                                          data: {
                                                        'value': form,
                                                      });
                                                  appCtrl.setUser(
                                                      res.data['user']);
                                                  Navigator.pop(context);
                                                } catch (e) {
                                                  //
                                                  clog(e.runtimeType);
                                                  if (e.runtimeType ==
                                                      DioException) {
                                                    e as DioException;
                                                    handleDioException(
                                                        context: context,
                                                        exception: e);
                                                  } else {
                                                    clog(e);
                                                    showToast(
                                                            "Something went wrong!",
                                                            isErr: true)
                                                        .show(context);
                                                  }
                                                }
                                              }));
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                    )),
                                my: 0),
                            Obx(
                              () => Column(
                                //id=personal-details
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  tuTableRow(
                                    Text(
                                      "First name:",
                                      style: Styles.h3(),
                                    ),
                                    Text(
                                      "${appCtrl.user['first_name']}",
                                      style: Styles.h3(isLight: true),
                                    ),
                                  ),
                                  tuTableRow(
                                    Text(
                                      "Last name:",
                                      style: Styles.h3(),
                                    ),
                                    Text(
                                      "${appCtrl.user['last_name']}",
                                      style: Styles.h3(isLight: true),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ])),
                  TuCard(
                      my: 5,
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tuTableRow(
                                Text(
                                  "Contact details",
                                  style: Styles.h2(),
                                ),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                    )),
                                my: 0),
                            Obx(
                              () => Column(
                                //id=contact-details
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  tuTableRow(
                                    Text(
                                      "Email:",
                                      style: Styles.h3(),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: SelectableText(
                                        "${appCtrl.user['email']}",
                                        maxLines: 1,
                                        style: Styles.h3(isLight: true),
                                      ),
                                    ),
                                  ),
                                  Obx(() => Visibility(
                                      visible: !appCtrl.user['email_verified'],
                                      child: tuTableRow(
                                        const Text(''),
                                        InkWell(
                                          onTap: () async {
                                            try {
                                              formViewCtrl.setForm({
                                                'email': appCtrl.user['email']
                                              });
                                              // Generate OTP for email
                                              await apiDio().post(
                                                  '/auth/verify-email',
                                                  data: {
                                                    'email': formViewCtrl
                                                        .form['email'],
                                                  });
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (c) =>
                                                      const VerifyEmailView());
                                            } catch (e) {
                                              errorHandler(
                                                  e: e,
                                                  context: context,
                                                  msg:
                                                      "Failed to make request");
                                            }
                                          },
                                          child: const Text(
                                            "Verify email",
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ))),
                                  tuTableRow(
                                    Text(
                                      "Phone:",
                                      style: Styles.h3(),
                                    ),
                                    SelectableText(
                                      "${appCtrl.user['phone']}",
                                      style: Styles.h3(isLight: true),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ])),
                  TuCard(
                      my: 5,
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tuTableRow(
                                Text(
                                  "Residential Address",
                                  style: Styles.h2(),
                                ),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      formViewCtrl
                                          .setForm(appCtrl.user['address']);
                                      addEditAddress(title: "Edit address");
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                    )),
                                my: 0),
                            Obx(() {
                              final address = appCtrl.user["address"];
                              return address == null
                                  ? Center(
                                      child: SizedBox(
                                      width: double.infinity,
                                      height: 70,
                                      child: InkWell(
                                        onTap: () {
                                          addEditAddress();
                                        },
                                        child: const Card(
                                            elevation: .5,
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.black87,
                                              // size: 50,
                                            )),
                                      ),
                                    ))
                                  : Column(
                                      //id=address-details
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${appCtrl.user['address']['location']['name']}")
                                      ],
                                    );
                            })
                          ])),
                ]),
              )
            ]),
          ),
        ));
  }
}
