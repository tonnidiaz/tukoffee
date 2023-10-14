// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/form_view.dart';
import 'package:get/get.dart';

class ResetPassPage extends StatelessWidget {
  const ResetPassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Step1();
  }
}

class Step1 extends StatelessWidget {
  const Step1({super.key});

  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formViewCtrl;

    return FormView(
      title: "Reset Password",
      useBottomSheet: true,
      btnTxt: "Next",
      onSubmit: () async {
        try {
          final email = formCtrl.form['email'];
          showProgressSheet();
          await apiDio()
              .post('/auth/password/reset?act=gen-otp', data: {'email': email});
          Get.back();
          pushTo(const Step2());
          formCtrl.setFormField('email', email);
        } catch (e) {
          Get.back();
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        Obx(() => TuFormField(
              label: "Email:",
              hint: "Enter your email address..",
              value: formCtrl.form['email'],
              required: true,
              radius: 5,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Field is required";
                } else if (!val.isEmail) {
                  return "Enter a valid email address";
                }

                return null;
              },
              keyboard: TextInputType.emailAddress,
              onChanged: (val) {
                formCtrl.setFormField('email', val);
              },
            ))
      ],
    );
  }
}

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  final formCtrl = MainApp.formViewCtrl;
  late Timer timer;
  int _secs = 60;
  _setSecs(int val) {
    setState(() {
      _secs = val;
    });
  }

  _onTimerChange(Timer timer) {
    if (_secs > 0) {
      _setSecs(_secs - 1);
    } else {
      timer.cancel();
    }
  }

  _initTimer() {
    _setSecs(60);
    timer = Timer.periodic(const Duration(seconds: 1), _onTimerChange);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FormView(
      title: "Reset Password",
      useBottomSheet: true,
      btnTxt: "VERIFY",
      onSubmit: () async {
        try {
          final form = formCtrl.form;
          showProgressSheet();
          await apiDio()
              .post('/auth/password/reset?act=verify-otp', data: formCtrl.form);

          gpop();
          pushTo(const Step3());
        } catch (e) {
          gpop();
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        SizedBox(
          width: screenSize(context).width,
          child: Column(
            children: [
              const Text("Enter the 4 digit code sent to:"),
              Obx(() => Text(
                    " ${formCtrl.form['email']}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TuColors.primary),
                  )),
            ],
          ),
        ),
        mY(10),
        Obx(() => TuFormField(
              textAlign: TextAlign.center,
              labelAlignment: FloatingLabelAlignment.center,
              hint: "* * * * ",
              height: 16,
              value: formCtrl.form['otp'],
              keyboard: TextInputType.number,
              maxLength: 4,
              required: true,
              onChanged: (val) {
                formCtrl.setFormField('otp', val);
              },
            )),
        InkWell(
          onTap: _secs > 0
              ? null
              : () async {
                  try {
                    showProgressSheet();
                    await apiDio().post('/auth/otp/resend',
                        data: {'email': formCtrl.form['email']});
                    _setSecs(60);
                    _initTimer();
                    gpop();
                  } catch (e) {
                    gpop();
                    errorHandler(
                        e: e, context: context, msg: 'Failed to request OTP');
                    _setSecs(0);
                  }
                },
          child: Text(
            _secs > 0 ? "Resend PIN in: $_secs" : "Resend PIN",
            style:
                TextStyle(color: _secs > 0 ? Colors.black45 : TuColors.primary),
          ),
        )
      ],
    );
  }
}

class Step3 extends StatelessWidget {
  const Step3({super.key});

  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formViewCtrl;

    return FormView(
      title: "Reset Password",
      useBottomSheet: true,
      onSubmit: () async {
        try {
          showProgressSheet();
          await apiDio()
              .post('/auth/password/reset?act=reset', data: {...formCtrl.form});
          gpop();
          Get.offAllNamed("/");
          pushNamed('/auth/login');
        } catch (e) {
          gpop();
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        SizedBox(
          width: screenSize(context).width,
          child: Text(
            "Create new password",
            textAlign: TextAlign.center,
            style: Styles.h4(isLight: true),
          ),
        ),
        mY(5),
        Obx(() => TuFormField(
              label: "Password:",
              hint: "Enter new password...",
              isPass: true,
              showEye: false,
              value: formCtrl.form['password'],
              required: true,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Field is required.";
                } else if (val.length < 6) {
                  return "Must be 6 or more characters";
                }

                return null;
              },
              keyboard: TextInputType.phone,
              onChanged: (val) {
                formCtrl.setFormField('password', val);
              },
            )),
        Obx(() => TuFormField(
              label: "Comfirm Password:",
              hint: "Confirm your password...",
              isPass: true,
              value: formCtrl.form['cpassword'],
              required: true,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Field is required.";
                } else if (val != formCtrl.form['password']) {
                  return "Passwords do not match!";
                }

                return null;
              },
              keyboard: TextInputType.phone,
              onChanged: (val) {
                formCtrl.setFormField('cpassword', val);
              },
            )),
      ],
    );
  }
}

class ResetPassPageWrapper extends StatelessWidget {
  final List<Widget> children;
  const ResetPassPageWrapper({super.key, this.children = const []});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(showCart: false),
      child: Container(
        padding: defaultPadding2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mY(screenSize(context).height / 20),
            Text(
              "Reset password",
              style: Styles.h1,
            ),
            mY(5),
            ...children
          ],
        ),
      ),
    );
  }
}
