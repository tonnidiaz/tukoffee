import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import 'common.dart';

class TuDialogView extends StatefulWidget {
  final bool isForm;
  final Function()? onOk;
  final Widget? content;
  final String title;
  final List<Widget> fields;
  final String okTxt;
  const TuDialogView(
      {super.key,
      this.isForm = false,
      this.onOk,
      this.content,
      this.okTxt = "Submit",
      this.title = "",
      this.fields = const []});

  @override
  State<TuDialogView> createState() => _TuDialogViewState();
}

class _TuDialogViewState extends State<TuDialogView> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: cardBGLight,
      contentPadding: defaultPadding,
      titlePadding: defaultPadding,
      actionsPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
      insetPadding: const EdgeInsets.all(15),
      title: Text(
        widget.title,
        style: Styles.h2(),
      ),
      content: widget.isForm
          ? Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.fields,
                ],
              ))
          : widget.content,
      actions: [
        TuButton(
            text: widget.okTxt,
            onPressed: () async {
              if (widget.isForm) {
                if (_formKey.currentState!.validate()) {
                  // Validate form first
                  if (widget.onOk != null) {
                    await widget.onOk!();
                  }

                  await Future.delayed(const Duration(milliseconds: 50));
                  // Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
            width: double.infinity)
      ],
    );
  }
}
