import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:tu/tu.dart";

class LoadingDialog extends StatefulWidget {
  final String? msg;
  const LoadingDialog({super.key, this.msg});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  @override
  void initState() {
    super.initState();
    backEnabled = false;
  }

  @override
  void dispose() {
    backEnabled = true;
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: colors.bg,
      content: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
        mX(10),
        Text(
          widget.msg ?? "Hang on...",
          style: TextStyle(
              fontWeight: FontWeight.w600, color: colors.note, fontSize: 14),
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
