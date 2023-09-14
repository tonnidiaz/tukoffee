import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/functions.dart';
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

  final FormViewCtrl _formViewCtrl = Get.find();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitBtn = TuButton(
        text: widget.btnTxt,
        width: double.infinity,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            widget.onSubmit();
          }
        });
    return PageWrapper(
        appBar: childAppbar(showCart: false),
        bottomSheet: widget.useBottomSheet
            ? Container(
                padding: defaultPadding,
                color: cardBGLight,
                height: 55,
                child: submitBtn,
              )
            : null,
        child: SingleChildScrollView(
          child: Container(
              //color: Colors.amber,
              padding:
                  const EdgeInsets.only(bottom: 55, top: 14, left: 14, right: 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title ?? "Add address", style: Styles.h1),
                    mY(10),
                    Column(
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
                    )
                  ])),
        ));
  }
}
