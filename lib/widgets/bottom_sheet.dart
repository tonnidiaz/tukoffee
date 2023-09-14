import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:get/get.dart';
import '../utils/colors.dart';
import '/utils/constants.dart';
import 'common.dart';

class TBottomSheet extends StatefulWidget {
  const TBottomSheet({Key? key}) : super(key: key);

  @override
  State<TBottomSheet> createState() => _TBottomSheetState();
}

class _TBottomSheetState extends State<TBottomSheet> {
  final AppCtrl _appCtrl = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: defaultPadding,
      height: bottomSheetH,
      decoration: const BoxDecoration(
          color: appBG,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          )),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._appCtrl.navItems,
                        NavItem(
                            text: "Exit",
                            onClick: () async {
                              SystemChannels.platform
                                  .invokeMethod('SystemNavigator.pop');
                            }),
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
