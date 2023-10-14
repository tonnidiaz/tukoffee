import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:google_fonts/google_fonts.dart';

class TuFormField extends StatefulWidget {
  final String? label;
  final String hint;
  final dynamic value;
  final Widget? suffix;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function(Function)? onShowHidePass;
  final String? Function(String?)? validator;
  final bool required;
  final bool isPass;
  final bool showEye;
  final bool hasBorder;
  final TextInputType keyboard;
  final double radius;
  final double elevation;
  final double height;
  final double my;
  final bool isLegacy;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final double? width;
  final int? maxLength;
  final TextAlign textAlign;
  final FloatingLabelAlignment? labelAlignment;
  final Function()? onTap;
  final FocusNode? focusNode;
  final Color? fill;
  const TuFormField(
      {super.key,
      this.label,
      this.my = 2.5,
      this.focusNode,
      this.suffixIcon,
      this.suffix,
      this.onSubmitted,
      this.width,
      this.prefixIcon,
      this.prefix,
      this.onTap,
      this.hint = "",
      this.value,
      this.radius = 4,
      this.elevation = 0,
      this.height = 10,
      this.maxLines = 1,
      this.maxLength,
      this.onChanged,
      this.onShowHidePass,
      this.required = false,
      this.isLegacy = false,
      this.autofocus = false,
      this.readOnly = false,
      this.isPass = false,
      this.showEye = true,
      this.hasBorder = true,
      this.validator,
      this.fill,
      this.textAlign = TextAlign.start,
      this.labelAlignment,
      this.keyboard = TextInputType.name});

  @override
  State<TuFormField> createState() => _TuFormFieldState();
}

class _TuFormFieldState extends State<TuFormField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showPass = false;
  void _updateVal() {
    if (widget.value == null) {
      _controller.text = "";
    } else if (widget.value != _controller.text) {
      _controller.text = "${widget.value}";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateVal();
    });
    final border = widget.hasBorder
        ? UnderlineInputBorder(
            borderSide: BorderSide(color: TuColors.primaryFade, width: 2),
            borderRadius: BorderRadius.circular(widget.radius),
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: const BorderSide(color: Colors.transparent));
    final focusedBorder = !widget.hasBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: const BorderSide(color: Colors.transparent))
        : UnderlineInputBorder(
            borderSide: BorderSide(color: TuColors.primary, width: 3),
            borderRadius: BorderRadius.circular(widget.radius),
          );
    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.my),
      width: widget.width,
      child: Material(
        elevation: widget.elevation,
        borderRadius: BorderRadius.circular(widget.radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.hasBorder && widget.isLegacy
                ? Text(widget.label!, style: Styles.label())
                : none(),
            TextFormField(
              textAlign: widget.textAlign,
              maxLength: widget.maxLength,
              readOnly: widget.readOnly,
              controller: _controller,
              autofocus: widget.autofocus,
              onTap: widget.onTap,
              onFieldSubmitted: widget.onSubmitted,
              
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              focusNode: widget.focusNode ?? _focusNode,
              onChanged: widget.onChanged,
              obscureText: widget.isPass && !_showPass,
              maxLines: widget.maxLines,

              validator: widget.validator ??
                  (val) {
                    String? msg;
                    if ((widget.required && val != null && val.isEmpty) ||
                        val == null) {
                      msg = "Field is required!";
                    }
                    return msg;
                  },
              autocorrect: true,
              autofillHints: ["email"],
              keyboardType: widget.keyboard,
              style: const TextStyle(
                fontSize: 16,
              ),
              decoration: InputDecoration(
                prefixIconColor:
                    _focusNode.hasFocus ? TuColors.note : Colors.black45,
                suffixIconColor:
                    _focusNode.hasFocus ? TuColors.note : Colors.black45,
                fillColor: widget.fill ?? Color.fromRGBO(134, 179, 172, 0.145),
                filled: true,
                isDense: true,
                contentPadding: EdgeInsets.only(
                  top: widget.height,
                  bottom: widget.height,
                  left: 10,
                  right: 10,
                ),

                prefixIcon: widget.prefixIcon,
                prefix: widget.prefix,
                suffix: widget.suffix,
                suffixIcon: widget.isPass && widget.showEye
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          //SHowHide pass

                          if (!_showPass && widget.onShowHidePass != null) {
                            // Pass hidden and the event handler is provided
                            // Invoke the handler
                            void setShowPass(bool val) {
                              setState(() {
                                _showPass = val;
                              });
                            }

                            await widget.onShowHidePass!(setShowPass);
                          } else {
                            setState(() {
                              _showPass = !_showPass;
                            });
                          }
                        },
                        splashRadius: 18,
                        icon: Icon(!_showPass
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash))
                    : widget.suffixIcon,

                labelText:
                    !widget.hasBorder || !widget.isLegacy ? widget.label : null,

                hintText: widget.hint,
                hintStyle: const TextStyle(fontSize: 12.5),
                floatingLabelAlignment: widget.labelAlignment,
                floatingLabelStyle: GoogleFonts.inclusiveSans(
                    color: Colors.black87, fontSize: 18),
                enabledBorder: widget.radius != null ? border : null,
                focusedBorder: widget.radius != null ? focusedBorder : null,
                focusedErrorBorder:
                    widget.radius != null ? focusedBorder : null,
                errorBorder: widget.radius != null ? border : null,
                //border: widget.radius != null ? border : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
