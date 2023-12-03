/* class TuFormField extends StatefulWidget {
  final String? label;
  final String hint;
  final dynamic value;
  final Widget? suffix;
  final Widget? prefix;
  final Function(String)? onChanged;
  final Function(Function)? onShowHidePass;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool isPass;
  final bool showEye;
  final bool hasBorder;
  final TextInputType keyboard;
  final double radius;
  final double height;
  final double my;
  final bool isLegacy;
  final bool readOnly;
  final int maxLines;
  final double? width;
  final int? maxLength;
  final TextAlign textAlign;
  final FloatingLabelAlignment? labelAlignment;
  final Function()? onTap;

  const TuFormField(
      {super.key,
      this.label,
      this.my = 5,
      this.suffix,
      this.width,
      this.prefix,
      this.onTap,
      this.hint = "",
      this.value,
      this.radius = 5,
      this.height = 14,
      this.maxLines = 1,
      this.maxLength,
      this.onChanged,
      this.onShowHidePass,
      this.isRequired = false,
      this.isLegacy = false,
      this.readOnly = false,
      this.isPass = false,
      this.showEye = true,
      this.hasBorder = false,
      this.validator,
      this.textAlign = TextAlign.start,
      this.labelAlignment,
      this.keyboard = TextInputType.text});

  @override
  State<TuFormField> createState() => _TuFormFieldState();
}

class _TuFormFieldState extends State<TuFormField> {
  final _controller = TextEditingController();
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.my),
      width: widget.width,
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
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            obscureText: widget.isPass && !_showPass,
            maxLines: widget.maxLines,
            validator: widget.validator ??
                (val) {
                  String? msg;
                  if ((widget.isRequired && val != null && val.isEmpty) ||
                      val == null) {
                    msg = "Field is required!";
                  }
                  return msg;
                },
            keyboardType: widget.keyboard,
            decoration: InputDecoration(
              fillColor: TuColors.fieldBG,
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: widget.height,
                horizontal: 10,
              ),
              prefixIcon: widget.prefix,
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
                      icon: Icon(!_showPass
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash))
                  : widget.suffix,
              labelText:
                  !widget.hasBorder || !widget.isLegacy ? widget.label : null,
              hintText: widget.hint,
              floatingLabelAlignment: widget.labelAlignment,
              floatingLabelStyle:
                  const TextStyle(color: Colors.black87, fontSize: 18),
              focusedBorder: widget.hasBorder
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius),
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 2))
                  : const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54, width: 2)),
              focusedErrorBorder: widget.hasBorder
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius),
                      borderSide: const BorderSide(color: Colors.red, width: 2))
                  : const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2)),
              errorBorder: widget.hasBorder
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius),
                      borderSide: const BorderSide(color: Colors.red, width: 2))
                  : const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2)),
              enabledBorder: widget.hasBorder
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius),
                      borderSide:
                          const BorderSide(width: 2, color: Colors.black26))
                  : const UnderlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Colors.black26)),
            ),
          ),
        ],
      ),
    );
  }
}
 */


/* 
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
 
 */