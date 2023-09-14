/* // ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:get/get.dart';

import 'password.dart';

class LoginCtrl extends GetxController {
  RxMap<String, dynamic> user = <String, dynamic>{
    "email": "tonnidiazed@gmail.com",
    "password": "toor"
  }.obs;
  RxInt step = 0.obs;
  set setstep(int val) {
    step.value = val;
  }

  set setuser(Map<String, dynamic> val) {
    user.value = val;
  }
}

class TStep {
  bool complete;
  TStep({this.complete = false});
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late GlobalKey<FormState> _formKey;
  final _ctrl = Get.put(LoginCtrl());
  String _btnTxt = "Login";

  void _setBtnTxt(String val) {
    setState(() {
      _btnTxt = val;
    });
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  final _appCtrl = MainApp.appCtrl;
  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(title: "Login", showCart: false),
      child: Container(
          padding: defaultPadding2,
          height: screenSize(context).height - (appBarH + statusBarH(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              mY(screenSize(context).height / 30),
              Text(
                "Login",
                style: Styles.h1,
              ),
              mY(15),
              Form(
                  key: _formKey,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TuFormField(
                          label: "Email:",
                          hint: "e.g. johndoe01@gmail.com",
                          keyboard: TextInputType.emailAddress,
                          isRequired: true,
                          hasBorder: false,
                          value: _ctrl.user["email"],
                          onChanged: (val) {
                            _ctrl.setuser = {..._ctrl.user, "email": val};
                          },
                        ),
                        TuFormField(
                          label: "Password:",
                          value: _ctrl.user["password"],
                          isPass: true,
                          keyboard: TextInputType.emailAddress,
                          isRequired: true,
                          hasBorder: false,
                          onChanged: (val) {
                            _ctrl.setuser = {..._ctrl.user, "password": val};
                          },
                        ),
                      ],
                    ),
                  )),
              TextButton(
                  style: TextButton.styleFrom(
                      fixedSize: const Size.fromHeight(16)),
                  onPressed: () {
                    pushTo(context, const ForgotPassPage());
                  },
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0.5,
                          fixedSize: Size(screenSize(context).width, 40),
                          backgroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                              borderRadius: Styles.btnRadius)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            _setBtnTxt("Loging in...");
                            final res = await dio.post("$apiURL/auth/login",
                                data: _ctrl.user);
                            clog(res.data['token']);
                            appBox!.put("authToken", res.data["token"]);
                            setupUser();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => false);
                          } catch (e) {
                            if (e.runtimeType == DioException) {
                              e as DioException;
                              handleDioException(
                                  context: context, exception: e);
                            } else {
                              showToast("Error logging in", isErr: true)
                                  .show(context);
                            }
                            _setBtnTxt("Login");
                          }
                        }
                      },
                      child: Text(_btnTxt)),
                  mY(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Container(
                        height: 1.8,
                        color: Colors.black26,
                      )),
                      const Text("  Or  "),
                      Expanded(
                          child: Container(
                        height: 1.8,
                        color: Colors.black26,
                      )),
                    ],
                  ),
                  mY(5),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: Styles.btnRadius),
                          fixedSize: Size(screenSize(context).width, 40)),
                      onPressed: () {
                        Navigator.pushNamed(context, "/auth/create");
                      },
                      child: Text("Sign up"))
                ],
              )
            ],
          )),
    );
  }
}
 */