import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/map.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/tu/multiselect.dart';
import 'package:get/get.dart';

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  final _storeCtrl = MainApp.storeCtrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: childAppbar(showCart: false),
      body: Container(
          padding: defaultPadding,
          child: Column(
            children: [
              TuButton(
                text: "Go to map",
                onPressed: () {
                  pushNamed(context, '/map',
                      args: const MapPageArgs(center: [-26.193954, 28.057857]));
                },
              ),
              Obx(
                () => _storeCtrl.stores.value == null
                    ? none()
                    : TuMultiselect(
                        dialogTitle: "Stores",
                        onOk: (val) {
                          clog(val);
                        },
                        items: _storeCtrl.stores.value!
                            .map((it) => TuMultiselectDialogItem(
                                label: it['location']['name'], it: it))
                            .toList(),
                      ),
              ),
            ],
          )),
    );
  }
}
