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

  @override
  Widget build(BuildContext context) {
    return TuDialogView(
      title: "Help/Feedback",
      isForm: true,
      fields: [
        TuFormField(
          label: "Email:",
          hint: "Your email here... ",
          required: true,
          onChanged: _setEmail,
          value: _email,
          keyboard: TextInputType.emailAddress,
        ),
        TuFormField(
          label: "Message:",
          maxLines: 3,
          hint: "Your message here... ",
          required: true,
          keyboard: TextInputType.multiline,
          onChanged: _setMsg,
          value: _msg,
        ),
      ],
      onOk: () async {
        try {
          await apiDio().post('/message/send',
              data: {'from': _email, 'to': 'staff', 'msg': _msg});
          showToast("Feedback sent!")
              .show(context)
              .then((value) => Navigator.pop(context));
        } catch (e) {
          errorHandler(e: e, context: context, msg: "Failed to  send feedback");
        }
      },
    );
  }
}
