import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/dialog.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';
import '../widgets/common.dart';

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  String _query = "";
  final _formCtrl = MainApp.formViewCtrl;
  CancelToken _locationSearchToken = CancelToken();
  _setCancelToken(CancelToken val) {
    setState(() {
      _locationSearchToken = val;
    });
  }

  List _locations = [];
  _setLocations(List val) {
    setState(() {
      _locations = val;
    });
  }

  _setQuery(String val) {
    setState(() {
      _query = val;
    });
  }

  _searchLocation(String query) async {
    try {
      try {
        _locationSearchToken.cancel();
      } catch (e) {
        clog(e);
      }

      final cancelToken = CancelToken();
      _setCancelToken(cancelToken);
      final res = await searchLocation(query, token: cancelToken);
      _setLocations(res.data['features']);
    } catch (e) {
      clog(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(showCart: false, title: "Research"),
      child: Container(
          height: screenSize(context).height,
          alignment: Alignment.center,
          padding: defaultPadding2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              mY(10),
            ],
          )),
    );
  }
}

Widget editCollectorModal() {
  final formCtrl = MainApp.formViewCtrl;
  return TuDialogView(
    title: "Edit collector",
    isForm: true,
    fields: [
      Obx(() => TuFormField(
            label: "Collector Name:",
            hint: "e.g. John Doe",
            isRequired: true,
            value: formCtrl.form['name'],
            onChanged: (val) {
              formCtrl.setFormField('name', val);
            },
          )),
      Obx(() => TuFormField(
            label: "Collector Phone:",
            hint: "e.g. 0712345678",
            isRequired: true,
            keyboard: TextInputType.phone,
            value: formCtrl.form['phone'],
            onChanged: (val) {
              formCtrl.setFormField('phone', val);
            },
          )),
    ],
  );
}
