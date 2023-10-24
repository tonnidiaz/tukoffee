import "package:flutter/material.dart";
import "package:lebzcafe/utils/functions.dart";

import "../common.dart";

class TuForm extends StatefulWidget {
  final String btnTxt;
  final Widget Function(GlobalKey<FormState> formKey) builder;
  const TuForm({super.key, required this.builder, this.btnTxt = "Submit"});

  @override
  State<TuForm> createState() => _TuFormState();
}

class _TuFormState extends State<TuForm> {
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _key.currentState?.save();
    return Form(key: _key, child: _wid());
  }

  Widget _wid() {
    _key.currentState?.save();

    return widget.builder(_key);
  }
}
