import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:get/get.dart";
import "package:tu/tu.dart";

import "common.dart";

class FormCtrl extends GetxController {
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
    return Scaffold(
        appBar:
            childAppbar(showCart: false, title: widget.title ?? "Add address"),
        bottomNavigationBar: widget.useBottomSheet
            ? Container(
                padding: defaultPadding,
                color: colors.surface,
                child: submitBtn,
              )
            : null,
        body: SingleChildScrollView(
          padding: defaultPadding,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            mY(4),
            TuCard(
              radius: 5,
              color: colors.surface,
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.fields,
                        mY(5),
                        widget.useBottomSheet ? none() : submitBtn
                      ])),
            ),
            mY(55)
          ]),
        ));
  }
}
