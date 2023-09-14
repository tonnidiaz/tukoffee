// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/appbar.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common2.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'common.dart';
import 'prompt_modal.dart';

class OrderItem extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isAdmin;
  final bool dev;
  final dynamic ctrl;
  OrderItem(
      {super.key,
      required this.order,
      this.dev = true,
      required this.ctrl,
      this.isAdmin = false});

  void _selectItem(Map<String, dynamic> item) {
    var newList = !_appBarCtrl.selected.contains(item)
        ? [..._appBarCtrl.selected, item]
        : _appBarCtrl.selected.where((el) => el != item).toList();
    _appBarCtrl.setSelected(newList);
  }

  final AppBarCtrl _appBarCtrl = Get.find();

  _cancelOrder(BuildContext context, {bool del = false}) async {
    showDialog(
        context: context,
        builder: (context) {
          var act = del ? "delete" : "cancel";
          return PromptModal(
            title: "${act.toUpperCase()} order",
            msg: "Are you sure you want to $act this order? ",
            okTxt: "Yes",
            onOk: () async {
              try {
                final res =
                    await apiDio().post("/order/cancel?action=$act", data: {
                  'ids': [order['_id']],
                  "userId": isAdmin ? null : MainApp.appCtrl.user['_id']
                });
                showToast("Order ${del ? "deleted" : "cancelled"}!")
                    .show(context);
                _appBarCtrl.setSelected([]);
                ctrl.setOrders(res.data['orders']);
              } catch (e) {
                if (e.runtimeType == DioException) {
                  e as DioException;
                  handleDioException(
                      context: context,
                      exception: e,
                      msg: "Failed to cancel order!");
                } else {
                  clog(e);
                  showToast("Failed to cancel order!", isErr: true)
                      .show(context);
                }
              }
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => TuCard(
        my: 2.5,
        onTap: () async {
          if (_appBarCtrl.selected.isEmpty) {
            Navigator.pushNamed(context, "/order",
                arguments: OrderPageArgs(id: "${order['oid']}"));
          } else {
            _selectItem(order);
          }
        },
        onLongPress: () {
          _selectItem(order);
        },
        child: TuListTile(
            leading: _appBarCtrl.selected.isNotEmpty
                ? TuLabeledCheckbox(
                    activeColor: orange,
                    value: _appBarCtrl.selected.contains(order),
                    onChanged: (val) {
                      _selectItem(order);
                    })
                : none(),
            title: Text(
              "#${order['oid']}",
              style: Styles.title(color: Colors.black87),
            ),
            subtitle: Builder(builder: (context) {
              String status = order['status'];
              Color? bgColor;
              Color? color;

              if (status == "pending") {
                bgColor = const Color.fromRGBO(255, 153, 0, 0.3);
                color = Colors.orange;
              } else if (status == "delivered") {
                bgColor = const Color.fromRGBO(76, 175, 80, .3);
                color = Colors.green;
              } else if (status == "cancelled") {
                bgColor = const Color.fromRGBO(244, 67, 54, .3);
                color = Colors.red;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    var dateCreated =
                        DateTime.parse(order['date_created']).toLocal();

                    return Text(
                      "$dateCreated",
                      style: const TextStyle(fontSize: 12),
                    );
                  }),
                  tuStatus(status, color: color, bgColor: bgColor),
                ],
              );
            }),
            trailing: Container(
                width: 23,
                alignment: Alignment.center,
                child: dev
                    ? PopupMenuButton(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              onTap: () {
                                _appBarCtrl.setSelected([]);
                                Navigator.pushNamed(context, "/order",
                                    arguments:
                                        OrderPageArgs(id: "${order['oid']}"));
                              },
                              child: iconText(
                                "View",
                                Icons.visibility,
                                alignment: MainAxisAlignment.start,
                                fontSize: 15,
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                _cancelOrder(context);
                              },
                              child: iconText(
                                "Cancel",
                                Icons.cancel,
                                alignment: MainAxisAlignment.start,
                                fontSize: 15,
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                _cancelOrder(context, del: true);
                              },
                              child: iconText(
                                "Delete",
                                Icons.delete,
                                iconColor: Colors.red,
                                labelColor: Colors.red,
                                alignment: MainAxisAlignment.start,
                                fontSize: 15,
                              ),
                            ),
                          ];
                        })
                    : IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add_shopping_cart_outlined,
                          color: Colors.white70,
                        ))))));
  }
}

Widget tuStatus(String text, {Color? bgColor, Color? color, double? fontSize}) {
  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: bgColor ?? const Color.fromRGBO(41, 41, 41, .3),
          borderRadius: BorderRadius.circular(100)),
      child: Text(
        text,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: fontSize),
      ));
}
