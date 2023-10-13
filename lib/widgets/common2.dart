// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/controllers/appbar.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants2.dart';
import '../utils/styles.dart';

class CartBtn extends StatelessWidget {
  final double top;
  const CartBtn({super.key, this.top = 12});

  @override
  Widget build(BuildContext context) {
    final storeCtrl = Get.find<StoreCtrl>();
    return Obx(() {
      int c = false
          ? 100
          : (storeCtrl.cart.isEmpty ? 0 : storeCtrl.cart['products'].length);
      return SizedBox(
        width: c < 100 ? 50 : 65,
        child: IconButton(
            splashRadius: 23,
            onPressed: () {
              pushNamed(context, '/cart');
            },
            icon: Badge(
              label: Text(c < 100 ? "$c" : "99+"),
              textColor: Colors.white,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              backgroundColor: TuColors.primary,
              child: svgIcon(
                name: 'rr-shopping-basket',
                color: TuColors.text2,
                size: 24,
              ),
            )),
      );
    });
  }
}

class TuListTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  const TuListTile(
      {super.key, this.title, this.subtitle, this.leading, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Row(
            children: [
              leading ?? none(),
              mX(10),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title ?? none(), mY(6), subtitle ?? none()],
                  ),
                ),
              ),
            ],
          ),
        ),
        mX(5),
        trailing ?? none()
      ]),
    );
  }
}

enum Position { top, bottom, right }

class TuLabeledCheckbox extends StatelessWidget {
  final bool value;
  final double radius;
  final Function(bool?) onChanged;
  final String? label;
  final Position labelPos;
  final Color? activeColor;
  final FontWeight? fontWeight;
  const TuLabeledCheckbox(
      {super.key,
      this.fontWeight = FontWeight.w600,
      this.label,
      this.activeColor,
      this.value = false,
      this.radius = 5,
      this.labelPos = Position.right,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final check = Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 25,
      child: Checkbox(
          value: value,
          activeColor: activeColor ?? TuColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          onChanged: onChanged),
    );
    final lbl = label != null
        ? Text(
            label!,
            style: TextStyle(
                fontSize: 14, fontWeight: fontWeight, color: TuColors.text2),
          )
        : none();
    return labelPos == Position.right
        ? Row(
            children: [check, lbl],
            mainAxisSize: MainAxisSize.min,
          )
        : labelPos == Position.bottom
            ? Column(
                children: [check, lbl],
              )
            : Column(
                children: [lbl, check],
              );
  }
}

PreferredSizeWidget childAppbar(
    {String? title,
    bool showCart = true,
    double height = appBarH,
    List<Widget> actions = const []}) {
  final AppCtrl appCtrl = Get.find();
  final AppBarCtrl appBarCtrl = Get.find();
  return PreferredSize(
    preferredSize: Size.fromHeight(height),
    child: Obx(
      () => AppBar(
        elevation: .4,
        backgroundColor: cardBGLight,
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
                style: GoogleFonts.karla(fontWeight: FontWeight.w500),
              )
            : Text(title ?? appCtrl.store['name']),
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

Container imgCard(
    {Widget? child,
    required BuildContext context,
    required String mode,
    Function()? onTap,
    bool uploading = false,
    bool canRemove = true,
    required int index}) {
  final formViewCtrl = MainApp.formViewCtrl;
  double width = 60;
  return Container(
      width: width,
      height: width,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 224, 224),
          borderRadius: BorderRadius.circular(2)),
      child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              child ?? none(),
              Visibility(
                visible: !uploading && canRemove,
                child: Positioned(
                    child: Container(
                  color: const Color.fromRGBO(0, 0, 0, .5),
                  width: width,
                  height: width,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      // delete and remove the img from the list
                      var toast =
                          showToast("Deleting image...", autoDismiss: false);
                      var img =
                          formViewCtrl.form["images"][index]; // {url, publicId}
                      toast.show(context);
                      try {
                        clog("Deleting from cloudinary...");
                        var res = await signedCloudinary.destroy(
                          img['publicId'],
                        );
                        clog(formViewCtrl.form['images'].length);
                        var tempImgs = [...formViewCtrl.form['images']];
                        tempImgs.removeAt(index);
                        clog(res.result);
                        if (mode == "edit" || res.result == "not found") {
                          final res2 = await addProduct(
                              context,
                              {
                                "images": tempImgs,
                                "pid": formViewCtrl.form['pid']
                              },
                              mode: mode);
                          if (res2 != null) {
                            formViewCtrl.tempImgs.removeAt(index);
                          }
                        }
                        if (res.isSuccessful) {
                          clog("Image deleted successfully!");
                        }
                        toast.dismiss();
                      } catch (e) {
                        clog(e);
                        toast.dismiss();
                        showToast("Failed to delete image").show(context);
                      }
                    },
                  ),
                )),
              ),
              Visibility(
                visible: uploading,
                child: Positioned(
                    child: Container(
                  color: Colors.white60,
                  alignment: Alignment.center,
                  child: Text(
                    "...",
                    style: GoogleFonts.karla(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )),
              )
            ],
          )));
}

class TuBackButton extends StatelessWidget {
  const TuBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_outlined,
          color: TuColors.text2,
          size: 30,
        ));
  }
}
