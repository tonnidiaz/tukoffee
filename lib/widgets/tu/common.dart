import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";

import "package:tu/tu.dart";

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
      backgroundColor: colors.background,
      collapsedBackgroundColor: colors.background,
      textColor: colors.text2,
      title: Text(title, style: styles.h3(isLight: true)),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      children: [
        Container(
          color: colors.surface,
          width: double.infinity,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
              padding: defaultPadding, color: colors.surface, child: child),
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
          color: colors.surface,
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
