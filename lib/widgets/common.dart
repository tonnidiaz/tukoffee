import "dart:core";
import "package:flutter/material.dart";
import "package:tu/tu.dart";
import "../controllers/app_ctrl.dart";
import "../controllers/appbar.dart";
import "../utils/colors.dart";
import "common2.dart";

PreferredSizeWidget childAppbar(
    {String? title,
    bool showCart = true,
    double? height,
    List<Widget> actions = const []}) {
  final AppCtrl appCtrl = Get.find();
  final AppBarCtrl appBarCtrl = Get.find();
  return PreferredSize(
    preferredSize: Size.fromHeight(height ?? appBarH),
    child: Obx(
      () => AppBar(
        leadingWidth: appBarH - 5,
        //titleSpacing: 5,
        leading: appBarCtrl.selected.isNotEmpty
            ? IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: () {
                  appBarCtrl.setSelected([]);
                },
                icon: const Icon(Icons.close))
            : null,
        title: appBarCtrl.selected.isNotEmpty
            ? Text(
                "${appBarCtrl.selected.length} selected",
              )
            : Text(title ?? appCtrl.store["name"]),
        actions: [
          showCart
              ? const CartBtn(
                  top: 15,
                )
              : none(),
          ...actions,
          // mX(8)
        ],
      ),
    ),
  );
}

Widget navItem({String text = "", void Function()? onClick}) {
  return InkWell(
    onTap: onClick,
    child: Container(
      width: double.infinity,
      //color: const Color.fromRGBO(30, 30, 30, .2),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(fontSize: 15),
      ),
    ),
  );
}

Widget TDrawerItem(
    {required String title,
    required int index,
    Widget? leading,
    bool selected = false,
    Function()? onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selectedTileColor: const Color.fromRGBO(225, 106, 6, .20),
      selectedColor: orange,
      selected: selected,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      onTap: onTap,
    ),
  );
}

class OptionsBtn extends PopupMenuButton {
  const OptionsBtn({super.key, required super.itemBuilder});
}
