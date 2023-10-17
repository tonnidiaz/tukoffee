import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/widgets/common.dart';

class LoadingDialog extends StatelessWidget {
  final String? msg;
  const LoadingDialog({super.key, this.msg});

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: appBGLight,
      content: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
        mX(10),
        Text(
          msg ?? "Hang on...",
          style: TextStyle(
              fontWeight: FontWeight.w600, color: TuColors.note, fontSize: 14),
        )
      ]),
    );
  }
}

showLoading(
  BuildContext context, {
  Widget? widget,
}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      useRootNavigator: false,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      builder: (context) => widget ?? const LoadingDialog());
}
