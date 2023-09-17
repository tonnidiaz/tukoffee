// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:frust/controllers/appbar.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/widgets/common.dart';
import 'package:get/get.dart';

import '../utils/constants2.dart';
import '../utils/styles.dart';

class CartBtn extends StatelessWidget {
  final double top;
  const CartBtn({super.key, this.top = 12});

  @override
  Widget build(BuildContext context) {
    final storeCtrl = Get.find<StoreCtrl>();
    return Obx(() => Container(
        color: Colors.transparent,
        width: 35 + 10,
        alignment: Alignment.center,
        height: appBarH,
        child: Stack(
          children: [
            Builder(builder: (context) {
              return IconButton(
                splashRadius: 25,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pushNamed(context, "/cart");
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 30,
                  // color: Colors.white,
                ),
              );
            }),
            Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  child: storeCtrl.cart.isEmpty
                      ? const Text(
                          "0",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          "${storeCtrl.cart["products"].length}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ))
          ],
        )));
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
              mX(5),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title ?? none(), subtitle ?? none()],
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
      this.fontWeight,
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
      child: SizedBox(
        width: 25,
        child: Checkbox(
            value: value,
            activeColor: activeColor ?? Colors.orange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            onChanged: onChanged),
      ),
    );
    final lbl = label != null
        ? Text(
            label!,
            style: TextStyle(fontWeight: fontWeight),
          )
        : none();
    return labelPos == Position.right
        ? Row(
            children: [check, lbl],
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

PreferredSizeWidget childAppbar0({String? title, bool showCart = true}) {
  final AppCtrl appCtrl = Get.find();
  final AppBarCtrl appBarCtrl = Get.find();
  return PreferredSize(
    preferredSize: const Size.fromHeight(appBarH),
    child: Obx(
      () => AppBar(
        centerTitle: appBarCtrl
            .selected.isEmpty, //appBarCtrl.selected.isNotEmpty ? false : true,
        leading: SizedBox(
            width: 35,
            child: appBarCtrl.selected.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                    onPressed: () {
                      appBarCtrl.setSelected([]);
                    },
                    icon: const Icon(Icons.close))
                : Builder(builder: (context) {
                    return IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back));
                  })),

        title: appBarCtrl.selected.isNotEmpty
            ? Text(
                "${appBarCtrl.selected.length} selected",
                style: const TextStyle(fontWeight: FontWeight.w500),
              )
            : title != null
                ? Text(title)
                : Text(
                    appCtrl.store['name'],
                  ),

        actions: [
          appBarCtrl.selected.isNotEmpty
              ? SizedBox(
                  width: 25,
                  child: (PopupMenuButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      itemBuilder: (context) {
                        return [...appBarCtrl.selectedActions];
                      })),
                )
              : showCart
                  ? const CartBtn(
                      top: 15,
                    )
                  : none(),
          mX(8)
        ],
      ),
    ),
  );
}

PreferredSizeWidget childAppbar(
    {String? title, bool showCart = true, double height = appBarH}) {
  final AppCtrl appCtrl = Get.find();
  final AppBarCtrl appBarCtrl = Get.find();
  return PreferredSize(
    preferredSize: Size.fromHeight(height),
    child: Obx(
      () => AppBar(
        backgroundColor: appBGLight,
        centerTitle: appBarCtrl
            .selected.isEmpty, //appBarCtrl.selected.isNotEmpty ? false : true,
        leadingWidth: appBarH - 5,
        leading: appBarCtrl.selected.isNotEmpty
            ? IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: () {
                  appBarCtrl.setSelected([]);
                },
                icon: const Icon(Icons.close))
            : Builder(builder: (context) {
                return Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const TuBackButton());
              }),

        title: appBarCtrl.selected.isNotEmpty
            ? Text(
                "${appBarCtrl.selected.length} selected",
                style: const TextStyle(fontWeight: FontWeight.w500),
              )
            : Text(title ?? appCtrl.store['name']),

        actions: [
          appBarCtrl.selected.isNotEmpty
              ? SizedBox(
                  width: 25,
                  child: (PopupMenuButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      itemBuilder: (context) {
                        return [...appBarCtrl.selectedActions];
                      })),
                )
              : showCart
                  ? const CartBtn(
                      top: 15,
                    )
                  : none(),
          mX(8)
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
                  child: const Text(
                    "...",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )),
              )
            ],
          )));
}

class TuFormField extends StatefulWidget {
  final String? label;
  final String hint;
  final dynamic value;
  final Widget? suffix;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function(Function)? onShowHidePass;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool isPass;
  final bool showEye;
  final bool hasBorder;
  final TextInputType keyboard;
  final double? radius;
  final double height;
  final double my;
  final bool isLegacy;
  final bool readOnly;
  final int maxLines;
  final double? width;
  final int? maxLength;
  final TextAlign textAlign;
  final FloatingLabelAlignment? labelAlignment;
  final Function()? onTap;
  final FocusNode? focusNode;
  final Color? fill;
  const TuFormField(
      {super.key,
      this.label,
      this.my = 5,
      this.focusNode,
      this.suffixIcon,
      this.suffix,
      this.onSubmitted,
      this.width,
      this.prefixIcon,
      this.prefix,
      this.onTap,
      this.hint = "",
      this.value,
      this.radius = 5,
      this.height = 15,
      this.maxLines = 1,
      this.maxLength,
      this.onChanged,
      this.onShowHidePass,
      this.isRequired = false,
      this.isLegacy = false,
      this.readOnly = false,
      this.isPass = false,
      this.showEye = true,
      this.hasBorder = false,
      this.validator,
      this.fill,
      this.textAlign = TextAlign.start,
      this.labelAlignment,
      this.keyboard = TextInputType.name});

  @override
  State<TuFormField> createState() => _TuFormFieldState();
}

class _TuFormFieldState extends State<TuFormField> {
  final _controller = TextEditingController();
  bool _showPass = false;
  void _updateVal() {
    if (widget.value == null) {
      _controller.text = "";
    } else if (widget.value != _controller.text) {
      _controller.text = "${widget.value}";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateVal();
    });
    final border = OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(widget.radius!));
    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.my),
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.hasBorder && widget.isLegacy
              ? Text(widget.label!, style: Styles.label())
              : none(),
          TextFormField(
            textAlign: widget.textAlign,
            maxLength: widget.maxLength,
            readOnly: widget.readOnly,
            controller: _controller,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onSubmitted,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            obscureText: widget.isPass && !_showPass,
            maxLines: widget.maxLines,
            validator: widget.validator ??
                (val) {
                  String? msg;
                  if ((widget.isRequired && val != null && val.isEmpty) ||
                      val == null) {
                    msg = "Field is required!";
                  }
                  return msg;
                },
            keyboardType: widget.keyboard,
            decoration: InputDecoration(
              fillColor: widget.fill ?? TuColors.fieldBG,
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: widget.height,
                horizontal: 10,
              ),
              prefixIcon: widget.prefixIcon,
              prefix: widget.prefix,
              suffix: widget.suffix,
              suffixIcon: widget.isPass && widget.showEye
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        //SHowHide pass

                        if (!_showPass && widget.onShowHidePass != null) {
                          // Pass hidden and the event handler is provided
                          // Invoke the handler
                          void setShowPass(bool val) {
                            setState(() {
                              _showPass = val;
                            });
                          }

                          await widget.onShowHidePass!(setShowPass);
                        } else {
                          setState(() {
                            _showPass = !_showPass;
                          });
                        }
                      },
                      icon: Icon(!_showPass
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash))
                  : widget.suffixIcon,
              labelText:
                  !widget.hasBorder || !widget.isLegacy ? widget.label : null,
              hintText: widget.hint,
              floatingLabelAlignment: widget.labelAlignment,
              floatingLabelStyle:
                  const TextStyle(color: Colors.black87, fontSize: 18),
              enabledBorder: widget.radius != null ? border : null,
              focusedBorder: widget.radius != null ? border : null,
              focusedErrorBorder: widget.radius != null ? border : null,
              errorBorder: widget.radius != null ? border : null,
              border: widget.radius != null ? border : null,
            ),
          ),
        ],
      ),
    );
  }
}

class TuBackButton extends StatelessWidget {
  const TuBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black12,
      foregroundColor: const Color.fromRGBO(50, 50, 50, .9),
      child: IconButton(
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.chevron_left,
            size: 30,
          )),
    );
  }
}
