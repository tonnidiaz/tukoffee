// ignore_for_file: use_build_context_synchronously
import 'package:frust/widgets/tu/form_field.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:get/get.dart';

class SignupCtrl extends GetxController {
  RxMap<String, dynamic> user = <String, dynamic>{"phone": '0726013383'}.obs;

  RxString title = "Create an account".obs;
  set setuser(Map<String, dynamic> val) {
    user.value = val;
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return const Step1();
  }
}

class Step1 extends StatelessWidget {
  const Step1({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SignupCtrl>();
    return CreateAccountPageWrapper(
      onSubmit: () async {
        clog(ctrl.user);
        try {
          final res = await apiDio().post('/auth/login', data: ctrl.user);
          if (res.data['user'] != null) {
            // User already exists and password is correct
            appBox!.put("authToken", res.data["token"]);
            setupUser();
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else {
            // Proceed to next step
            clog(res.data);
            pushTo(context, const Step2());
          }
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      btnTxt: "Next",
      fields: [
        Obx(() => TuFormField(
              label: "Mobile Number:",
              hint: "e.g. +2771245678",
              keyboard: TextInputType.phone,
              required: true,
              hasBorder: false,
              value: ctrl.user["phone"],
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Mobile Number is required";
                } else if (val.length != 12 && val.length != 10) {
                  return "Enter a valid mobile number";
                }

                return null;
              },
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, "phone": val};
              },
            )),
        Obx(() => TuFormField(
              label: "Password:",
              hint: "More than 6 characters...",
              required: true,
              hasBorder: false,
              value: ctrl.user["password"],
              isPass: true,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Password is required";
                } else if (val.length < 6) {
                  return "Must be 6 or more characters long";
                }

                return null;
              },
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, "password": val};
              },
            )),
        InkWell(
          onTap: () {
            pushNamed(context, '/auth/resetPass');
          },
          child: const Text("Forgot password?"),
        )
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
    final ctrl = Get.find<SignupCtrl>();
    return CreateAccountPageWrapper(
      onSubmit: () async {
        try {
          await apiDio().post('/auth/otp/verify',
              data: {'phone': ctrl.user['phone'], 'otp': ctrl.user['otp']});

          pushTo(context, const Step3());
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      btnTxt: "Verify",
      title: "Verify number",
      fields: [
        mY(5),
        Obx(() => Text(
              "Enter the 4 digit pin sent to ${ctrl.user['phone']}",
              textAlign: TextAlign.center,
            )),
        Obx(() => TuFormField(
              my: 0,
              textAlign: TextAlign.center,
              labelAlignment: FloatingLabelAlignment.center,
              hint: "* * * * ",
              height: 14,

              ///label: "OTP:",
              value: ctrl.user['otp'],
              keyboard: TextInputType.number,
              hasBorder: false,
              maxLength: 4,
              required: true,
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, 'otp': val};
              },
            )),
        InkWell(
          onTap: _secs > 0
              ? null
              : () async {
                  try {
                    await apiDio().post('/auth/otp/resend',
                        data: {'phone': ctrl.user['phone']});
                    _setSecs(60);
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
    final ctrl = Get.find<SignupCtrl>();
    return CreateAccountPageWrapper(
      btnTxt: "Sign up",
      onSubmit: () async {
        try {
          final res = await apiDio().post("/auth/signup", data: ctrl.user);
          clog(res.data);
          appBox!.put("authToken", res.data["token"]);
          setupUser();
          await Navigator.pushNamed(context, '/');
          Navigator.pushNamedAndRemoveUntil(
              context, '/account/profile', (route) => false);
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      },
      title: "Finish up",
      fields: [
        Obx(() => TuFormField(
              label: "First name:",
              hint: "e.g. John",
              keyboard: TextInputType.name,
              required: true,
              value: ctrl.user['first_name'],
              hasBorder: false,
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, "first_name": val};
              },
            )),
        Obx(() => TuFormField(
              label: "Last name:",
              keyboard: TextInputType.name,
              hint: "e.g. Doe",
              required: true,
              hasBorder: false,
              value: ctrl.user['last_name'],
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, "last_name": val};
              },
            )),
        TuFormField(
          label: "Email:",
          hint: "e.g. johndoe@gmail.com",
          required: true,
          hasBorder: false,
          value: ctrl.user['email'],
          keyboard: TextInputType.emailAddress,
          onChanged: (val) {
            ctrl.setuser = {...ctrl.user, "email": val};
          },
        ),
      ],
    );
  }
}

class CreateAccountPageWrapper extends StatefulWidget {
  final List<Widget> fields;
  final String btnTxt;
  final String title;
  final Function() onSubmit;

  const CreateAccountPageWrapper(
      {super.key,
      this.fields = const [],
      required this.onSubmit,
      this.btnTxt = "Submit",
      this.title = "TuKoffee auth"});

  @override
  State<CreateAccountPageWrapper> createState() =>
      _CreateAccountPageWrapperState();
}

class _CreateAccountPageWrapperState extends State<CreateAccountPageWrapper> {
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(title: "Login/Sign up", showCart: false),
      child: Container(
          padding: const EdgeInsets.all(14),
          height: screenSize(context).height -
              (appBarH + statusBarH(context: context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              mY(screenSize(context).height / 30),
              Text(
                widget.title,
                style: Styles.h1,
              ),
              mY(5),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.fields,
                  )),
              mY(10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TuButton(
                      text: widget.btnTxt,
                      onPressed: () async {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          await widget.onSubmit();
                        }
                      }),
                ],
              ),
            ],
          )),
    );
  }
}
