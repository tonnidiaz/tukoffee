import "package:flutter/material.dart";
import "package:tu/tu.dart";

class PromptDialog extends StatelessWidget {
  final void Function()? onOk;
  final Future<bool> Function()? onCancel;
  final String title;
  final String okTxt;
  final String cancelTxt;
  final String msg;
  const PromptDialog(
      {super.key,
      this.title = "",
      this.msg = "",
      this.okTxt = "Ok",
      this.cancelTxt = "Cancel",
      this.onOk,
      this.onCancel});

  @override
  Widget build(BuildContext context) {
    return TuDialogView(
      title: title,
      content: Text(msg),
      onOk: onOk,
      onCancel: onCancel,
      okTxt: okTxt,
    );
  }
}
