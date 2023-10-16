import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/widgets/common.dart';

class ProgressSheet extends StatefulWidget {
  final Color? color;
  final String? msg;
  const ProgressSheet({super.key, this.color, this.msg});

  @override
  State<ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<ProgressSheet> {
  final _ctrl = MainApp.progressCtrl;

  @override
  void dispose() {
    if (context.mounted) {
      _ctrl.setProgress(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        child: Container(
            height: 45,
            color: widget.color ?? cardBGLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => LinearProgressIndicator(
                      value: _ctrl.progress.value,
                    )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(widget.msg ?? 'Hang on...')],
                    ),
                  ),
                )
              ],
            )));
  }
}

void showProgressSheet({String? msg}) {
  Get.bottomSheet(ProgressSheet(msg: msg), isDismissible: false);
}

class TuCollapse extends StatelessWidget {
  final String title;
  final Widget child;
  final double radius;
  final bool expanded;
  const TuCollapse(
      {super.key,
      required this.title,
      required this.child,
      this.radius = 4.5,
      this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: expanded,
      backgroundColor: appBGLight,
      collapsedBackgroundColor: appBGLight,
      textColor: TuColors.text2,
      title: h3(title, isLight: true),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      children: [
        Container(
          color: cardBGLight,
          width: double.infinity,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
              padding: defaultPadding, color: cardBGLight, child: child),
        )
      ],
    );
  }
}
