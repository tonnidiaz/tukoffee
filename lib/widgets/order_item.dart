// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:lebzcafe/controllers/appbar.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/functions2.dart";
import "package:lebzcafe/views/order/checkout.dart";
import "package:lebzcafe/views/order/index.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:get/get.dart";
import "package:lebzcafe/widgets/tu/common.dart";

import "../utils/colors.dart";
import "../utils/constants.dart";
import "../utils/functions.dart";
import "common.dart";
import "prompt_modal.dart";

class OrderItem extends StatelessWidget {
  final Map order;
  final bool isAdmin;
  final bool dev;
  final dynamic ctrl;
  final BuildContext tcontext;
  OrderItem(
      {super.key,
      required this.tcontext,
      required this.order,
      this.dev = true,
      required this.ctrl,
      this.isAdmin = false});

  void _selectItem(Map item) {
    var newList = !_appBarCtrl.selected.contains(item)
        ? [..._appBarCtrl.selected, item]
        : _appBarCtrl.selected.where((el) => el != item).toList();
    _appBarCtrl.setSelected(newList);
  }

  final AppBarCtrl _appBarCtrl = Get.find();

  _cancelOrder({bool del = false}) async {
    var act = del ? "delete" : "cancel";
    Get.dialog(PromptDialog(
      title: "Cancel order",
      msg: "Are you sure you want to cancel this order? ",
      okTxt: "Yes",
      onOk: () async {
        try {
          showProgressSheet(msg: "Canceling order..");

          if (order["mode"] == OrderMode.deliver.index) {
            //cancel from shiplogic first
            await Shiplogic.cancelOrder(order);
          }

          final res = await apiDio().post("/order/cancel?action=$act", data: {
            "ids": [order["_id"]],
            "userId": isAdmin ? null : MainApp.appCtrl.user["_id"]
          });

          _appBarCtrl.setSelected([]);
          await ctrl.setOrders(res.data["orders"]);
          gpop();
        } catch (e) {
          gpop();
          errorHandler(e: e, msg: "Failed to cancel order!");
        }
      },
    ));
  }

  final _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        key: _key,
        width: double.infinity,
        decoration: BoxDecoration(
            color: _appBarCtrl.selected.isNotEmpty &&
                    _appBarCtrl.selected.contains(order)
                ? const Color.fromARGB(37, 0, 89, 255)
                : cardBGLight,
            border: const Border(
                bottom: BorderSide(color: Color.fromRGBO(10, 10, 10, .05)))),
        child: ListTile(
          title: Text(
            "#${order["oid"]}",
            softWrap: false,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: tuColumn(
            children: [
              mY(5),
              Text(
                formatDate(order["date_created"]),
                style: TextStyle(
                    color: TuColors.note,
                    fontWeight: FontWeight.w500,
                    fontSize: 13),
              ),
              Chip(
                  backgroundColor: order["status"] == "cancelled"
                      ? TuColors.danger
                      : TuColors.medium,
                  label: Text(
                    "${order["status"]}",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  )),
              mY(10),
              Container(
                height: 35,
                alignment: Alignment.centerLeft,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: order["products"].length,
                    itemBuilder: (context, index) {
                      var item = order["products"][index]["product"];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: Material(
                          elevation: 0,
                          child: Container(
                            width: 40,
                            height: 35,
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              backgroundImage: item["images"].isEmpty
                                  ? null
                                  : Image.network(
                                      item["images"][0]["url"],
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                            child: SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ));
                                      },
                                    ).image,
                              child: item["images"].isEmpty
                                  ? svgIcon(
                                      name: "br-image-slash",
                                      size: 20,
                                      color: Colors.black54,
                                    )
                                  : none(),
                            ),
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
          trailing: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: TuColors.text2,
              ),
              splashRadius: 24,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      _cancelOrder();
                    },
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                ];
              }),
          onLongPress: () {
            _selectItem(order);
          },
          onTap: () async {
            if (_appBarCtrl.selected.isEmpty) {
              pushNamed("/order",
                  arguments: OrderPageArgs(id: "${order["oid"]}"));
            } else {
              _selectItem(order);
            }
          },
          isThreeLine: true,
        ),
      ),
    );
  }
}
