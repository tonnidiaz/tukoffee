import 'dart:core';
import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/styles.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/constants2.dart';

Widget mY(double h) {
  return SizedBox(height: h);
}

Widget mX(double w) {
  return SizedBox(width: w);
}

Widget h3(String txt, {Color? color, bool isLight = false}) {
  return Text(
    txt,
    style: Styles.h3(color: color, isLight: isLight),
  );
}

Widget h4(String txt, {Color? color, bool isLight = false}) {
  return Text(
    txt,
    style: Styles.h4(color: color, isLight: isLight),
  );
}

Widget navItem({String text = "", void Function()? onClick}) {
  return InkWell(
    onTap: onClick,
    child: Container(
      width: double.infinity,
      //color: const Color.fromRGBO(30, 30, 30, .2),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(fontSize: 15),
      ),
    ),
  );
}

Widget sizedText(String text,
    {double width = 150, double fs = 16, Color color = Colors.white70}) {
  return SizedBox(
      width: width,
      child: Text(
        text,
        softWrap: false,
        style: TextStyle(
          fontSize: fs,
          overflow: TextOverflow.fade,
          color: color,
        ),
      ));
}

class TuDropdownButton extends StatelessWidget {
  final dynamic value;
  final void Function(dynamic)? onChanged;
  final String? label;
  final double? width;
  final double? radius;
  final double elevation;
  final double? height;
  final double? labelFontSize;
  final bool disabled;
  final Color? bgColor;
  final Color? borderColor;
  final List<SelectItem> items;
  const TuDropdownButton(
      {Key? key,
      this.items = const [],
      this.value,
      this.label = "Dropdown",
      this.width,
      this.height = 40,
      this.radius,
      this.bgColor,
      this.borderColor,
      this.labelFontSize,
      this.elevation = .5,
      this.onChanged,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: Material(
        color: /* mFieldBG2, */ bgColor ?? appBGLight,
        elevation: elevation,
        shadowColor: Colors.black87,
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
              value: value, // ?? formats[0],
              dropdownColor: bgColor ?? appBGLight,
              focusColor: bgColor ?? appBGLight,
              underline: Container(),
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_outlined,
                color: Colors.black54,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              hint: SizedBox(
                  child: Text(
                "$label",
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              )),
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e.value,
                  child: Text(
                    e.label,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: tuTextTheme(context).labelLarge,
                  ),
                );
              }).toList(),
              onChanged: disabled ? null : onChanged),
        ),
      ),
    );
  }
}

Widget iconText(String text, IconData icon,
    {double spacing = 4.0,
    double iconSize = 18,
    double my = 0,
    double? fontSize,
    FontWeight? fw,
    Function()? onClick,
    Color? iconColor,
    Color? labelColor,
    MainAxisAlignment alignment = MainAxisAlignment.center}) {
  final child = Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: alignment,
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
      mX(spacing),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: labelColor,
            fontWeight: fw,
          ),
          softWrap: true,
        ),
      )
    ],
  );

  return Container(
    margin: EdgeInsets.symmetric(vertical: my),
    child: onClick != null
        ? InkWell(onTap: onClick, enableFeedback: false, child: child)
        : child,
  );
}

class TuButton extends StatefulWidget {
  final double? width;
  final double height;
  final double vp;
  final double radius;
  final double hp;
  final Function()? onPressed;
  final Color? bgColor;
  final Color? color;
  final Widget? child;
  final String text;
  final bool outlined;
  const TuButton(
      {super.key,
      this.text = "",
      this.width,
      this.height = 45,
      this.vp = 5,
      this.radius = 3,
      this.hp = 10,
      this.outlined = false,
      this.onPressed,
      this.bgColor,
      this.color,
      this.child});

  @override
  State<TuButton> createState() => _TuButtonState();
}

class _TuButtonState extends State<TuButton> {
  bool _isProcessing = false;
  _setIsProcessing(bool val) {
    setState(() {
      _isProcessing = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.outlined
          ? OutlinedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      _setIsProcessing(true);
                      if (widget.onPressed != null) {
                        await widget.onPressed!();
                      }
                      _setIsProcessing(false);
                    },
              style: OutlinedButton.styleFrom(
                  alignment: Alignment.center,

                  /*   shadowColor: TuColors
                      .coffee1Shadow, // const Color.fromRGBO(26, 92, 255, .5),
                  elevation: 1.5, */
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  side: BorderSide(
                      color: widget.color ?? TuColors.text, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.radius),
                  )),
              child: widget.child ??
                  Text(
                    widget.text.toUpperCase(),
                    style: TextStyle(color: widget.color ?? TuColors.text),
                  ),
            )
          : ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      _setIsProcessing(true);
                      if (widget.onPressed != null) {
                        await widget.onPressed!();
                      }
                      _setIsProcessing(false);
                    },
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  disabledBackgroundColor: TuColors.medium,
                  disabledForegroundColor: Colors.white,
                  backgroundColor: widget.bgColor ??
                      Colors.black87, //const Color.fromRGBO(26, 92, 255, 1),
                  shadowColor: TuColors
                      .coffee1Shadow, // const Color.fromRGBO(26, 92, 255, .5),
                  elevation: 1.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.radius))),
              child: widget.child ??
                  Text(
                    widget.text.toUpperCase(),
                    style: TextStyle(color: widget.color),
                  ),
            ),
    );
  }
}

Widget TDrawerItem(
    {required String title,
    required int index,
    Widget? leading,
    bool selected = false,
    Function()? onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selectedTileColor: const Color.fromRGBO(225, 106, 6, .20),
      selectedColor: orange,
      selected: selected,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      onTap: onTap,
    ),
  );
}

Widget none() {
  return Container(
    width: 0,
  );
}

class OptionsBtn extends PopupMenuButton {
  const OptionsBtn({super.key, required super.itemBuilder});
}
