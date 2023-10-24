import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";

import "../utils/colors.dart";
import "../utils/constants.dart";
import "../utils/styles.dart";
import "common.dart";

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
      this.okTxt = "CONTINUE",
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      titlePadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      insetPadding: const EdgeInsets.all(15),
      actionsPadding: const EdgeInsets.fromLTRB(6, 10, 15, 16),
      elevation: .5,
      title: Text(
        widget.title,
        style: Styles.h4(isLight: true),
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
          text: "CANCEL",
          height: 35,
          bgColor: TuColors.medium,
          radius: 5,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TuButton(
          text: widget.okTxt,
          height: 35,

          radius: 5,
          bgColor: Colors.blue,
          //bgColor: Colors.black87,
          // height: 35,
          onPressed: () async {
            if (widget.isForm) {
              if (_formKey.currentState!.validate()) {
                // Validate form first
                if (widget.onOk != null) {
                  await widget.onOk!();
                }
              }
            } else {
              if (widget.onOk != null) {
                await widget.onOk!();
              }
            }
          },
        )
      ],
    );
  }
}
