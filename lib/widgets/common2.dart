// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:lebzcafe/controllers/store_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:tu/tu.dart";
import "../utils/constants2.dart";

class CartBtn extends StatelessWidget {
  final double top;
  const CartBtn({super.key, this.top = 12});

  @override
  Widget build(BuildContext context) {
    final storeCtrl = Get.find<StoreCtrl>();
    return Obx(() {
      int c = (storeCtrl.cart.isEmpty ? 0 : storeCtrl.cart["products"].length);
      return SizedBox(
          width: c < 100 ? 50 : 65,
          child: IconButton(
              splashRadius: 23,
              onPressed: () {
                pushNamed("/cart");
              },
              icon: Badge(
                label: Text(c < 100 ? "$c" : "99+"),
                textColor: Colors.white,
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                backgroundColor: colors.primary,
                child: svgIcon(
                  name: "rr-shopping-basket",
                  color: colors.text2,
                  size: 24,
                ),
              )));
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

Container imgCard(
    {Widget? child,
    required BuildContext context,
    required String mode,
    Function()? onTap,
    bool uploading = false,
    bool canRemove = true,
    required int index}) {
  final formViewCtrl = MainApp.formCtrl;
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
                          img["publicId"],
                        );
                        clog(formViewCtrl.form["images"].length);
                        var tempImgs = [...formViewCtrl.form["images"]];
                        tempImgs.removeAt(index);
                        clog(res.result);
                        if (mode == "edit" || res.result == "not found") {
                          final res2 = await addEditProduct(
                              context,
                              {
                                "images": tempImgs,
                                "pid": formViewCtrl.form["pid"]
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
          color: colors.text2,
          size: 30,
        ));
  }
}
