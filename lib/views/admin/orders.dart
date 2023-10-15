// ignore_for_file: use_build_context_synchronously
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/controllers/appbar.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/dialogs/loading_dialog.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../../widgets/order_item.dart';
import '../../widgets/prompt_modal.dart';

class OrdersCtrl extends GetxController {
  RxString orderId = "".obs;
  setOrderId(String val) {
    orderId.value = val;
  }

  RxBool ordersFetched = false.obs;
  setOrdersFetched(bool val) {
    ordersFetched.value = val;
  }

  RxList<dynamic> orders = <dynamic>[].obs;
  setOrders(List<dynamic> val) {
    orders.value = val;
    //selectedOrders.value = [];
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
    // clear selected
    clog("Sorting...");
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
  final OrdersCtrl _ctrl = Get.put(OrdersCtrl());
  final AppBarCtrl _appBarCtrl = Get.find();
  final AppCtrl _appCtrl = Get.find();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_appCtrl.user.isEmpty) {
        Get.offNamed('/auth/login');
        return;
      }
      ever(_ctrl.sortedOrders, (callback) {
        _appBarCtrl.setSelected([]);
      });
      /*   _appBarCtrl.setSelectedActions([
        ); */
      _getOrders();
    });
  }

  _cancelOrders({bool del = false}) async {
    showDialog(
        context: context,
        builder: (context) {
          var act = del ? "delete" : "cancel";
          return PromptDialog(
            title: "Cancel orders",
            msg: "Do you want to cancel the selected orders? ",
            okTxt: "Yes",
            onOk: () async {
              try {
                showLoading(context,
                    widget: const LoadingDialog(msg: 'Canceling orders..'));
                // Deselect all
                final List<dynamic> ids =
                    _appBarCtrl.selected.map((it) => it['_id']).toList();
                _appBarCtrl.setSelected([]);
                final res = await apiDio().post(
                    "/order/cancel?action=${act.toLowerCase()}",
                    data: {'ids': ids, "userId": MainApp.appCtrl.user['_id']});
                Navigator.pop(_scaffoldKey.currentContext!);
                _ctrl.setOrders(res.data['orders']);
              } catch (e) {
                Navigator.pop(context);
                clog(e);
                errorHandler(
                    context: context, e: e, msg: "Failed to cancel orders!");
              }
            },
          );
        });
  }

  _getOrders() async {
    try {
      if (_appCtrl.user.isEmpty) {
        return;
      }
      clog("Getting orders");
      _ctrl.setOrdersFetched(false);
      final res = ModalRoute.of(context)?.settings.name == "/orders"
          ? await dio.get("$apiURL/orders?user=${_appCtrl.user['_id']}")
          : await dio.get("$apiURL/orders");
      _ctrl.setOrders(res.data['orders']);
      _ctrl.setOrdersFetched(true);
    } catch (e) {
      clog(e);
      _ctrl.setOrdersFetched(true);
    }
  }

  final GlobalKey _scaffoldKey = GlobalKey();
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarCtrl.setSelected([]);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var routeName = ModalRoute.of(context)?.settings.name;
    filterModal() {
      return Padding(
        padding: defaultPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                          ? CupertinoIcons.sort_down
                          : CupertinoIcons.sort_up),
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
          ],
        ),
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: childAppbar(title: "Orders", actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                    (_appBarCtrl.selected.length == _ctrl.sortedOrders.length &&
                            _ctrl.sortedOrders.isNotEmpty)
                        ? PopupMenuItem(
                            onTap: () {
                              _appBarCtrl.setSelected([]);
                            },
                            child: const Text("Deselect all"))
                        : PopupMenuItem(
                            onTap: () {
                              _appBarCtrl.setSelected(_ctrl.sortedOrders);
                            },
                            child: const Text("Select all")),
                    PopupMenuItem(
                        enabled: _appBarCtrl.selected.isNotEmpty,
                        onTap: () {
                          _cancelOrders();
                        },
                        child: const Text("Cancel orders")),
                  ])
        ]),
        body: RefreshIndicator(
            onRefresh: () async {
              await _getOrders();
            },
            child: Obx(
              () => CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: topMargin),
                    sliver: SliverToBoxAdapter(
                      child: Obx(
                        () => Container(
                          width: double.infinity,
                          color: cardBGLight,
                          padding: defaultPadding,
                          child: TuFormField(
                            fill: appBGLight,
                            hasBorder: false,
                            hint: "Order ID",
                            height: borderlessInpHeight,
                            prefixIcon: TuIcon(Icons.search),
                            radius: 5,
                            value: _ctrl.orderId.value,
                            suffixIcon: IconButton(
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  // show filters
                                  TuFuncs.showBottomSheet(
                                      full: false,
                                      context: context,
                                      widget: filterModal());
                                },
                                icon: TuIcon(Icons.tune)),
                            onChanged: (val) {
                              _ctrl.setOrderId(val);
                              _ctrl.setsortedOrders(_ctrl.orders
                                  .where((p0) => "${p0['oid']}".contains(val))
                                  .toList());
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  !_ctrl.ordersFetched.value
                      ? const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _ctrl.sortedOrders.isEmpty
                          ? SliverFillRemaining(
                              child: Center(child: h3('Nothing to show')),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                              sliver: SliverList.builder(
                                itemBuilder: (c, i) => OrderItem(
                                  tcontext: _scaffoldKey.currentState!.context,
                                  ctrl: _ctrl,
                                  order: _ctrl.sortedOrders[i],
                                  isAdmin: true,
                                ),
                                itemCount: _ctrl.sortedOrders.length,
                              ),
                            ),
                ],
              ),
            )));
  }
}
