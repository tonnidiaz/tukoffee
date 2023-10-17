// ignore_for_file: use_build_context_synchronously

import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/dialog.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String _msg = "";
  _setMsg(String val) {
    setState(() {
      _msg = val;
    });
  }

  String _email = "";
  _setEmail(String val) {
    setState(() {
      _email = val;
    });
  }

  Map<String, dynamic> _form = {};
  _setFormKey(String key, dynamic val) {
    setState(() {
      _form[key] = val;
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: defaultPadding,
      margin: EdgeInsets.only(bottom: keyboardPadding(context)),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "Help / Feedback",
            style: Styles.h3(),
          ),
          mY(10),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  TuFormField(
                    label: "Full name:",
                    hint: "e.g. John Doe ",
                    required: true,
                    onChanged: (val) {
                      _setFormKey('name', val);
                    },
                    value: _form['name'],
                    keyboard: TextInputType.name,
                  ),
                  TuFormField(
                    label: "Email:",
                    hint: "Your email here... ",
                    required: true,
                    onChanged: (val) {
                      _setFormKey('email', val);
                    },
                    value: _form['email'],
                    keyboard: TextInputType.emailAddress,
                  ),
                  TuFormField(
                    label: "Message:",
                    maxLines: 3,
                    hint: "Your message here... ",
                    required: true,
                    keyboard: TextInputType.multiline,
                    onChanged: (val) {
                      _setFormKey('msg', val);
                    },
                    value: _form['msg'],
                  ),
                  mY(6),
                  TuButton(
                    text: "SUBMIT FEEDBACK",
                    width: double.infinity,
                    onPressed: () async {
                      try {
                        if (_formKey.currentState!.validate()) {
                          showProgressSheet(msg: 'Sending feedback...');
                          await apiDio().post('/message/send', data: {
                            "app": MainApp.appCtrl.store['name'],
                            ..._form
                          });

                          gpop();
                          showToast("Feedback sent!")
                              .show(context)
                              .then((value) {
                            pop(context);
                          });
                        }
                      } catch (e) {
                        gpop();
                        errorHandler(
                            e: e,
                            context: context,
                            msg: "Failed to  send feedback");
                      }
                    },
                  )
                ],
              ))
        ]),
      ),
    );
  }
}
