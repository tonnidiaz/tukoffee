import 'package:flutter/material.dart';
import 'package:tu/tu.dart';
import '../../main.dart';
import './ctrl.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  static Ctrl ctrl = Get.put(Ctrl());
  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formCtrl;
    return Scaffold(
      appBar: tuAppbar(title: const Text("Help & Feedback")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(children: [
            mY(15),
            const Text(
              "Hit us up with any Feedback, suggestions, or questions that you have. ",
              textAlign: TextAlign.center,
            ),
            mY(15),
            TuForm(builder: ((formKey) {
              final form = formCtrl.form;
              return Obx(
                () => Column(
                  children: [
                    TuFormField(
                      label: "Full name:",
                      hint: "e.g. John Doe",
                      value: form['name'],
                      required: true,
                      onChanged: (val) {
                        formCtrl.setFormField('name', val);
                      },
                    ),
                    TuFormField(
                      label: "Email:",
                      hint: "e.g. johnathan@mail.com",
                      value: form['email'],
                      keyboard: TextInputType.emailAddress,
                      required: true,
                      onChanged: (val) {
                        formCtrl.setFormField('email', val);
                      },
                    ),
                    TuFormField(
                      hint: "Type your feedback / query...",
                      value: form['body'],
                      maxLines: 5,
                      keyboard: TextInputType.multiline,
                      required: true,
                      maxLength: 1000,
                      onChanged: (val) {
                        formCtrl.setFormField('body', val);
                      },
                    ),
                    mY(5),
                    Wrap(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        const Text("Or email us at "),
                        SelectableText(
                          MainApp.appCtrl.email,
                          style: TextStyle(color: colors.primary),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    mY(10),
                    TuButton(
                      text: "Submit",
                      width: double.infinity,
                      bgColor: colors.secondary,
                      color: Colors.white,
                      onPressed: () async {
                        if (formKey.currentState?.validate() == true) {
                          await ctrl.sendFeedback(data: form, context: context);
                        }
                      },
                    ),
                    mY(15),
                  ],
                ),
              );
            }))
          ]),
        ),
      ),
    );
  }
}
