/* // ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:get/get.dart';
import '../controllers/appbar.dart';
import '../main.dart';
import '../widgets/order_item.dart';
import '../widgets/prompt_modal.dart';

class OrdersCtrl extends GetxController {
  RxBool ordersFetched = false.obs;
  setOrdersFetched(bool val) {
    ordersFetched.value = val;
  }

  RxList<dynamic> orders = <dynamic>[].obs;
  setOrders(List<dynamic> val) {
    orders.value = val;
    selectedOrders.value = [];
    _sortOrders(orders);
  }

  Rx<SortBy> sortBy = SortBy.dateCreated.obs;
  void setSortBy(SortBy val) {
    sortBy.value = val;
    _sortOrders(orders);
  }

  Rx<SortOrder> sortOrder = SortOrder.ascending.obs;
  void setSortOrder(SortOrder val) {
    sortOrder.value = val;
    _sortOrders(orders);
  }

  RxList<dynamic> selectedOrders = [].obs;
  void setSelectedOrders(List<dynamic> val) {
    selectedOrders.value = val;
  }

  RxList<dynamic> sortedOrders = [].obs;
  void setsortedOrders(List<dynamic> val) {
    sortedOrders.value = val;
  }

  Rx<OrderStatus> status = OrderStatus.all.obs;
  void setStatus(OrderStatus val) {
    status.value = val;
    // filter the sorted orders based on the status
    var ords = [];
    switch (val) {
      case OrderStatus.pending:
        ords = orders.where((it) => it['status'] == 'pending').toList();
        break;
      case OrderStatus.delivered:
        ords = orders.where((it) => it['status'] == 'delivered').toList();
        clog("Delivered only");
        break;
      case OrderStatus.cancelled:
        ords = orders.where((it) => it['status'] == 'cancelled').toList();
        break;
      default:
        ords = orders;
        break;
    }
    _sortOrders(ords);
  }

  void _sortOrders(List<dynamic> orders) {
    int dateInMs(String strDate) {
      var date = DateTime.parse(strDate);
      return date.millisecondsSinceEpoch;
    }

    int sorter(a, b) {
      int s = 1;
      final sortBy = this.sortBy.value;
      final sortOrder = this.sortOrder.value;
      switch (sortBy) {
        case SortBy.lastModified:
          s = sortOrder == SortOrder.ascending
              ? dateInMs(a['last_modified'])
                  .compareTo(dateInMs(b['last_modified']))
              : dateInMs(b['last_modified'])
                  .compareTo(dateInMs(a['last_modified']));
          break;
        case SortBy.dateCreated:
          s = sortOrder == SortOrder.ascending
              ? dateInMs(a['date_created'])
                  .compareTo(dateInMs(b['date_created']))
              : dateInMs(b['date_created'])
                  .compareTo(dateInMs(a['date_created']));
          break;
        default:
          break;
      }
      return s;
    }

    sortedOrders.value = orders;
    sortedOrders.sort(sorter);
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrdersCtrl _ctrl = Get.find();
  final AppCtrl _appCtrl = Get.find();
  final AppBarCtrl _appBarCtrl = Get.find();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // deselect
      _appBarCtrl.setSelected([]);
    });
    super.dispose();
  }

  _init() async {
    _appBarCtrl.setSelectedActions([
      PopupMenuItem(
          onTap: () {
            _cancelOrders();
          },
          padding: EdgeInsets.zero,
          child: iconText("Cancel", Icons.cancel)),
      PopupMenuItem(
          onTap: () {
            _cancelOrders(del: true);
          },
          padding: EdgeInsets.zero,
          child: iconText("Delete", Icons.delete,
              iconColor: Colors.red, labelColor: Colors.red)),
    ]);
    await _getOrders();
  }

  _cancelOrders({bool del = false}) async {
    showDialog(
        context: context,
        builder: (context) {
          var act = del ? "delete" : "cancel";
          return PromptModal(
            title: "${act.toUpperCase()} orders",
            msg: "Are you sure you want to $act the selected orders? ",
            okTxt: "Yes",
            onOk: () async {
              try {
                // Deselect all
                final List<dynamic> ids =
                    _appBarCtrl.selected.map((it) => it['_id']).toList();
                _appBarCtrl.setSelected([]);

                final res = await apiDio().post(
                    "/order/cancel?action=${act.toLowerCase()}",
                    data: {'ids': ids, "userId": MainApp.appCtrl.user['_id']});
                showToast("Orders ${del ? "deleted" : "cancelled"}!")
                    .show(context);
                _ctrl.setOrders(res.data['orders']);
              } catch (e) {
                if (e.runtimeType == DioException) {
                  e as DioException;
                  handleDioException(
                      context: context,
                      exception: e,
                      msg: "Failed to cancel orders!");
                } else {
                  clog(e);
                  showToast("Failed to cancel orders!", isErr: true)
                      .show(context);
                }
              }
            },
          );
        });
  }

  _getOrders() async {
    _ctrl.setOrdersFetched(false);
    if (_appCtrl.user.isEmpty) {
      _ctrl.setOrdersFetched(true);
      return;
    }
    try {
      final res = await dio.get("$apiURL/orders?user=${_appCtrl.user['_id']}");
      _ctrl.setOrders(res.data['orders']);
      _ctrl.setOrdersFetched(true);
    } catch (e) {
      clog(e);
      _ctrl.setOrdersFetched(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(),
      onRefresh: () async {
        await _init();
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Orders ",
                  style: Styles.h1,
                ),
                Obx(
                  () {
                    return _appBarCtrl.selected.isEmpty
                        ? none()
                        : TuLabeledCheckbox(
                            radius: 50,
                            activeColor: orange,
                            value: _appBarCtrl.selected.isNotEmpty &&
                                _appBarCtrl.selected.length ==
                                    _ctrl.orders.length,
                            onChanged: (val) {
                              if (val == true) {
                                _appBarCtrl.setSelected(_ctrl.orders);
                              } else {
                                _appBarCtrl.setSelected([]);
                              }
                            });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("FILTER",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                Obx(() => IconButton(
                      splashRadius: 15,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _ctrl.sortOrder.value == SortOrder.descending
                            ? _ctrl.setSortOrder(SortOrder.ascending)
                            : _ctrl.setSortOrder(SortOrder.descending);
                      },
                      icon: Icon(_ctrl.sortOrder.value == SortOrder.descending
                          ? Icons.arrow_drop_down
                          : Icons.arrow_drop_up),
                      color: Colors.black87,
                    )),
              ],
            ),
            LayoutBuilder(builder: (context, c) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => TuDropdownButton(
                        label: "Sort by",
                        labelFontSize: 14,
                        width: (c.maxWidth / 2) - 2.5,
                        //height: 35,
                        value: _ctrl.sortBy.value,
                        radius: 1,
                        items: [
                          SelectItem("Date created", SortBy.dateCreated),
                          SelectItem("Last modified", SortBy.lastModified),
                        ],
                        onChanged: (p0) {
                          _ctrl.setSortBy(p0);
                        },
                      )),
                  Obx(() {
                    return TuDropdownButton(
                      radius: 1,
                      label: "Status",
                      labelFontSize: 14,
                      width: (c.maxWidth / 2) - 2.5,
                      //height: 35,
                      value: _ctrl.status.value,
                      items: [
                        SelectItem("All", OrderStatus.all),
                        SelectItem("Pending", OrderStatus.pending),
                        SelectItem("Delivered", OrderStatus.delivered),
                        SelectItem("Cancelled", OrderStatus.cancelled),
                      ],
                      onChanged: (p0) {
                        _ctrl.setStatus(p0);
                      },
                    );
                  }),
                ],
              );
            }),
            mY(5),
            Obx(() => !_ctrl.ordersFetched.value
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        mY(30),
                        h3("Please wait..."),
                      ],
                    ),
                  )
                : _ctrl.sortedOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            mY(30),
                            h3("Nothing to show"),
                            IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () async {
                                  _getOrders();
                                })
                          ],
                        ),
                      )
                    : Column(
                        children: _ctrl.sortedOrders.map((e) {
                          return OrderItem(ctrl: _ctrl, order: e);
                        }).toList(),
                      ))
          ],
        ),
      ),
    );
  }
}
 */