import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "../utils/constants.dart";
import "/utils/functions.dart";
import "package:via_logger/logger.dart";

PreferredSizeWidget mobileTitleBar(
    {required BuildContext context,
    PreferredSizeWidget? bottom,
    List<PopupMenuItem> actions = const []}) {
  final AppCtrl appCtrl = Get.find();
  return AppBar(
    toolbarHeight: appBarH,
    //leadingWidth: 35,
    title: Obx(() => Text(appCtrl.store["name"],
        style: GoogleFonts.lato(fontWeight: FontWeight.w900, fontSize: 16))),
    actions: [const CartBtn(), mX(14)],
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
        Logger.info("ontap");
      },
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    ),
  );
}
