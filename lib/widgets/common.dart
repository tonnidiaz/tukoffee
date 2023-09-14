import 'dart:core';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';

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

class TInputField extends StatefulWidget {
  String label;
  String placeholder;
  Object? value;
  Widget? suffix;
  bool readOnly;
  bool isRequired;
  int? maxLines;
  String? Function(String?)? validator;
  void Function(String)? onChanged;
  void Function()? onTap;
  TextInputType? keyboardType;
  bool isPassword;
  TInputField(
      {super.key,
      this.label = "Title:",
      this.placeholder = "Placeholder...",
      this.value = "",
      this.suffix,
      this.readOnly = false,
      this.isRequired = false,
      this.isPassword = false,
      this.onChanged,
      this.maxLines = 1,
      this.onTap,
      this.keyboardType,
      this.validator});

  @override
  State<TInputField> createState() => _TInputFieldState();
}

class _TInputFieldState extends State<TInputField> {
  final controller = TextEditingController();
  bool _showPass = false;
  void _updateController() {
    try {
      if (widget.value != null && widget.value != controller.text) {
        controller.text = "${widget.value!}";
      } else if (widget.value == null) {
        controller.text = "";
      }
    } catch (err) {
      clog(err);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateController();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        maxLines: widget.maxLines,
        controller: controller,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword && !_showPass,
        validator: (val) {
          if (widget.isRequired && (val == null || val.isEmpty)) {
            return "Field is required!";
          }
          if (widget.validator != null) {
            return widget.validator!(val);
          }
          return null;
        },
        decoration: InputDecoration(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label),
                widget.isRequired
                    ? Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: const Icon(
                          Icons.emergency,
                          size: 10,
                          color: Colors.red,
                        ),
                      )
                    : const Text("")
              ],
            ),
            hintText: widget.placeholder,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _showPass = !_showPass;
                      });
                    },
                    icon: (Icon(
                        _showPass ? Icons.visibility_off : Icons.visibility)))
                : widget.suffix,
            labelStyle: const TextStyle(color: Colors.white70),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: btnBG, width: 2)),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange, width: 2)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange, width: 2))),
      ),
    );
  }
}

Widget NavItem({String text = "", void Function()? onClick}) {
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

  return onClick != null
      ? InkWell(onTap: onClick, enableFeedback: false, child: child)
      : child;
}

class TuButton extends StatefulWidget {
  final double width;
  final double height;
  final double vp;
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

class TestWidget extends StatefulWidget {
  String label;
  String placeholder;
  Object? value;
  Widget? suffix;
  bool readOnly;
  bool isRequired;
  int? maxLines;
  String? Function(String?)? validator;
  void Function(String)? onChanged;
  void Function()? onTap;
  TextInputType? keyboardType;
  TestWidget(
      {super.key,
      this.label = "Label:",
      this.placeholder = "Placeholder...",
      this.value = "",
      this.suffix,
      this.readOnly = false,
      this.isRequired = false,
      this.onChanged,
      this.maxLines = 1,
      this.onTap,
      this.keyboardType,
      this.validator});
  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _hasFocus = false;
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateController() {
    try {
      if (widget.value != _controller.text) {
        _controller.text = "${widget.value ?? ""}";
      }
    } catch (err) {
      clog(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateController();
    return TextFormField(
      onTap: widget.onTap,
      focusNode: _focusNode,
      controller: _controller,
      keyboardType: widget.keyboardType,
      validator: (val) {
        if (widget.isRequired && (val == null || val.isEmpty)) {
          return "Field is required!";
        }
        if (widget.validator != null) {
          return widget.validator!(val);
        }
        return null;
      },
      onChanged: widget.onChanged,
      decoration: InputDecoration(
          hintStyle: const TextStyle(fontSize: 14),
          labelStyle: TextStyle(color: _hasFocus ? Colors.orange : null),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label),
              widget.isRequired
                  ? Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: const Icon(
                        Icons.emergency,
                        size: 10,
                        color: Colors.red,
                      ),
                    )
                  : const Text("")
            ],
          ),
          hintText: widget.placeholder),
    );
  }
}

Widget none() {
  return Container();
}

class OptionsBtn extends PopupMenuButton {
  const OptionsBtn({super.key, required super.itemBuilder});
}
