// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/appbar.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/dialogs/loading_dialog.dart';
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
  final BuildContext tcontext;
  OrderItem(
      {super.key,
      required this.tcontext,
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
                await sleep(1500);
                pop(tcontext);
                _appBarCtrl.setSelected([]);
                ctrl.setOrders(res.data['orders']);
              } catch (e) {
                pop(tcontext);
                errorHandler(
                    context: context, e: e, msg: "Failed to cancel order!");
              }
            },
          );
        });
  }

  final _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
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
              icon: Icon(
                Icons.more_vert,
                color: TuColors.text2,
              ),
              splashRadius: 24,
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
              pushNamed("/order",
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
