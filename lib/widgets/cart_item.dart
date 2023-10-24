// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:lebzcafe/controllers/store_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/views/order/index.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/dialog.dart";
import "package:get/get.dart";
import "package:lebzcafe/widgets/tu/common.dart";
import "package:lebzcafe/widgets/tu/form_field.dart";
import "package:lebzcafe/widgets/tu/select.dart";

import "../controllers/products_ctrl.dart";
import "../utils/colors.dart";
import "../utils/constants.dart";
import "common.dart";

class CartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  CartItem({
    super.key,
    required this.item,
  });
  final ProductsCtrl _productsCtrl = Get.find();
  final _appBarCtrl = MainApp.appBarCtrl;

  void _selectItem(Map<String, dynamic> product) {
    !_appBarCtrl.selected.contains(product)
        ? _appBarCtrl.setSelected([..._appBarCtrl.selected, product])
        : _appBarCtrl.setSelected(
            _appBarCtrl.selected.where((el) => el != product).toList());
  }

  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formCtrl;
    final prod = item["product"];
    final storeCtrl = Get.find<StoreCtrl>();

    updateCart(String act, dynamic val) async {
      clog(act);
      try {
        final res = await apiDio().post("/user/cart?action=$act",
            data: {"product": prod["_id"], "quantity": val});
        storeCtrl.setcart(res.data["cart"]);
        // t.dismiss();
        clog("Item quantity updated");
        Navigator.pop(context);
      } catch (e) {
        errorHandler(e: e, context: context);
      }
    }

    Widget editSheet() {
      return Container(
        color: cardBGLight,
        padding: defaultPadding,
        child: tuColumn(min: true, children: [
          Row(
            children: [
              Expanded(
                child: false
                    ? Obx(
                        () => TuFormField(
                          radius: 100,
                          hasBorder: false,
                          textAlign: TextAlign.center,
                          readOnly: true,
                          value: formCtrl.form["quantity"],
                          prefixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 16,
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              if (formCtrl.form["quantity"] > 0) {
                                formCtrl.form["quantity"]--;
                              } else {
                                formCtrl.form["quantity"] = 0;
                              }
                            },
                          ),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 16,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              formCtrl.form["quantity"]++;
                            },
                          ),
                        ),
                      )
                    : Obx(
                        () => TuSelect(
                          label: "Quantity:",
                          value: formCtrl.form["quantity"],
                          onChanged: (val) =>
                              {formCtrl.setFormField("quantity", val)},
                          items: List.generate(prod["quantity"],
                              (index) => SelectItem("${index + 1}", index + 1)),
                        ),
                      ),
              ),
              IconButton(
                  onPressed: () async {
                    TuFuncs.showTDialog(
                        context,
                        TuDialogView(
                          title: "Delete item",
                          okTxt: "Yes",
                          content: const Text(
                              "Are you sure you want to remove this item?"),
                          onOk: () async {
                            showProgressSheet();
                            await updateCart("remove", null);
                            gpop();
                          },
                        ));
                  },
                  icon: Icon(
                    Icons.delete,
                    color: TuColors.text2,
                  ))
            ],
          ),
          mY(4),
          TuButton(
            text: "Save changes",
            width: double.infinity,
            bgColor: Colors.black87,
            onPressed: () async {
              showProgressSheet();
              await updateCart("add", formCtrl.form["quantity"]);
              gpop();
            },
          )
        ]),
      );
    }

    void showEditSheet() {
      formCtrl.setForm({"quantity": item["quantity"]});
      TuFuncs.showBottomSheet(context: context, widget: editSheet());
    }

    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color.fromRGBO(10, 10, 10, .05)))),
        //height: 110,
        child: ListTile(
          onTap: () {
            pushNamed("/product", arguments: {"pid": prod["pid"]});
          },
          //Checkbox, cover, content, deleteBtn
          tileColor: cardBGLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 70,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item["product"]["images"].isEmpty
                  ? svgIcon(
                      name: "br-image-slash",
                      size: 25,
                      color: Colors.black54,
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            item["product"]["images"][0]["url"],
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                  child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ));
                            },
                          )),
                    ),
            ),
          ),

          title: Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Text(
              "${prod["name"]}",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          subtitle: Row(
            children: [
              Text("R${prod["price"]}  ",
                  style: TextStyle(
                      color: prod["on_sale"] ? TuColors.text2 : Colors.black87,
                      fontSize: prod["on_sale"] ? 12 : 14,
                      decoration:
                          prod["on_sale"] ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w600)),
              Visibility(
                visible: prod["on_sale"],
                child: Text(
                  "R${prod["sale_price"]}",
                  style: TextStyle(
                      color: TuColors.text2,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              mX(10),
              Text(
                "x${item["quantity"]}",
                style: TextStyle(
                    color: TuColors.text2,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
            ],
          ),
          trailing: Obx(
            () => _appBarCtrl.selected.isNotEmpty
                ? SizedBox(
                    width: 30,
                    child: Checkbox(
                        activeColor: orange,
                        value: _appBarCtrl.selected.contains(item),
                        onChanged: (val) {
                          _selectItem(item);
                        }),
                  )
                : IconButton(
                    splashRadius: 24,
                    onPressed: showEditSheet,
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                    )),
          ),
        ));
  }
}
