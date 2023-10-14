// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/widgets/dialogs/loading_dialog.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:lebzcafe/widgets/tu/form.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../widgets/common.dart';
import '../../widgets/form_view.dart';
import '../order/index.dart';

class ChangeEmailSheet extends StatefulWidget {
  const ChangeEmailSheet({super.key});

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  int _step = 0;
  _setStep(int val) {
    setState(() {
      _step = val;
    });
  }

  final _formCtrl = MainApp.formViewCtrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: defaultPadding2,
        margin: EdgeInsets.only(bottom: keyboardPadding(context)),
        color: cardBGLight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            h3('Change email address', isLight: true),
            mY(5),
            _step == 0
                ? TuForm(
                    builder: (key) => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(
                              () => TuFormField(
                                keyboard: TextInputType.emailAddress,
                                required: true,
                                label: 'New email:',
                                hint: 'Enter your new email address...',
                                value: _formCtrl.form['email'],
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Email is required";
                                  } else if (!val.isEmail) {
                                    return "Enter a valid email address";
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  _formCtrl.setFormField('email', val);
                                },
                              ),
                            ),
                            Obx(
                              () => TuFormField(
                                keyboard: TextInputType.emailAddress,
                                required: true,
                                label: 'Password:',
                                isPass: true,
                                hint: 'Enter your current password...',
                                value: _formCtrl.form['password'],
                                onChanged: (val) {
                                  _formCtrl.setFormField('password', val);
                                },
                              ),
                            ),
                            mY(4),
                            TuButton(
                              text: "Next",
                              width: double.infinity,
                              onPressed: () async {
                                if (!key.currentState!.validate()) return;
                                clog('SHow loading');
                                //showLoading(context);
                                showProgressSheet();
                                try {
                                  await apiDio().post('/user/edit?field=email',
                                      data: {'data': _formCtrl.form});
                                  _setStep(1);
                                } catch (e) {
                                  Get.back();
                                  errorHandler(e: e, context: context);
                                }
                              },
                            )
                          ],
                        ))
                : TuForm(
                    builder: (key) => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            mY(5),
                            SizedBox(
                              width: screenSize(context).width,
                              child: Column(
                                children: [
                                  const Text("Enter the 4 digit pin sent to:"),
                                  Obx(() => Text(
                                        "${_formCtrl.form['email']}",
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: TuColors.primary),
                                      )),
                                ],
                              ),
                            ),
                            mY(10),
                            Obx(
                              () => TuFormField(
                                my: 0,
                                textAlign: TextAlign.center,
                                labelAlignment: FloatingLabelAlignment.center,
                                hint: "* * * * ",
                                height: 14,

                                ///label: "OTP:",
                                value: _formCtrl.form['otp'],
                                keyboard: TextInputType.number,

                                maxLength: 4,
                                required: true,
                                onChanged: (val) {
                                  _formCtrl.setFormField('otp', val);
                                },
                              ),
                            ),
                            mY(4),
                            const TuButton(
                              text: "Next",
                              width: double.infinity,
                            )
                          ],
                        ))
          ],
        ),
      ),
    );
  }
}

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppCtrl appCtrl = Get.find();
    final FormViewCtrl formCtrl = Get.find();

    void onChangeEmailClick() {
      formCtrl.clear();
      Get.bottomSheet(const ChangeEmailSheet());
    }

    return Scaffold(
        appBar: childAppbar(title: "Account settings", showCart: false),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
                top: topMargin / 2, left: topMargin, right: topMargin),
            height: screenSize(context).height,
            child: Column(children: [
              TuCard(
                  my: topMargin / 2,
                  width: double.infinity,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tuTableRow(
                            Text(
                              "Email",
                              style: Styles.h4(),
                            ),
                            TextButton(
                                onPressed: onChangeEmailClick,
                                child: const Text('Change'))),
                        mY(4),
                        Text("${appCtrl.user['email']}"),
                      ])),
              TuCard(
                my: topMargin / 2,
                child: TuButton(
                    bgColor: Colors.black,
                    onPressed: () {
                      // show edit pass dialog
                      showDialog(
                          useRootNavigator: false,
                          context: context,
                          builder: (context) {
                            return const EditPassForm();
                          });
                    },
                    text: "Change password"),
              ),
              TuCard(
                  my: topMargin / 2,
                  child: TuButton(
                      onPressed: () {
                        // confirm password -> delete paddword
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return ConfirmPassForm(
                                url: "/user/delete",
                                onOk: () async {
                                  // logout
                                  logout();
                                  pushNamed('/');
                                },
                              );
                            });
                      },
                      bgColor: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_amber_outlined,
                            size: 20,
                          ),
                          mX(6),
                          const Text("Delete Account"),
                        ],
                      ))),
            ]),
          ),
        ));
  }
}

class ConfirmPassForm extends StatelessWidget {
  final Function()? onOk;
  final String url;
  const ConfirmPassForm(
      {super.key, this.onOk, this.url = "/auth/password/verify"});

  @override
  Widget build(BuildContext context) {
    return TuDialogView(
      onOk: () async {
        try {
          await apiDio().post(url, data: {
            'password': MainApp.formViewCtrl.form['password'],
          });
          if (onOk != null) {
            onOk!();
          }
        } catch (e) {
          clog(e);
          if (e.runtimeType == DioException) {
            e as DioException;
            handleDioException(
                context: context,
                exception: e,
                msg: "Failed to verify password");
          } else {
            clog(e);
            showToast("Failed to verify password", isErr: true).show(context);
          }
        }
      },
      title: "Confirm password",
      isForm: true,
      fields: [
        Obx(() => TuFormField(
              label: "Password",
              isPass: true,
              hasBorder: false,
              isLegacy: true,
              hint: "Enter your password...",
              required: true,
              value: MainApp.formViewCtrl.form['password'],
              onChanged: (val) {
                MainApp.formViewCtrl.setFormField('password', val);
              },
            ))
      ],
    );
  }
}

class EditPassForm extends StatelessWidget {
  const EditPassForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = MainApp.formViewCtrl;
    return TuDialogView(
      title: "Change password",
      isForm: true,
      onOk: () async {
        //Validate old password
        //If old password is valid -> change the password for the user
        try {
          await apiDio().post("/auth/password/change", data: {
            'old': ctrl.form['old'],
            'new': ctrl.form['new'],
          });
          MainApp.appCtrl
              .setUser({...MainApp.appCtrl.user, 'password': ctrl.form['new']});
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 10));
          showToast("Password changed successfully!").show(context);
        } catch (e) {
          if (e.runtimeType == DioException) {
            e as DioException;
            handleDioException(
                context: context,
                exception: e,
                msg: "Failed to change password!");
          } else {
            clog(e);
            showToast("Failed to change password", isErr: true).show(context);
          }
        }
      },
      fields: [
        Obx(() => TuFormField(
              label: "Old password:",
              hint: "Enter old password...",
              isPass: true,
              required: true,
              hasBorder: false,
              value: ctrl.form['old'],
              onChanged: (val) {
                ctrl.setFormField('old', val);
              },
            )),
        Obx(() => TuFormField(
              label: "New password:",
              hint: "Enter your new password...",
              isPass: true,
              required: true,
              hasBorder: false,
              value: ctrl.form['new'],
              onChanged: (val) {
                ctrl.setFormField('new', val);
              },
            )),
      ],
    );
  }
}
