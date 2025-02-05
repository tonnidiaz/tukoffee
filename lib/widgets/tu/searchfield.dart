import "dart:io";
import "package:tu/tu.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/utils/constants2.dart";

class TuSearchField extends StatefulWidget {
  final List<TuSuggestion> suggestions;
  final Function(TuSuggestion it) onSuggestionTap;
  final IconData? suggestionIcon;
  final Function(String) onChanged;
  final String? label;
  final String hint;
  final Widget? prefix;
  final bool enabled;
  final bool readOnly;
  final Color? fill;
  const TuSearchField(
      {super.key,
      this.label,
      this.hint = "",
      this.fill,
      required this.onChanged,
      this.prefix,
      this.enabled = true,
      this.readOnly = false,
      this.suggestions = const [],
      required this.onSuggestionTap,
      this.suggestionIcon});

  @override
  State<TuSearchField> createState() => _TuSearchFieldState();
}

class _TuSearchFieldState extends State<TuSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _debouncer = Debouncer(milliseconds: 600);
  OverlayEntry? _entry;
  final _layerLink = LayerLink();

  String _value = "";
  _setValue(String val) {
    setState(() {
      _value = val;
    });
  }

  _hideOverlay() async {
    try {
      //clog(_entry == null);
      if (_entry != null) {
        await sleep(200);
        _entry?.remove();
        _entry = null;
      }
    } catch (e) {
      //clog(e);
    }
  }

  _showOverlay() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    _entry = OverlayEntry(
        builder: (context) => Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, size.height),
                  child: tuSearchField()),
            ));

    overlay.insert(_entry!);
  }

  _onFocusChanged() async {
    clog("ON FOCUS CHANGE");
    if (_focusNode.hasFocus && widget.suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      //clog("Unfocused");
      if (Platform.isAndroid || Platform.isIOS || true) {
        _hideOverlay();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    clog("DISPOSE");
    _hideOverlay();

    _entry?.dispose();
    _focusNode.removeListener(_onFocusChanged);

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _entry?.markNeedsBuild();
      if (widget.suggestions.isNotEmpty) _showOverlay();
    });
    return CompositedTransformTarget(
      link: _layerLink,
      child: TuFormField(
        fill: widget.fill,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        prefixIcon: widget.prefix,
        focusNode: _focusNode,
        hint: widget.hint,
        required: true,
        hasBorder: false,
        onSubmitted: (val) {
          _hideOverlay();
        },
        onChanged: (val) {
          clog(widget.suggestions.length);

          _setValue(val);
          _debouncer.run(() {
            widget.onChanged(val);
          });
        },
        label: widget.label,
        value: _value,
      ),
    );
  }

  Widget tuSearchField() {
    return Material(
        elevation: .5,
        child: Container(
            //height: widget.suggestions.isEmpty ? 40 : 150,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: const Color.fromARGB(255, 255, 253, 250),
            constraints: BoxConstraints(
                minHeight: 40,
                maxHeight: screenSize(context).height * (50 / 100)),
            child: ListView.builder(
              itemCount: widget.suggestions.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var it = widget.suggestions[index];
                return InkWell(
                  onTap: () {
                    _controller.text = it.text;
                    _setValue(it.text);
                    widget.onSuggestionTap(it);
                    _hideOverlay();
                    _focusNode.unfocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        widget.suggestionIcon != null
                            ? Icon(
                                widget.suggestionIcon!,
                                color: Colors.black45,
                              )
                            : none(),
                        mX(7),
                        Expanded(
                          child: Text(
                            it.text,
                            softWrap: true,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )));
  }
}

class TuSuggestion {
  final String text;
  final dynamic value;
  const TuSuggestion({required this.text, required this.value});
}
