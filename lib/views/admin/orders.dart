// ignore_for_file: use_build_context_synchronously
import "package:lebzcafe/utils/functions2.dart";
import "package:lebzcafe/views/auth/login.dart";
import "package:lebzcafe/views/order/checkout.dart";

import "package:dio/dio.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/controllers/appbar.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:get/get.dart";
import "package:tu/tu.dart";
import "package:via_logger/logger.dart";
import "../../main.dart";
import "../../widgets/order_item.dart";
import "../../widgets/prompt_modal.dart";

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
  setOrders(List<dynamic> val) async {
    List orders = [];
    for (var o in val) {
      String status;

      //final
      if (o["mode"] == OrderMode.deliver.index) {
        status = await Shiplogic.getOrderStatus(o);
      } else {
        status = o["status"] ?? OrderStatus.pending.name;
      }
      orders.add({...o, "status": status});
    }
    this.orders.value = orders;
    //selectedOrders.value = [];
    _sortOrders(orders);
  }

  Rx<SortBy> sortBy = SortBy.createdAt.obs;
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
        ords = orders.where((it) => it["status"] == "pending").toList();
        break;
      case OrderStatus.completed:
        ords = orders.where((it) => it["status"] == "delivered").toList();
        break;
      case OrderStatus.cancelled:
        ords = orders.where((it) => it["status"] == "cancelled").toList();
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
              ? dateInMs(b["updatedAt"]).compareTo(dateInMs(a["updatedAt"]))
              : dateInMs(a["updatedAt"]).compareTo(dateInMs(b["updatedAt"]));
          break;
        case SortBy.createdAt:
          s = sortOrder == SortOrder.ascending
              ? dateInMs(b["createdAt"]).compareTo(dateInMs(a["createdAt"]))
              : dateInMs(a["createdAt"]).compareTo(dateInMs(b["createdAt"]));
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
      _init();
    });
  }

  _init() async {
    if (_appCtrl.user.isEmpty) {
      clog("To Login");
      gpop();
      pushTo(const LoginPage(
        to: "/orders",
      ));
      return;
    }
    ever(_ctrl.sortedOrders, (callback) {
      _appBarCtrl.setSelected([]);
    });
    /*   _appBarCtrl.setSelectedActions([
        ); */
    _getOrders();
  }

  _cancelOrders({bool del = false, required routeName}) async {
    TuFuncs.dialog(
        getCtx(),
        PromptDialog(
          title: "Cancel orders",
          msg: "Do you want to cancel the selected orders? ",
          okTxt: "Yes",
          onOk: () async {
            try {
              showProgressSheet(msg: "Canceling orders..");
              // Deselect all
              final List<dynamic> ids =
                  _appBarCtrl.selected.map((it) => it["_id"]).toList();
              _appBarCtrl.setSelected([]);

              for (var o in _appBarCtrl.selected
                  .where((e) => e["mode"] == OrderMode.deliver.index)) {
                try {
                  //cancel from shiplogic first
                  await Shiplogic.cancelOrder(o);
                } catch (e) {
                  clog("SHIPLOGIC ERROR");
                  clog(e);
                  continue;
                }
              }
              final res =
                  await apiDio().post("/order/cancel?action=cancel", data: {
                "ids": ids,
                "userId":
                    routeName == "/orders" ? MainApp.appCtrl.user["_id"] : null
              });
              //gpop();
              await _ctrl.setOrders(res.data["orders"]);
              gpop();
            } catch (e) {
              gpop();
              clog(e);
              errorHandler(
                  context: context, e: e, msg: "Failed to cancel orders!");
            }
          },
        ));
  }

  _getOrders() async {
    try {
      if (_appCtrl.user.isEmpty) {
        return;
      }
      clog("Getting orders");
      _ctrl.setOrdersFetched(false);
      final res = ModalRoute.of(context)?.settings.name == "/orders"
          ? await apiDio().get("/orders?user=${_appCtrl.user["_id"]}")
          : await apiDio().get("/orders");
      await _ctrl.setOrders(res.data["orders"]);
      _ctrl.setOrdersFetched(true);
    } catch (e) {
      clog("FETCH ORDER ERR");
      clog(e);
      if (e.runtimeType == DioException) {
        e as DioException;
        clog(e.response);
      }
      _ctrl.setOrdersFetched(true);
    }
  }

  final GlobalKey _scaffoldKey = GlobalKey();
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarCtrl.setSelected([]);
      _ctrl.setOrdersFetched(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var routeName = ModalRoute.of(context)?.settings.name;
    filterModal() {
      return TuBottomSheet(
        child: Padding(
          padding: defaultPadding2,
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
                    Obx(() => TuSelect(
                          label: "Sort by",
                          labelFontSize: 14,
                          width: (c.maxWidth),
                          //height: 35,
                          value: _ctrl.sortBy.value,
                          radius: 1,
                          items: [
                            SelectItem("Date created", SortBy.createdAt),
                            SelectItem("Last modified", SortBy.lastModified),
                          ],
                          onChanged: (p0) {
                            _ctrl.setSortBy(p0);
                          },
                        )),
                    Visibility(
                      visible: false,
                      child: Obx(() {
                        return TuSelect(
                          radius: 1,
                          label: "Status",
                          labelFontSize: 14,
                          width: (c.maxWidth / 2) - 2.5,
                          //height: 35,
                          value: _ctrl.status.value,
                          items: [
                            SelectItem("All", OrderStatus.all),
                            SelectItem("Pending", OrderStatus.pending),
                            SelectItem("Completed", OrderStatus.completed),
                            SelectItem("Cancelled", OrderStatus.cancelled),
                          ],
                          onChanged: (p0) {
                            _ctrl.setStatus(p0);
                          },
                        );
                      }),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    }

    const sheetRadius = Radius.circular(10);
    return Scaffold(
        extendBody: false,
        key: _scaffoldKey,
        appBar: childAppbar(
            title: "Orders",
            showCart: routeName == "/orders",
            actions: [
              Obx(
                () => TuPopupBtn(items: [
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
                  _appBarCtrl.selected.isNotEmpty
                      ? PopupMenuItem(
                          onTap: () {
                            _cancelOrders(routeName: routeName);
                          },
                          child: const Text("Cancel orders"))
                      : null,
                ]),
              )
            ]),
        body: RefreshIndicator(
            onRefresh: () async {
              await _getOrders();
            },
            child: Obx(
              () => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: topMargin, horizontal: 14),
                    child: Obx(
                      () => TuFormField(
                        fill: colors.surface,
                        hasBorder: false,
                        hint: "Order ID",
                        prefixIcon: TuIcon(Icons.search),
                        radius: 100,
                        value: _ctrl.orderId.value,
                        suffixIcon: IconButton(
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              // show filters
                              Get.bottomSheet(filterModal());
                            },
                            icon: TuIcon(Icons.tune)),
                        onChanged: (val) {
                          _ctrl.setOrderId(val);
                          _ctrl.setsortedOrders(_ctrl.orders
                              .where((p0) => "${p0["oid"]}".contains(val))
                              .toList());
                        },
                      ),
                    ),
                  ),
                  !_ctrl.ordersFetched.value
                      ? const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _ctrl.sortedOrders.isEmpty
                          ? Expanded(
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/images/box.png",
                                  color: Colors.black45,
                                  width: screenPercent(context, 35).width,
                                ),
                              )),
                            )
                          : Expanded(
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(14.0, 0, 14, 8),
                                itemBuilder: (c, i) => OrderItem(
                                  tcontext: _scaffoldKey.currentState!.context,
                                  ctrl: _ctrl,
                                  order: _ctrl.sortedOrders[i],
                                  isAdmin: routeName != '/orders',
                                ),
                                itemCount: _ctrl.sortedOrders.length,
                              ),
                            ),
                ],
              ),
            )));
  }
}
