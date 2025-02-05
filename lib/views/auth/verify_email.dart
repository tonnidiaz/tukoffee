// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";

import "package:tu/tu.dart";

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formCtrl;
    final appCtrl = MainApp.appCtrl;
    return Container(
      padding: defaultPadding2,
      child: Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Obx(() => Text(
                "Enter the 4 digit pin sent to ${formCtrl.form["email"]}",
                textAlign: TextAlign.center,
              )),
          Obx(() => TuFormField(
                radius: 7,
                my: 0,
                textAlign: TextAlign.center,
                labelAlignment: FloatingLabelAlignment.center,
                hint: "* * * * ",
                value: formCtrl.form["otp"],
                keyboard: TextInputType.number,
                hasBorder: false,
                maxLength: 4,
                required: true,
                onChanged: (val) {
                  formCtrl.setFormField("otp", val);
                },
              )),
          mY(4),
          TuButton(
            text: "VERIFY",
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final res = await apiDio().post("/auth/verify-email", data: {
                    "email": formCtrl.form["email"],
                    "otp": formCtrl.form["otp"]
                  });

                  appCtrl.setUser(res.data["user"]);
                  Navigator.pop(context);
                } catch (e) {
                  errorHandler(e: e, context: context);
                }
              }
            },
          )
        ]),
      ),
    );
  }
}
