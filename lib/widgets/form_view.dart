import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';
import '../utils/styles.dart';
import 'common.dart';
import 'common2.dart';

class FormViewCtrl extends GetxController {
  RxMap<String, dynamic> form = <String, dynamic>{}.obs;
  setFormField(String key, dynamic val) {
    form.value = {...form, key: val};
  }

  clear() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      clog("Clear form");
      form.value = {};
      setTempImgs([]);
    });
  }

  setForm(Map<String, dynamic> val) {
    form.value = {};
    form.value = val;
  }

  RxList tempImgs = [].obs;
  void setTempImgs(List<dynamic> val) {
    tempImgs.value = val;
  }
}

class FormView extends StatefulWidget {
  final List<Widget> fields;
  final Function() onSubmit;
  final String? title;
  final String btnTxt;
  final bool useBottomSheet;
  const FormView(
      {super.key,
      this.fields = const [],
      this.title,
      this.useBottomSheet = false,
      required this.onSubmit,
      this.btnTxt = "Submit"});

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitBtn = TuButton(
        text: widget.btnTxt,
        width: double.infinity,
        bgColor: Colors.black87,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            widget.onSubmit();
          }
        });
    return PageWrapper(
        appBar:
            childAppbar(showCart: false, title: widget.title ?? "Add address"),
        bottomSheet: widget.useBottomSheet
            ? Container(
                padding: defaultPadding,
                color: cardBGLight,
                height: 55,
                child: submitBtn,
              )
            : null,
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            mY(4),
            Container(
              color: cardBGLight,
              padding: defaultPadding,
              child: Column(
                children: [
                  Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...widget.fields,
                            mY(5),
                            widget.useBottomSheet ? none() : submitBtn
                          ]))
                ],
              ),
            ),
            mY(55)
          ]),
        ));
  }
}
