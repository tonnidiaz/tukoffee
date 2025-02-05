// ignore_for_file: use_build_context_synchronously

import "dart:io";

import "package:cloudinary/cloudinary.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:tu/functions.dart";
import "package:tu/tu.dart";
import "../main.dart";
import "../utils/constants.dart";
import "../utils/constants2.dart";
import "../utils/functions.dart";
import "../views/order/index.dart";

import "common2.dart";
import "form_view.dart";

class AddProductForm extends StatefulWidget {
  final String title;
  final String btnTxt;
  final String mode;
  final Function(dynamic res)? onDone;
  const AddProductForm(
      {super.key,
      this.title = "Add product",
      this.btnTxt = "Add product",
      this.onDone,
      this.mode = "add"});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _innerController = ScrollController();
  final _appCtrl = MainApp.appCtrl;
  final _formCtrl = MainApp.formCtrl;

  @override
  void dispose() {
    _innerController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _formCtrl.clear();
    });
    super.dispose();
  }

  void _onUpload(int p0, int p1) {
    var percentage = (p0 / p1) * 100;
    clog("Percentage: $percentage%");
  }

  void _uploadImg(File file, int index) async {
    try {
      final res = await cloudinary.unsignedUpload(
          uploadPreset: uploadPreset,
          file: file.path,
          publicId:
              "${_appCtrl.store["name"]}_-_product_-_epoch-${DateTime.now().millisecondsSinceEpoch}",
          resourceType: CloudinaryResourceType.image,
          folder: getCloudinaryFolder(storeName: _appCtrl.store["name"]),
          progressCallback: _onUpload);
      if (res.isResultOk) {
        var existingImgs = _formCtrl.form["images"] ?? [];
        if (widget.mode == "edit") {
          // immediately update product images

          try {
            clog("Adding image to backend...");
            var newImgs = [
              ...existingImgs,
              {"url": res.secureUrl, "publicId": res.publicId}
            ];
            await apiDio().post("/products/edit",
                data: {"pid": _formCtrl.form["pid"], "images": newImgs});
            _formCtrl.setFormField("images", newImgs);
            _formCtrl.tempImgs[index] = {
              ..._formCtrl.tempImgs[index],
              "loading": false
            };
          } catch (e) {
            _formCtrl.tempImgs.removeAt(index);
            // delete image cloudinary
            await signedCloudinary.destroy(res.publicId);
            if (e.runtimeType == DioException) {
              handleDioException(
                  context: context,
                  exception: e as DioException,
                  msg: "Failed to add image to database");
            } else {
              clog(e);
              showToast("Failed to add image to database", isErr: true)
                  .show(context);
            }
          }
        } else {
          // Is adding
          _formCtrl.setFormField("images", [
            ...existingImgs,
            {"url": res.secureUrl, "publicId": res.publicId}
          ]);
          _formCtrl.tempImgs[index] = {
            ..._formCtrl.tempImgs[index],
            "loading": false
          };
        }
      } else {
        showToast(res.error!).show(context);
      }
    } catch (e) {
      if (e.runtimeType == DioException) {
        handleDioException(
            context: context,
            exception: e as DioException,
            msg: "Failed to upload image");
      } else {
        clog(e);
        showToast("Failed to upload image", isErr: true).show(context);
      }
    }
  }

  void _importImg() async {
    // Request storage permission
    if (Platform.isAndroid || Platform.isIOS) {
      await requestStoragePermission();
    }
    final file = await importFile(
        dialogTitle: "Import image file", type: FileType.image);
    if (file != null) {
      _formCtrl.setTempImgs([
        ..._formCtrl.tempImgs,
        {"file": file, "loading": true}
      ]);
      _uploadImg(file, _formCtrl.tempImgs.length - 1);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var formImgs = _formCtrl.form["images"];
      if (widget.mode == "edit") {
        _formCtrl.setTempImgs(formImgs);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FormView(
          title: widget.title,
          btnTxt: widget.btnTxt,
          fields: [
            TuFormField(
              label: "Product name:",
              hint: "Enter product name...",
              value: _formCtrl.form["name"],
              required: true,
              onChanged: (val) {
                _formCtrl.setFormField("name", val);
              },
            ),
            TuFormField(
              label: "Product description:",
              hint: "Enter product description...",
              value: _formCtrl.form["description"],
              required: true,
              onChanged: (val) {
                _formCtrl.setFormField("description", val);
              },
            ),
            TuFormField(
              label: "Price:",
              prefix: const Text("R "),
              hint: "Enter product price...",
              value: _formCtrl.form["price"],
              required: true,
              validator: (val) {
                bool isNum = isNumeric(val);
                if (!isNum || (isNum && double.parse(val!) < 0)) {
                  return "Enter a valid positive number";
                }
                return null;
              },
              keyboard: TextInputType.number,
              onChanged: (val) {
                _formCtrl.setFormField("price", val);
              },
            ),
            LayoutBuilder(builder: (context, c) {
              return Column(
                children: [
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TuFormField(
                          width: (c.maxWidth / 2) - 2.5,
                          label: "Quantity:",
                          hint: "Enter product quantity...",
                          value: _formCtrl.form["quantity"],
                          required: true,
                          validator: (val) {
                            bool isNum = isNumeric(val);
                            if (!isNum || (isNum && double.parse(val!) < 0)) {
                              return "Enter a valid positive number";
                            }
                            return null;
                          },
                          keyboard: TextInputType.number,
                          onChanged: (val) {
                            _formCtrl.setFormField("quantity", val);
                          },
                        ),
                        TuFormField(
                          width: (c.maxWidth / 2) - 2.5,
                          label: "Weight:",
                          keyboard: TextInputType.number,
                          hint: "Weight in KG...",
                          value: _formCtrl.form["weight"],
                          required: true,
                          suffix: const Text("KG"),
                          onChanged: (val) {
                            _formCtrl.setFormField("weight", val);
                          },
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => _formCtrl.form["on_sale"] == true
                        ? TuFormField(
                            label: "Sale price:",
                            prefix: const Text("R "),
                            hint: "Enter sale price...",
                            value: _formCtrl.form["sale_price"],
                            required: true,
                            validator: (val) {
                              bool isNum = isNumeric(val);
                              if (!isNum || (isNum && double.parse(val!) < 0)) {
                                return "Enter a valid positive number";
                              }
                              return null;
                            },
                            keyboard: TextInputType.number,
                            onChanged: (val) {
                              _formCtrl.setFormField("sale_price", val);
                            },
                          )
                        : none(),
                  ),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TuFormField(
                          label: "Width:",
                          width: (c.maxWidth / 2) - 2.5,
                          keyboard: TextInputType.number,
                          hint: "Width in cm...",
                          value: _formCtrl.form["width"],
                          required: true,
                          suffix: const Text("cm"),
                          onChanged: (val) {
                            _formCtrl.setFormField("width", val);
                          },
                        ),
                        TuFormField(
                          label: "Height:",
                          width: (c.maxWidth / 2) - 2.5,
                          keyboard: TextInputType.number,
                          hint: "Height in cm...",
                          value: _formCtrl.form["height"],
                          required: true,
                          suffix: const Text("cm"),
                          onChanged: (val) {
                            _formCtrl.setFormField("height", val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Obx(
                    () => TuLabeledCheckbox(
                        radius: 50,
                        label: "Top selling",
                        value: _formCtrl.form["top_selling"] == true,
                        onChanged: (val) {
                          _formCtrl.setFormField("top_selling", val);
                        }),
                  ),
                  Obx(
                    () => TuLabeledCheckbox(
                        radius: 50,
                        label: "On special",
                        value: _formCtrl.form["on_special"] == true,
                        onChanged: (val) {
                          _formCtrl.setFormField("on_special", val);
                        }),
                  ),
                  Obx(
                    () => TuLabeledCheckbox(
                        radius: 50,
                        label: "On sale",
                        value: _formCtrl.form["on_sale"] == true,
                        onChanged: (val) {
                          _formCtrl.setFormField("on_sale", val);
                        }),
                  ),
                ],
              ),
            ),
            mY(5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tuTableRow(
                    const Text("Product Images"),
                    IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 24,
                        onPressed: () {
                          _importImg();
                        },
                        icon: const Icon(Icons.add_outlined))),
                Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final offset = event.scrollDelta.dy;
                      _innerController.jumpTo(_innerController.offset + offset);
                      // outerController.jumpTo(outerController.offset - offset);
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _innerController,
                    scrollDirection: Axis.horizontal,
                    child: Obx(() => Row(
                          children: _formCtrl.tempImgs.asMap().entries.map((e) {
                            return imgCard(
                                context: context,
                                index: e.key,
                                mode: widget.mode,
                                child: e.value["url"] != null
                                    ? Image.network(e.value["url"])
                                    : Image.file(e.value["file"]),
                                uploading: e.value["url"] != null
                                    ? false
                                    : e.value["loading"]);
                          }).toList(),
                        )),
                  ),
                ),
              ],
            ),
            mY(10)
          ],
          useBottomSheet: true,
          onSubmit: () async {
            if (true) {
              showProgressSheet();
              final res = await addEditProduct(context, {..._formCtrl.form},
                  mode: widget.mode);
              if (res != null) {
                /*   showToast("Successs!").show(context);
                return; */
                gpop();
                if (widget.mode == 'edit') {
                  if (widget.onDone != null) {
                    await widget.onDone!(res);
                  }
                  gpop();

                  return;
                }
                Get.offAllNamed("/");
                pushNamed("/product", arguments: {"pid": res['pid']});
              }
            }
          }),
    );
  }
}
