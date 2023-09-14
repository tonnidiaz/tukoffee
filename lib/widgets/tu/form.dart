import 'package:flutter/material.dart';

import '../common.dart';

class TuForm extends StatefulWidget {
  final List<Widget> children;
  final String btnTxt;
  final Function() onSubmit;
  const TuForm(
      {super.key,
      this.children = const [],
      required this.onSubmit,
      this.btnTxt = "Submit"});

  @override
  State<TuForm> createState() => _TuFormState();
}

class _TuFormState extends State<TuForm> {
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(children: [
            ...widget.children,
            ...widget.children,
            ...widget.children,
            mY(10),
            TuButton(text: widget.btnTxt)
          ]),
        ),
      ),
    );
  }
}
