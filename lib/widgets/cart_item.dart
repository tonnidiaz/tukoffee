// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/dialog.dart';
import 'package:get/get.dart';

import '../controllers/products_ctrl.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'common.dart';

class CartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  CartItem({
    super.key,
    required this.item,
  });
  final ProductsCtrl _productsCtrl = Get.find();

  void _selectItem(Map<String, dynamic> product) {
    !_productsCtrl.selectedProducts.contains(product)
        ? _productsCtrl
            .set_selectedProducts([..._productsCtrl.selectedProducts, product])
        : _productsCtrl.set_selectedProducts(_productsCtrl.selectedProducts
            .where((el) => el != product)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formViewCtrl;
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

    void showEditSheet() {
      formCtrl.setForm({'quantity': item['quantity']});
      TuFuncs.showBottomSheet(
          context: context,
          widget: Container(
            color: cardBGLight,
            padding: defaultPadding,
            child: tuColumn(min: true, children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TuDropdownButton(
                        value: formCtrl.form['quantity'],
                        onChanged: (val) =>
                            {formCtrl.setFormField('quantity', val)},
                        items: List.generate(
                            prod["quantity"],
                            (index) =>
                                SelectItem("Qty: ${index + 1}", index + 1)),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        TuFuncs.showTDialog(
                            context,
                            TuDialogView(
                              title: 'Delete item',
                              okTxt: "Yes",
                              content: const Text(
                                  'Are you sure you want to remove this item?'),
                              onOk: () async {
                                await updateCart('remove', null);
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
                text: 'Save changes',
                width: double.infinity,
                bgColor: Colors.black87,
                onPressed: () async {
                  await updateCart('add', formCtrl.form['quantity']);
                },
              )
            ]),
          ));
    }

    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color.fromRGBO(10, 10, 10, .05)))),
        //height: 110,
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, "/product",
                arguments: {"pid": prod["pid"]});
          },
          //Checkbox, cover, content, deleteBtn
          tileColor: cardBGLight,
          contentPadding: EdgeInsets.symmetric(horizontal: 7),
          leading: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 70,
              height: 45,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item['product']['images'].isEmpty
                  ? const Icon(
                      Icons.coffee_outlined,
                      size: 45,
                      color: Colors.black54,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child:
                          Image.network(item['product']['images'][0]['url'])),
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
              Text(
                "R${prod["price"]}",
                style: TextStyle(
                    color: TuColors.text2,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
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
            () => _productsCtrl.selectedProducts.isNotEmpty
                ? SizedBox(
                    width: 30,
                    child: Checkbox(
                        activeColor: orange,
                        value: _productsCtrl.selectedProducts.contains(item),
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
