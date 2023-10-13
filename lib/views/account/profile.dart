// ignore_for_file: use_build_context_synchronously
import 'package:lebzcafe/widgets/tu/form_field.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/auth/verify_email.dart';
import 'package:lebzcafe/views/map.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../widgets/common.dart';
import '../../widgets/form_view.dart';
import '../order/index.dart';

class ProfilePage extends StatefulWidget {
  final String? id;
  const ProfilePage({super.key, this.id});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _account;
  final _appCtrl = MainApp.appCtrl;

  _getAccount() async {
    try {
      setState(() {
        _account = null;
      });
      final res =
          await apiDio().get("/users?id=${widget.id ?? _appCtrl.user['_id']}");
      setState(() {
        _account = res.data['users'][0];
      });
    } catch (e) {
      clog(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppCtrl appCtrl = Get.find();
    final FormViewCtrl formCtrl = Get.find();
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
              setState(() {
                _account = res.data["user"];
              });
              if (_account!['_id'] == appCtrl.user['_id']) {
                appCtrl.setUser(_account!);
              }
              // Navigator.pop(context);
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

    void onEditPermissionsClick() {
      formCtrl.setForm({'permissions': _account!['permissions']});
      TuFuncs.showBottomSheet(
          context: context,
          widget: Container(
            color: cardBGLight,
            padding: defaultPadding,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Permissions",
                    style: Styles.h3(),
                  ),
                  mY(7),
                  Obx(
                    () => Wrap(
                      spacing: 10,
                      children: [
                        TuLabeledCheckbox(
                          onChanged: (val) {},
                          label: 'READ',
                          value: formCtrl.form['permissions'] >= 0,
                          radius: 100,
                        ),
                        TuLabeledCheckbox(
                          onChanged: (val) {
                            var perms = val == true ? 1 : 0;
                            formCtrl.setFormField('permissions', perms);
                          },
                          label: 'WRITE',
                          value: formCtrl.form['permissions'] >= 1,
                          radius: 100,
                        ),
                        TuLabeledCheckbox(
                          onChanged: (val) {
                            var perms = val == true ? 2 : 1;
                            formCtrl.setFormField('permissions', perms);
                          },
                          label: 'DELETE',
                          value: formCtrl.form['permissions'] >= 2,
                          radius: 100,
                        ),
                      ],
                    ),
                  ),
                  mY(5),
                  TuButton(
                    text: "Save changes",
                    width: double.infinity,
                    bgColor: Colors.black87,
                    onPressed: () async {
                      try {
                        final res = await apiDio().post("/user/edit", data: {
                          'userId': _account!['_id'],
                          'value': {
                            'permissions': formCtrl.form['permissions'],
                          },
                        });
                        setState(() {
                          _account = res.data['user'];
                        });
                        if (_account!['_id'] == appCtrl.user['_id']) {
                          appCtrl.setUser(_account!);
                        }
                        Navigator.pop(context);
                      } catch (error) {
                        errorHandler(e: error, context: context);
                      }
                    },
                  )
                ]),
          ));
    }

    void onEditDetailsBtnClick() {
      final FormViewCtrl ctrl = Get.find();
      ctrl.setForm({
        "first_name": _account!['first_name'],
        "last_name": _account!['last_name'],
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
                  required: true,
                  value: form["first_name"],
                  onChanged: (val) {
                    formCtrl.setFormField("first_name", val);
                  },
                ),
                TuFormField(
                  label: "Last name:",
                  hint: "e.g. Doe",
                  radius: 5,
                  hasBorder: false,
                  required: true,
                  value: form["last_name"],
                  onChanged: (val) {
                    formCtrl.setFormField("last_name", val);
                  },
                ),
              ],
              onSubmit: () async {
                try {
                  final res = await apiDio().post("/user/edit", data: {
                    'value': form,
                  });
                  setState(() {
                    _account = res.data['user'];
                  });
                  if (_account!['_id'] == appCtrl.user['_id']) {
                    appCtrl.setUser(_account!);
                  }
                  Navigator.pop(context);
                } catch (e) {
                  //
                  clog(e.runtimeType);
                  if (e.runtimeType == DioException) {
                    e as DioException;
                    handleDioException(context: context, exception: e);
                  } else {
                    clog(e);
                    showToast("Something went wrong!", isErr: true)
                        .show(context);
                  }
                }
              }));
    }

    return _account == null
        ? const Scaffold()
        : Scaffold(
            appBar: childAppbar(
                title: "${_account!['first_name']} ${_account!['last_name']}",
                showCart: false),
            body: SizedBox(
              height: screenSize(context).height -
                  appBarH -
                  statusBarH(),
              child: SingleChildScrollView(
                child: Container(
                  padding: defaultPadding,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  color: cardBGLight,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        tuTableRow(
                                            Text(
                                              "Full name",
                                              style: Styles.h4(
                                                  isLight: true,
                                                  color: TuColors.text),
                                            ),
                                            TextButton(
                                                onPressed:
                                                    onEditDetailsBtnClick,
                                                child: const Text('Edit')),
                                            my: 0),
                                        mY(8),
                                        Text(
                                          "${_account!['first_name']} ${_account!['last_name']}",
                                          style: Styles.h5(
                                              isLight: true,
                                              color: TuColors.text2),
                                        ),
                                      ])),
                              mY(2.5),
                              Container(
                                  color: cardBGLight,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          //id=contact-details
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Email",
                                              style: Styles.h4(
                                                  isLight: true,
                                                  color: TuColors.text),
                                            ),
                                            mY(8),
                                            SelectableText(
                                              "${_account!['email']}",
                                              maxLines: 1,
                                              style: Styles.h5(isLight: true),
                                            ),
                                            Visibility(
                                                visible: !_account![
                                                    'email_verified'],
                                                child: tuTableRow(
                                                    const Text(''),
                                                    InkWell(
                                                      onTap: () async {
                                                        try {
                                                          formCtrl.setForm({
                                                            'email': _account![
                                                                'email']
                                                          });
                                                          // Generate OTP for email
                                                          await apiDio().post(
                                                              '/auth/verify-email',
                                                              data: {
                                                                'email': formCtrl
                                                                        .form[
                                                                    'email'],
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
                                                            color:
                                                                Colors.orange,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                    my: 7)),
                                            mY(8),
                                            Text(
                                              "Phone",
                                              style: Styles.h4(
                                                  isLight: true,
                                                  color: TuColors.text),
                                            ),
                                            mY(8),
                                            SelectableText(
                                              "${_account!['phone']}",
                                              style: Styles.h5(isLight: true),
                                            ),
                                          ],
                                        ),
                                      ])),
                              mY(2.5),
                              Container(
                                  color: cardBGLight,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        tuTableRow(
                                            Text(
                                              "Residential Address",
                                              style: Styles.h4(
                                                  isLight: true,
                                                  color: TuColors.text),
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  formCtrl.setForm(
                                                      _account!['address']);
                                                  addEditAddress(
                                                      title: "Edit address");
                                                },
                                                child: const Text('Edit')),
                                            my: 0),
                                        mY(8),
                                        Builder(builder: (context) {
                                          final address = _account!["address"];
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
                                                      "${_account!['address']['location']['name']}",
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    )
                                                  ],
                                                );
                                        })
                                      ])),
                              mY(2.5),
                              Container(
                                color: cardBGLight,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                child: tuColumn(
                                  children: [
                                    tuTableRow(
                                        Text(
                                          "Permissions",
                                          style: Styles.h4(
                                              isLight: true,
                                              color: TuColors.text),
                                        ),
                                        TextButton(
                                            onPressed: onEditPermissionsClick,
                                            child: const Text('Edit')),
                                        my: 0),
                                    mY(8),
                                    Wrap(
                                      spacing: 10,
                                      children: [
                                        TuLabeledCheckbox(
                                          onChanged: (val) {},
                                          label: 'READ',
                                          value: _account!['permissions'] >= 0,
                                          radius: 100,
                                        ),
                                        TuLabeledCheckbox(
                                          onChanged: (val) {},
                                          label: 'WRITE',
                                          value: _account!['permissions'] >= 1,
                                          radius: 100,
                                        ),
                                        TuLabeledCheckbox(
                                          onChanged: (val) {},
                                          label: 'DELETE',
                                          value: _account!['permissions'] >= 2,
                                          radius: 100,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ])
                      ]),
                ),
              ),
            ));
  }
}
