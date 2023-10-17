// ignore_for_file: use_build_context_synchronously
import 'package:google_fonts/google_fonts.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/tu/form.dart';
import 'package:get/get.dart';

import 'create.dart';

class LoginPage extends StatefulWidget {
  final bool pop;
  final String? to;
  const LoginPage({super.key, this.pop = false, this.to});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _formCtrl = MainApp.formCtrl;
  final _appCtrl = MainApp.appCtrl;

  _login() async {
    try {
      if (_formKey.currentState!.validate()) {
        showProgressSheet();
        final res = await apiDio().post('/auth/login', data: _formCtrl.form);
        // User already exists and password is correct
        appBox!.put("authToken", res.data["token"]);
        await setupUser(full: false);
        //gpop();
        if (widget.pop) {
          gpop(); //Hide sheet
          gpop(); //Back to prev page
        } else if (widget.to != null) {
          gpop();
          Navigator.pushNamedAndRemoveUntil(
              context, widget.to!, (route) => route.isFirst);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      }
    } catch (e) {
      gpop();
      errorHandler(e: e, context: context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (DEV) {
        _formCtrl.setForm(
            {'email': 'clickbait4587@gmail.com', 'password': 'Baseline'});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(title: 'Login', showCart: false),
      child: Container(
        color: cardBGLight,
        height: screenSize(context).height - appBarH - statusBarH() - 4,
        margin: const EdgeInsets.only(top: 4),
        padding: defaultPadding,
        child: Form(
            key: _formKey,
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${_appCtrl.store['name']}",
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ],
                  ),
                  mY(10),
                  TuFormField(
                    label: "Email address:",
                    hint: "Enter your email...",
                    value: _formCtrl.form['email'],
                    required: true,
                    keyboard: TextInputType.emailAddress,
                    onChanged: (val) {
                      _formCtrl.setFormField('email', val);
                    },
                  ),
                  TuFormField(
                    label: "Password:",
                    hint: "Enter your password...",
                    value: _formCtrl.form['password'],
                    required: true,
                    isPass: true,
                    onChanged: (val) {
                      _formCtrl.setFormField('password', val);
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        pushNamed('/auth/forgot');
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.blue),
                      )),
                  mY(2.5),
                  TuButton(
                    text: 'LOGIN',
                    width: double.infinity,
                    bgColor: Colors.black87,
                    onPressed: _login,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            //pushNamed( '/auth/signup');
                            Get.toNamed('/auth/signup');
                          },
                          child: const Text(
                            "Create new account",
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
