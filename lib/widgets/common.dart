import 'dart:core';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

Widget mY(double h) {
  return SizedBox(height: h);
}

Widget mX(double w) {
  return SizedBox(width: w);
}

Widget h3(String txt, {Color? color}) {
  return Text(
    txt,
    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: color),
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
  final double radius;
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
      this.radius = 7,
      this.bgColor,
      this.borderColor,
      this.labelFontSize,
      this.onChanged,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      decoration: BoxDecoration(
          color: bgColor ?? cardBGLight,
          border: Border.all(
              color: borderColor ?? const Color.fromARGB(8, 0, 0, 0),
              width: 1.5),
          borderRadius: BorderRadius.circular(radius)),
      child: DropdownButton(
          value: value, // ?? formats[0],
          dropdownColor: bgColor ?? cardBGLight,
          underline: Container(),
          isExpanded: true,
          borderRadius: BorderRadius.circular(5),
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
                style: TextStyle(fontSize: labelFontSize),
              ),
            );
          }).toList(),
          onChanged: disabled ? null : onChanged),
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
    children: [
      Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
      mX(spacing),
      Text(
        text,
        style: TextStyle(fontSize: fontSize, color: labelColor, fontWeight: fw),
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
  final double width;
  final double height;
  final double vp;
  final double radius;
  final double hp;
  final Function()? onPressed;
  final Color? bgColor;
  final Widget? child;
  final String text;
  const TuButton(
      {super.key,
      this.text = "",
      this.width = double.infinity,
      this.height = 40,
      this.vp = 5,
      this.radius = 0,
      this.hp = 10,
      this.onPressed,
      this.bgColor,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: ElevatedButton(
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
              elevation: .5,
              padding: EdgeInsets.symmetric(
                  vertical: widget.vp, horizontal: widget.hp),
              backgroundColor: widget.bgColor,
              alignment: Alignment.center),
          child: widget.child ?? Text(widget.text.toUpperCase()),
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
  return Container();
}

class OptionsBtn extends PopupMenuButton {
  const OptionsBtn({super.key, required super.itemBuilder});
}
