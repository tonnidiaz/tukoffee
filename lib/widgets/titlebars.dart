import 'package:flutter/material.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '/utils/functions.dart';

import 'common.dart';

PreferredSizeWidget MobileTitleBar(
    {PreferredSizeWidget? bottom, List<PopupMenuItem> actions = const []}) {
  final AppCtrl appCtrl = Get.find();
  return AppBar(
    titleSpacing: 0,
    toolbarHeight: appBarH,
    //leadingWidth: 35,
    leading: const CartBtn(),
    title: Obx(() => Text(appCtrl.storeName.value,
        style: GoogleFonts.lato(fontWeight: FontWeight.w900, fontSize: 16))),
    actions: [
      Container(
          margin: const EdgeInsets.only(right: 10),
          child: const EndDrawerButton())
    ],
    bottom: bottom,
  );
}

Widget ActionBtn(IconData icon, {Color? color, void Function()? onClick}) {
  const double iconSize = 16;
  return SizedBox(
    width: 35,
    height: 35,
    child: InkWell(
      mouseCursor: SystemMouseCursors.basic,
      enableFeedback: true,
      onTap: onClick,
      onTapDown: (e) {
        clog("ontap");
      },
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    ),
  );
}
