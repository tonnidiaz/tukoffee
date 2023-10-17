// ignore_for_file: use_build_context_synchronously
import 'package:google_fonts/google_fonts.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/vars.dart';
import 'package:lebzcafe/views/account/profile.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:get/get.dart';

class SignupCtrl extends GetxController {
  RxMap<String, dynamic> user = <String, dynamic>{}.obs;

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
        try {
          showProgressSheet();
          final res = await apiDio().post('/auth/signup', data: ctrl.user);
          Get.back();
          // Proceed to next step
          clog(res.data);
          pushTo(const Step2());
        } catch (e) {
          Get.back();
          errorHandler(e: e, context: context);
        }
      },
      btnTxt: "Next",
      fields: [
        Obx(() => TuFormField(
              label: "Email address:",
              hint: "Enter your email...",
              keyboard: TextInputType.emailAddress,
              required: true,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Email is required';
                } else if (!val.isEmail) {
                  return "Enter a valid email address";
                }
                return null;
              },
              value: ctrl.user["email"],
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, "email": val};
              },
            )),
        Obx(() => TuFormField(
              label: "Password:",
              hint: "More than 6 characters...",
              required: true,
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
          showProgressSheet();
          await apiDio().post('/auth/otp/verify',
              data: {'email': ctrl.user['email'], 'otp': ctrl.user['otp']});
          Get.back();
          pushTo(const Step3());
        } catch (e) {
          Get.back();
          errorHandler(e: e, context: context);
        }
      },
      btnTxt: "Verify",
      title: "Verify email",
      fields: [
        mY(5),
        SizedBox(
          width: screenSize(context).width,
          child: Column(
            children: [
              const Text("Enter the 4 digit pin sent to:"),
              Obx(() => Text(
                    "${ctrl.user['email']}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TuColors.primary),
                  )),
            ],
          ),
        ),
        mY(10),
        Obx(() => TuFormField(
              my: 0,
              textAlign: TextAlign.center,
              labelAlignment: FloatingLabelAlignment.center,
              hint: "* * * * ",
              height: borderlessInpHeight,

              ///label: "OTP:",
              value: ctrl.user['otp'],
              keyboard: TextInputType.number,

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
                    showProgressSheet();
                    await apiDio().post('/auth/otp/resend',
                        data: {'email': ctrl.user['email']});
                    _setSecs(60);
                    _initTimer();
                    Get.back();
                  } catch (e) {
                    Get.back();
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
    final ctrl = Get.find<SignupCtrl>();
    return CreateAccountPageWrapper(
      btnTxt: "SUBMIT",
      onSubmit: () async {
        try {
          showProgressSheet();
          final res =
              await apiDio().post("/auth/signup?act=complete", data: ctrl.user);
          appBox!.put("authToken", res.data["token"]);
          await setupUser(full: false);
          Get.back();

          Get.offAllNamed('/');
          Get.toNamed('/account/profile');
        } catch (e) {
          Get.back();
          errorHandler(e: e, context: context);
        }
      },
      title: "Finish up",
      fields: [
        const Text(
          "FINISH UP",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        mY(10),
        Obx(() => TuFormField(
              label: "First name:",
              hint: "e.g. John",
              keyboard: TextInputType.name,
              required: true,
              value: ctrl.user['first_name'],
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, "first_name": val};
              },
            )),
        Obx(() => TuFormField(
              label: "Last name:",
              keyboard: TextInputType.name,
              hint: "e.g. Doe",
              required: true,
              value: ctrl.user['last_name'],
              onChanged: (val) {
                ctrl.setuser = {...ctrl.user, "last_name": val};
              },
            )),
        TuFormField(
          label: "Phone:",
          hint: "e.g. 0712345678",
          required: true,
          value: ctrl.user['phone'],
          keyboard: TextInputType.phone,
          onChanged: (val) {
            ctrl.setuser = {...ctrl.user, "phone": val};
          },
        ),
      ],
    );
  }
}

class CreateAccountPageWrapper extends StatefulWidget {
  final List<Widget> fields;
  final String btnTxt;
  final String? title;
  final Function() onSubmit;

  const CreateAccountPageWrapper(
      {super.key,
      this.fields = const [],
      required this.onSubmit,
      this.btnTxt = "Submit",
      this.title});

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
      appBar: childAppbar(title: "New account", showCart: false),
      child: Container(
          color: cardBGLight,
          height:
              screenSize(context).height - appBarH - statusBarH() - topMargin,
          margin: EdgeInsets.only(top: topMargin),
          padding: defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${MainApp.appCtrl.store['name']}",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
              mY(10),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.fields,
                  )),
              mY(10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TuButton(
                      width: double.infinity,
                      text: widget.btnTxt,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await widget.onSubmit();
                        }
                      }),
                  mY(5),
                  TextButton(
                      onPressed: () {
                        //pushNamed( '/auth/signup');
                        Get.back();
                      },
                      child: const Text(
                        "Login instead",
                        style: TextStyle(color: Colors.blue),
                      )),
                ],
              ),
            ],
          )),
    );
  }
}
