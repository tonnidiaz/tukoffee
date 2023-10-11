import 'package:flutter/material.dart';
import 'package:frust/utils/styles.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';

class PromptModal extends StatelessWidget {
  final void Function()? onOk;
  final Future<bool> Function()? onCancel;
  final String title;
  final String okTxt;
  final String cancelTxt;
  final String msg;
  const PromptModal(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      backgroundColor: appBGLight,
      insetPadding: defaultPadding2,
      //actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      titlePadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      title: Text(
        title,
        style: Styles.h3(),
      ),
      content: Container(
        color: appBGLight,
        padding: defaultPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 10));
              if (onOk != null) onOk!();
            },
            child: Text(okTxt,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600))),
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
              cancelTxt,
              style: const TextStyle(color: Colors.red),
            )),
      ],
    );
  }
}
