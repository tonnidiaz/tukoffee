import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/widgets/common.dart';

class ProgressSheet extends StatefulWidget {
  final Color? color;
  final String? msg;
  final bool dismissable;
  const ProgressSheet(
      {super.key, this.color, this.msg, required this.dismissable});

  @override
  State<ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<ProgressSheet> {
  final _ctrl = MainApp.progressCtrl;

  @override
  void dispose() {
    backEnabled = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _ctrl.setProgress(null);
    });

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.dismissable) {
      backEnabled = false;
    }
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

void showProgressSheet({String? msg, bool dismissable = false}) {
  Get.bottomSheet(ProgressSheet(msg: msg, dismissable: dismissable),
      isDismissible: false);
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

class TuBottomBar extends StatelessWidget {
  final Widget? child;
  final double topRadius;
  final EdgeInsetsGeometry? padding;
  const TuBottomBar(
      {super.key, this.child, this.topRadius = 0.0, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? defaultPadding2,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
          color: cardBGLight,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(158, 158, 158, .5),
              offset: Offset(0, -.5),
            )
          ]),
      child: child,
    );
  }
}
