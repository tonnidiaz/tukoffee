import "package:flutter/material.dart";
import "package:lebzcafe/utils/styles.dart";

import "../utils/colors.dart";
import "../utils/constants.dart";

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
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      backgroundColor: Colors.white,
      insetPadding: defaultPadding2,
      //actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      titlePadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      shape: const RoundedRectangleBorder(),
      title: Text(
        title,
        style: Styles.h3(isLight: true),
      ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              msg,
              style: TextStyle(color: TuColors.text2),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () async {
              if (onCancel != null) {
                // ignore: use_build_context_synchronously
                if (await onCancel!()) Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              cancelTxt.toUpperCase(),
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            )),
        TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 10));
              if (onOk != null) onOk!();
            },
            child: Text(okTxt.toUpperCase(),
                style: const TextStyle(color: Colors.black, fontSize: 14))),
      ],
    );
  }
}
