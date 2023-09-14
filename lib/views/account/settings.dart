// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/dialog.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../widgets/common.dart';
import '../../widgets/form_view.dart';
import '../order/index.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fprmViewCtrl = MainApp.formViewCtrl;
    final AppCtrl appCtrl = Get.find();
    final FormViewCtrl formViewCtrl = Get.find();

    return Scaffold(
        appBar: childAppbar(),
        body: SingleChildScrollView(
          child: Container(
            padding: defaultPadding2,
            height: screenSize(context).height,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Account settings", style: Styles.h1),
              mY(5),
              Expanded(
                child: Column(children: [
                  TuCard(
                      my: 5,
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => TuFormField(
                                  label: "Password",
                                  isPass: true,
                                  hasBorder: true,
                                  isLegacy: false,
                                  readOnly: true,
                                  onChanged: (val) {
                                    formViewCtrl.setFormField('password', val);
                                  },
                                  value: appCtrl.user['password'],
                                  onShowHidePass: (setShowPass) async {
                                    //Show confirm pass dialog
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return ConfirmPassForm(
                                            onOk: () async {
                                              MainApp.appCtrl.setUser({
                                                ...MainApp.appCtrl.user,
                                                'password': formViewCtrl
                                                    .form['password']
                                              });
                                              Navigator.pop(context);
                                              setShowPass(true);
                                            },
                                          );
                                        });
                                  },
                                )),
                            TuButton(
                                onPressed: () {
                                  // show edit pass dialog
                                  showDialog(
                                      useRootNavigator: false,
                                      context: context,
                                      builder: (context) {
                                        return const EditPassForm();
                                      });
                                },
                                child: const Text("Change password")),
                            mY(5),
                            TuButton(
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
                                            pushNamed(context, '/');
                                          },
                                        );
                                      });
                                },
                                bgColor: Colors.red,
                                child: iconText("Delete Account", Icons.delete))
                          ])),
                ]),
              )
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
              isRequired: true,
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
              isRequired: true,
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
              isRequired: true,
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
