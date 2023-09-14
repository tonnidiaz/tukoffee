// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/form_view.dart';
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
      onSubmit: () async {
        try {
          final phone = formCtrl.form['phone'];
          await apiDio()
              .post('/auth/password/reset?act=gen-otp', data: {'phone': phone});

          pushTo(context, const Step2());
          formCtrl.setFormField('phone', phone);
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        const Text(
          "Enter the mobile number you used to register your account.",
          textAlign: TextAlign.center,
        ),
        mY(5),
        Obx(() => TuFormField(
              label: "Mobile Number:",
              hint: "e.g. 0712345678",
              value: formCtrl.form['phone'],
              hasBorder: false,
              isRequired: true,
              isLegacy: true,
              radius: 5,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Mobile Number is required";
                } else if (val.length != 12 && val.length != 10) {
                  return "Enter a valid mobile number";
                }

                return null;
              },
              keyboard: TextInputType.phone,
              onChanged: (val) {
                formCtrl.setFormField('phone', val);
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
      onSubmit: () async {
        try {
          final form = formCtrl.form;
          clog(form);
          await apiDio()
              .post('/auth/password/reset?act=verify-otp', data: formCtrl.form);
          pushTo(context, const Step3());
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        Obx(() => Text(
              "Enter the 4 digit pin sent to ${formCtrl.form['phone']}",
              textAlign: TextAlign.center,
            )),
        Obx(() => TuFormField(
              radius: 7,
              my: 0,
              textAlign: TextAlign.center,
              labelAlignment: FloatingLabelAlignment.center,
              hint: "* * * * ",
              value: formCtrl.form['otp'],
              keyboard: TextInputType.number,
              hasBorder: false,
              maxLength: 4,
              isRequired: true,
              onChanged: (val) {
                formCtrl.setFormField('otp', val);
              },
            )),
        TuInkwell(
          onTap: _secs > 0
              ? null
              : () async {
                  try {
                    _setSecs(60);
                    await apiDio().post('/auth/password/reset?act=gen-otp',
                        data: {'phone': formCtrl.form['phone']});
                    _initTimer();
                  } catch (e) {
                    errorHandler(
                        e: e, context: context, msg: 'Failed to request OTP');
                    _setSecs(0);
                  }
                },
          child: Text(
            _secs > 0 ? "Resend PIN in: $_secs" : "Resend PIN",
            style: TextStyle(color: _secs > 0 ? Colors.black45 : Colors.orange),
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
          await apiDio()
              .post('/auth/password/reset?act=reset', data: {...formCtrl.form});
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          pushNamed(context, '/auth/login');
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      fields: [
        const Text(
          "Create new password",
          textAlign: TextAlign.center,
        ),
        mY(5),
        Obx(() => TuFormField(
              label: "Password:",
              hint: "Enter new password...",
              isPass: true,
              showEye: false,
              value: formCtrl.form['password'],
              isRequired: true,
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
              isRequired: true,
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
