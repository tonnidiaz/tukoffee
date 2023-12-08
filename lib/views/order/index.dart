import "package:lebzcafe/utils/functions2.dart";
import "package:lebzcafe/views/order/checkout.dart";
import "package:lebzcafe/widgets/prompt_modal.dart";
import "package:lebzcafe/widgets/tu/common.dart";

import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";

import "package:lebzcafe/views/map.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:lebzcafe/widgets/form_view.dart";
import "package:tu/tu.dart";

import "../../utils/functions.dart";

class OrderPage extends StatefulWidget {
  final String id;
  final bool fromDash;
  const OrderPage({super.key, required this.id, this.fromDash = false});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _appCtrl = MainApp.appCtrl;
  final _storeCtrl = MainApp.storeCtrl;
  final _formCtrl = MainApp.formCtrl;
  Map? _order;
  void _setOrder(Map<String, dynamic>? val) {
    setState(() {
      _order = val;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  _init() async {
    try {
      _setOrder(null);
      // Fetch the order
      final res = await apiDio().get("/orders?oid=${widget.id}");
      if (res.data["orders"].isNotEmpty) {
        var order = res.data["orders"][0];
        order["status"] = order["mode"] == OrderMode.collect.index
            ? order["status"] ?? OrderStatus.pending.name
            : await Shiplogic.getOrderStatus(order);
        _setOrder(order);
      } else {
        _setOrder({});
      }
      getStores(storeCtrl: _storeCtrl);
    } catch (e) {
      clog(e);
      setState(() {
        _setOrder({});
      });
    }
  }

  _onEditRecipientBtnPress() async {
    var mode = _order!["mode"];
    Map<String, dynamic> form =
        mode == 1 ? _order!["collector"] : _order!["delivery_address"];

    Get.bottomSheet(
        FormView(
            title: "Edit order recipient",
            useBottomSheet: true,
            fields: [
              TuFormField(
                required: true,
                label: "Name:",
                hint: "e.g. John Doe",
                value: form["name"],
                onChanged: (val) {
                  form["name"] = val;
                },
              ),
              TuFormField(
                required: true,
                label: "Phone:",
                hint: "e.g. 0712345678",
                value: form["phone"],
                onChanged: (val) {
                  form["phone"] = val;
                },
              ),
              mY(5)
            ],
            onSubmit: () async {
              try {
                var field = mode == 1 ? "collector" : "delivery_address";
                Map<String, dynamic> val = mode == 1
                    ? _order!["collector"]
                    : _order!["delivery_address"];
                showProgressSheet();
                final res = await apiDio()
                    .post("/order/edit?id=${_order!["_id"]}", data: {
                  field: {...val, ...form}
                });
                gpop(); //POP SHEET
                gpop(); //POP MAP
                _reload(data: res.data);
              } catch (e) {
                errorHandler(e: e, msg: "Error editing fields!");
              }
            }),
        isScrollControlled: true,
        ignoreSafeArea: false);
  }

  _onEditAddressPress() async {
    _formCtrl.setForm({"delivery_address": _order!["delivery_address"]});
    _formCtrl.setForm({"address": _order!["delivery_address"]});

    Get.bottomSheet(MapPage(onSubmit: (val) async {
      if (val.isEmpty) return;
      try {
        showProgressSheet();
        final res =
            await apiDio().post("/order/edit?id=${_order!["_id"]}", data: {
          "delivery_address": {..._order!["delivery_address"], ...val}
        });
        gpop();
        _reload(data: res.data);
      } catch (e) {
        errorHandler(e: e, msg: "Error editing fields!");
      }
    }), isScrollControlled: true, ignoreSafeArea: false);
  }

  _reload({Map? data}) async {
    if (data?.containsKey('order') == true) {
      _setOrder(data!['order']);
    } else {
      Get.off(OrderPage(
        id: widget.id,
        fromDash: widget.fromDash,
      ));
    }
  }

  _cancelOrder({bool del = false}) async {
    var act = del ? "delete" : "cancel";
    TuFuncs.dialog(
        context,
        PromptDialog(
          title: "Cancel order",
          msg: "Are you sure you want to cancel this order? ",
          okTxt: "Yes",
          onOk: () async {
            try {
              gpop();
              showProgressSheet(msg: "Canceling order..");

              if (_order!["mode"] == OrderMode.deliver.index) {
                //cancel from shiplogic first
                await Shiplogic.cancelOrder(_order!);
              }

              await apiDio().post("/order/cancel?action=$act", data: {
                "ids": [_order!["_id"]],
              });

              gpop();
              _init();
            } catch (e) {
              gpop();
              errorHandler(e: e, msg: "Failed to cancel order!");
            }
          },
        ));
  }

  _getTotal(Map order) {
    double total = 0;
    for (var it in order["products"]) {
      final prod = it["product"];
      total += ((prod["on_sale"] ? prod["sale_price"] : prod["price"]) *
              it["quantity"])
          .toDouble();
    }
    return total;
  }

  _showUpdateStatusSheet() {
    _formCtrl.setForm({'status': _order!['status']});
    Tu.bottomSheet(TuBottomSheet(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => TuSelect(
              label: "Status:",
              value: _formCtrl.form['status'],
              items: [
                SelectItem("Pending", OrderStatus.pending.name),
                SelectItem("Awaiting pickup", OrderStatus.awaitingPickup.name),
                SelectItem("Completed", OrderStatus.completed.name),
                dev
                    ? SelectItem("Cancelled", OrderStatus.cancelled.name)
                    : null,
              ],
              onChanged: (val) {
                _formCtrl.setFormField('status', val);
              },
            ),
          ),
          mY(6),
          TuButton(
            text: "Save changes",
            width: double.infinity,
            onPressed: () async {
              try {
                showProgressSheet();
                final res = await apiDio().post('/order/edit',
                    queryParameters: {'id': _order!['_id']},
                    data: {"status": _formCtrl.form['status']});
                _setOrder(res.data['order']);
                gpop(); //Hide loader
                gpop(); // Hide sheet
              } catch (e) {
                gpop();
                errorHandler(e: e);
              }
            },
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${widget.id}"),
        actions: [
          TuPopupBtn(
            items: [
              (_appCtrl.user["permissions"] > 0 &&
                          _order?["mode"] == OrderMode.collect.index &&
                          widget.fromDash &&
                          _order?['status'] != "cancelled" ||
                      dev)
                  ? PopupMenuItem(
                      onTap: _showUpdateStatusSheet,
                      child: const Text("Update status"),
                    )
                  : null,
              _order?['status'] == 'cancelled'
                  ? null
                  : PopupMenuItem(
                      onTap: _cancelOrder,
                      child: const Text("Cancel order"),
                    ),
            ],
          )
        ],
      ),
      bottomNavigationBar: _order == null
          ? null
          : TuBottomSheet(
              elevation: 1,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tuTableRow(
                      Text(
                        "Subtotal:",
                        style: styles.h4(),
                      ),
                      Text("R${_getTotal(_order!)}")),
                  tuTableRow(
                      Text(
                        "Delivery fee:",
                        style: styles.h4(),
                      ),
                      Text("R${_order!["fee"]}")),
                ],
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _init();
        },
        child: Container(
          color: Colors.transparent,
          height: screenSize(context).height - appBarH,
          child: _order == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mY(6),
                        TuCard(
                            width: double.infinity,
                            child: TuCard(
                              color: colors.bg,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Details",
                                    style: styles.h3(),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                  mY(6),
                                  tuColumn(
                                    //id=order-details
                                    children: [
                                      tuTableRow(
                                          const Text(
                                            "Order ID:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SelectableText(
                                            widget.id,
                                          ),
                                          my: 10),
                                      tuColumn(children: [
                                        const Text(
                                          "Order status:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        mY(6),
                                        Chip(
                                            backgroundColor: _order!["status"]
                                                        .toLowerCase() ==
                                                    "cancelled"
                                                ? colors.danger
                                                : colors.medium,
                                            label: Text(
                                              "${_order!["status"]}",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ))
                                      ]),
                                      tuTableRow(
                                          const Text(
                                            "Date created:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            DateTime.parse(
                                                    "${_order!["createdAt"] ?? _order!['date_created']}")
                                                .toLocal()
                                                .toString()
                                                .split(" ")
                                                .first,
                                          ),
                                          my: 10),
                                      tuTableRow(
                                          const Text(
                                            "Last modified:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            DateTime.parse(
                                                    "${_order!["updatedAt"]}")
                                                .toLocal()
                                                .toString()
                                                .split(" ")
                                                .first,
                                          ),
                                          my: 10),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        mY(6),
                        TuCard(
                            width: double.infinity,
                            child: TuCard(
                              color: colors.bg,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Customer",
                                    style: styles.h3(),
                                  ),
                                  devider(),
                                  Column(
                                    //id=customer-details
                                    children: [
                                      tuTableRow(
                                          const Text("Name:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          _order!['customer'] == null
                                              ? none()
                                              : Text(
                                                  "${_order!["customer"]["first_name"]} ${_order!["customer"]["last_name"]}",
                                                ),
                                          my: 10),
                                      _order!['customer'] == null
                                          ? none()
                                          : tuTableRow(
                                              const Text("Phone:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              Text(
                                                "${_order!["customer"]["phone"]}",
                                              ),
                                              my: 10),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        mY(6),
                        TuCard(
                            width: double.infinity,
                            child: TuCard(
                              color: colors.bg,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  tuTableRow(
                                      Text("Recipient", style: styles.h3()),
                                      IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: _onEditRecipientBtnPress,
                                          icon: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: colors.text2,
                                          )),
                                      my: 0),
                                  devider(),
                                  Column(
                                    //id=customer-details
                                    children: [
                                      tuTableRow(
                                          const Text("Name:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Text(
                                            _order!["mode"] == 0
                                                ? "${_order!["delivery_address"]["name"]}"
                                                : "${_order!["collector"]["name"]}",
                                          ),
                                          my: 10),
                                      tuTableRow(
                                          const Text("Phone:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Text(
                                            _order!["mode"] == 0
                                                ? "${_order!["delivery_address"]["phone"]}"
                                                : "${_order!["collector"]["phone"]}",
                                          ),
                                          my: 10),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        mY(6),
                        _order!["mode"] == OrderMode.collect.index
                            ? TuCard(
                                child: TuCard(
                                color: colors.bg,
                                child: Column(children: [
                                  tuTableRow(
                                      Text("Collection store",
                                          style: styles.h3()),
                                      IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: _onEditStoreAddrClick,
                                          icon: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: colors.text2,
                                          )),
                                      my: 0),
                                  devider(),
                                  mY(10),
                                  InkWell(
                                    onTap: () {
                                      _formCtrl.setForm({
                                        "address": _order!['store']['address']
                                      });
                                      Get.bottomSheet(
                                          const MapPage(canEdit: false),
                                          isScrollControlled: true,
                                          ignoreSafeArea: false);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${_order!["store"]["address"]["place_name"]}",
                                            softWrap: true,
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right_outlined)
                                      ],
                                    ),
                                  )
                                ]),
                              ))
                            : tuColumn(
                                children: [
                                  TuCard(
                                      width: double.infinity,
                                      child: TuCard(
                                        color: colors.bg,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            tuTableRow(
                                                Text(
                                                  "Delivery address",
                                                  style: styles.h3(),
                                                ),
                                                Visibility(
                                                  visible: false,
                                                  child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed:
                                                          _onEditAddressPress,
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                      )),
                                                ),
                                                my: 0),
                                            devider(),
                                            mY(10),
                                            Builder(builder: (context) {
                                              final addr =
                                                  _order!["delivery_address"];
                                              return addr == null
                                                  ? const Text("No address")
                                                  : InkWell(
                                                      onTap: () {
                                                        _formCtrl.setForm({
                                                          "address": _order![
                                                              "delivery_address"]
                                                        });
                                                        Get.bottomSheet(
                                                            const MapPage(
                                                              canEdit: false,
                                                            ),
                                                            isScrollControlled:
                                                                true,
                                                            ignoreSafeArea:
                                                                false);
                                                      },
                                                      child: Text(
                                                        addr["place_name"],
                                                      ),
                                                    );
                                            }),
                                          ],
                                        ),
                                      )),
                                  mY(6),
                                  TuCard(
                                      width: double.infinity,
                                      child: TuCard(
                                        color: colors.bg,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pickup date & time",
                                              style: styles.h3(),
                                            ),
                                            devider(),
                                            mY(10),
                                            Text(
                                              formatDate(_order!["shiplogic"]
                                                      ["service_level"]
                                                  ["collection_date"]),
                                            )
                                          ],
                                        ),
                                      )),
                                  TuCard(
                                      width: double.infinity,
                                      child: TuCard(
                                        color: colors.bg,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Delivery dates & times",
                                              style: styles.h3(),
                                            ),
                                            devider(),
                                            mY(10),
                                            const Text(
                                              "FROM:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            mY(2.5),
                                            Text(
                                              formatDate(_order!["shiplogic"]
                                                      ["service_level"]
                                                  ["delivery_date_from"]),
                                            ),
                                            mY(10),
                                            const Text(
                                              "TO:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            mY(2.5),
                                            Text(
                                              formatDate(_order!["shiplogic"]
                                                      ["service_level"]
                                                  ["delivery_date_to"]),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                        mY(6),
                        TuCard(
                          child: TuCollapse(
                            radius: 0,
                            title: "Items    (${_order!["products"].length})",
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(builder: (context) {
                                    final items =
                                        _order!["products"] as List<dynamic>;
                                    return Column(
                                      children: items
                                          .map((it) => Column(
                                                children: [
                                                  TuListTile(
                                                      title: Text(
                                                          "${it["product"]["name"]}",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                      subtitle: Text(
                                                        "R${it['product']['on_sale'] ? it['product']['sale_price'] : it["product"]["price"]}",
                                                        style: styles.subtitle,
                                                      ),
                                                      trailing: Text(
                                                          "x${it["quantity"]}")),
                                                  devider()
                                                ],
                                              ))
                                          .toList(),
                                    );
                                  })
                                ]),
                          ),
                        ),
                        mY(6),
                      ]),
                ),
        ),
      ),
    );
  }

  void _onEditStoreAddrClick() async {
    Get.bottomSheet(TuBottomSheet(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: tuColumn(min: true, children: [
        Obx(() => TuSelect(
              label: "Store:",
              value: _order!["store"]?["_id"],
              items: _storeCtrl.stores.value!.map((e) {
                return SelectItem("${e["address"]["place_name"]}", e["_id"]);
              }).toList(),
              onChanged: (val) {
                _formCtrl.setForm({'store': val});
              },
            )),
        mY(6),
        TuButton(
          text: "Save changes",
          width: double.infinity,
          onPressed: () async {
            try {
              var store = _storeCtrl.stores.value!
                  .where((element) => element["_id"] == _formCtrl.form['store'])
                  .first;
              showProgressSheet(); //_ctrl.setStore(store);
              final res = await apiDio().post(
                  "/order/edit?id=${_order!["_id"]}",
                  data: {"store": store});
              gpop();
              gpop();
              _reload(data: res.data);
            } catch (e) {
              gpop();
              errorHandler(e: e, msg: "Failed to change store");
            }
          },
        )
      ]),
    ));
  }
}
