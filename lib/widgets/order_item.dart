// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/appbar.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/dialogs/loading_dialog.dart';
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
          return PromptDialog(
            title: "Cancel order",
            msg: "Are you sure you want to cancel this order? ",
            okTxt: "Yes",
            onOk: () async {
              try {
                showLoading(
                    context, const LoadingDialog(msg: 'Canceling order..'));
                final res =
                    await apiDio().post("/order/cancel?action=$act", data: {
                  'ids': [order['_id']],
                  "userId": isAdmin ? null : MainApp.appCtrl.user['_id']
                });
                pop(context);
                _appBarCtrl.setSelected([]);
                ctrl.setOrders(res.data['orders']);
              } catch (e) {
                pop(context);

                errorHandler(
                    context: context, e: e, msg: "Failed to cancel order!");
              }
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: _appBarCtrl.selected.isNotEmpty &&
                    _appBarCtrl.selected.contains(order)
                ? TuColors.primaryFade
                : null,
            border: const Border(
                bottom: BorderSide(color: Color.fromRGBO(10, 10, 10, .05)))),
        child: ListTile(
          title: Text(
            "#${order['oid']}",
            softWrap: false,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Text(
                "${DateTime.parse(order["date_created"]).toLocal()}"
                    .split(' ')
                    .first,
                style: TextStyle(
                    color: TuColors.note,
                    fontWeight: FontWeight.w500,
                    fontSize: 13),
              ),
              mX(10),
              Chip(
                  backgroundColor: order['status'] == 'pending'
                      ? TuColors.medium
                      : order['status'] == 'cancelled'
                          ? TuColors.danger
                          : TuColors.success,
                  label: Text(
                    '${order['status']}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ))
            ],
          ),
          trailing: PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              splashRadius: 24,
              //  padding: EdgeInsets.zero,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      _cancelOrder(context);
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
              Navigator.pushNamed(context, "/order",
                  arguments: OrderPageArgs(id: "${order['oid']}"));
            } else {
              _selectItem(order);
            }
          },
        ),
      ),
    );
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
