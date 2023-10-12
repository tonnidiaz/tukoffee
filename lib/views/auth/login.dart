// ignore_for_file: use_build_context_synchronously
import 'package:frust/widgets/tu/form_field.dart';

import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/tu/form.dart';
import 'package:get/get.dart';

import 'create.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _formCtrl = MainApp.formViewCtrl;

  _login() async {
    try {
      if (_formKey.currentState!.validate()) {
        clog('Loging on...');
        final res = await apiDio().post('/auth/login', data: _formCtrl.form);
        // User already exists and password is correct
        appBox!.put("authToken", res.data["token"]);
        setupUser();
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      errorHandler(e: e, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(title: 'Login', showCart: false),
      child: Container(
        color: cardBGLight,
        height: screenSize(context).height -
            appBarH -
            statusBarH(context: context) -
            4,
        margin: const EdgeInsets.only(top: 4),
        padding: defaultPadding,
        child: Form(
            key: _formKey,
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      onPressed: () {},
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
                            pushNamed(context, '/auth/signup');
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
