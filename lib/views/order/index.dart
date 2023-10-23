// ignore_for_file: use_build_context_synchronously
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions2.dart';
import 'package:lebzcafe/views/order/checkout.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/prompt_modal.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/account/settings.dart';
import 'package:lebzcafe/views/map.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/form_view.dart';
import 'package:lebzcafe/widgets/tu/select.dart';
import 'package:get/get.dart';

import '../../utils/functions.dart';

class OrderPageArgs {
  final String id;
  const OrderPageArgs({required this.id});
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  OrderPageArgs? _args;
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
      setState(() {
        _args = ModalRoute.of(context)!.settings.arguments as OrderPageArgs;
      });

      _init();
    });
  }

  _init() async {
    try {
      _setOrder(null);
      // Fetch the order
      final res = await apiDio().get("/orders?oid=${_args!.id}");
      if (res.data["orders"].isNotEmpty) {
        var order = res.data["orders"][0];
        order['status'] = order['mode'] == OrderMode.collect.index
            ? order['status']
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
    var mode = _order!['mode'];
    Map<String, dynamic> form =
        mode == 1 ? _order!['collector'] : _order!['delivery_address'];

    TuFuncs.showBottomSheet(
        context: context,
        widget: FormView(
            title: "Edit order recipient",
            useBottomSheet: true,
            fields: [
              TuFormField(
                required: true,
                label: "Name:",
                hint: "e.g. John Doe",
                value: form['name'],
                onChanged: (val) {
                  form["name"] = val;
                },
              ),
              TuFormField(
                required: true,
                label: "Phone:",
                hint: "e.g. 0712345678",
                value: form['phone'],
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
                    ? _order!['collector']
                    : _order!['delivery_address'];
                showProgressSheet();
                final res = await apiDio()
                    .post('/order/edit?id=${_order!['_id']}', data: {
                  field: {...val, ...form}
                });
                gpop(); //POP SHEET
                gpop(); //POP MAP
                _reload(res);
              } catch (e) {
                errorHandler(
                    e: e, context: context, msg: "Error editing fields!");
              }
            }));
  }

  _onEditAddressPress() async {
    _formCtrl.setForm({"delivery_address": _order!['delivery_address']});
    _formCtrl.setForm({"address": _order!['delivery_address']});

    TuFuncs.showBottomSheet(
        context: context,
        widget: MapPage(onSubmit: (val) async {
          if (val.isEmpty) return;
          try {
            showProgressSheet();
            final res =
                await apiDio().post('/order/edit?id=${_order!['_id']}', data: {
              "delivery_address": {..._order!['delivery_address'], ...val}
            });
            gpop();
            _reload(res);
          } catch (e) {
            errorHandler(e: e, context: context, msg: "Error editing fields!");
          }
        }));
  }

  _reload(res) async {
    //Get.offAllNamed("/");
    Navigator.popAndPushNamed(context, '/order',
        arguments: OrderPageArgs(id: "${res.data['id']}"));
  }

  _cancelOrder({bool del = false}) async {
    var act = del ? "delete" : "cancel";
    Get.dialog(PromptDialog(
      title: "Cancel order",
      msg: "Are you sure you want to cancel this order? ",
      okTxt: "Yes",
      onOk: () async {
        try {
          showProgressSheet(msg: 'Canceling order..');

          if (_order!['mode'] == OrderMode.deliver.index) {
            //cancel from shiplogic first
            await Shiplogic.cancelOrder(_order!);
          }

          await apiDio().post("/order/cancel?action=$act", data: {
            'ids': [_order!['_id']],
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
    for (var it in order['products']) {
      final prod = it['product'];
      total += ((prod['on_sale'] ? prod['sale_price'] : prod["price"]) *
              it["quantity"])
          .toDouble();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${_args?.id}"),
        actions: [
          TuPopupBtn(
            items: [
              (_appCtrl.user['permissions'] > 0 &&
                      _order?['mode'] == OrderMode.collect.index)
                  ? PopupMenuItem(
                      onTap: _cancelOrder,
                      child: const Text('Update status'),
                    )
                  : null,
              PopupMenuItem(
                onTap: _cancelOrder,
                child: const Text('Cancel order'),
              ),
            ],
          )
        ],
      ),
      bottomNavigationBar: _order == null
          ? null
          : TuBottomBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tuTableRow(h4("SUBTOTAL:"), Text("R${_getTotal(_order!)}")),
                  tuTableRow(h4("DELIVERY FEE:"), Text("R${_order!['fee']}")),
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
                              color: appBGLight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Details",
                                    style: Styles.h3(),
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
                                            _args!.id,
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
                                            backgroundColor: _order!['status']
                                                        .toLowerCase() ==
                                                    'cancelled'
                                                ? TuColors.danger
                                                : TuColors.medium,
                                            label: Text(
                                              "${_order!['status']}",
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
                                                    "${_order!["date_created"]}")
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
                                                    "${_order!["last_modified"]}")
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
                              color: appBGLight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Customer",
                                    style: Styles.h3(),
                                  ),
                                  devider(),
                                  Column(
                                    //id=customer-details
                                    children: [
                                      tuTableRow(
                                          const Text("Name:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Text(
                                            "${_order!["customer"]["first_name"]} ${_order!["customer"]["last_name"]}",
                                          ),
                                          my: 10),
                                      tuTableRow(
                                          const Text("Phone:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
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
                              color: appBGLight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  tuTableRow(
                                      Text("Recipient", style: Styles.h3()),
                                      IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: _onEditRecipientBtnPress,
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
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
                                            _order!['mode'] == 0
                                                ? "${_order!['delivery_address']['name']}"
                                                : "${_order!["collector"]["name"]}",
                                          ),
                                          my: 10),
                                      tuTableRow(
                                          const Text("Phone:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Text(
                                            _order!['mode'] == 0
                                                ? "${_order!['delivery_address']['phone']}"
                                                : "${_order!["collector"]["phone"]}",
                                          ),
                                          my: 10),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        mY(6),
                        _order!['mode'] == OrderMode.collect.index
                            ? TuCard(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => _storeCtrl.stores.value == null
                                        ? none()
                                        : TuSelect(
                                            label: "Store:",
                                            value: _order!['store']?['_id'],
                                            items: _storeCtrl.stores.value!
                                                .map((e) {
                                              return SelectItem(
                                                  "${e['address']['place_name']}",
                                                  e['_id']);
                                            }).toList(),
                                            onChanged: (val) async {
                                              var store = _storeCtrl
                                                  .stores.value!
                                                  .where((element) =>
                                                      element['_id'] == val)
                                                  .first;
                                              showProgressSheet(); //_ctrl.setStore(store);
                                              final res = await apiDio().post(
                                                  '/order/edit?id=${_order!['_id']}',
                                                  data: {'store': store});
                                              gpop();
                                              _reload(res);
                                            },
                                          ),
                                  )
                                ],
                              ))
                            : tuColumn(
                                children: [
                                  TuCard(
                                      width: double.infinity,
                                      child: TuCard(
                                        color: appBGLight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            tuTableRow(
                                                Text(
                                                  "Delivery address",
                                                  style: Styles.h3(),
                                                ),
                                                IconButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed:
                                                        _onEditAddressPress,
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 20,
                                                    )),
                                                my: 0),
                                            devider(),
                                            mY(10),
                                            Builder(builder: (context) {
                                              final addr =
                                                  _order!["delivery_address"];
                                              return addr == null
                                                  ? const Text("No address")
                                                  : Text(
                                                      addr['place_name'],
                                                    );
                                            }),
                                          ],
                                        ),
                                      )),
                                  mY(6),
                                  TuCard(
                                      width: double.infinity,
                                      child: TuCard(
                                        color: appBGLight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pickup date & time",
                                              style: Styles.h3(),
                                            ),
                                            devider(),
                                            mY(10),
                                            Text(
                                              formatDate(_order!['shiplogic']
                                                      ['service_level']
                                                  ['collection_date']),
                                            )
                                          ],
                                        ),
                                      )),
                                  TuCard(
                                      width: double.infinity,
                                      child: TuCard(
                                        color: appBGLight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Delivery dates & times",
                                              style: Styles.h3(),
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
                                              formatDate(_order!['shiplogic']
                                                      ['service_level']
                                                  ['delivery_date_from']),
                                            ),
                                            mY(10),
                                            const Text(
                                              "TO:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            mY(2.5),
                                            Text(
                                              formatDate(_order!['shiplogic']
                                                      ['service_level']
                                                  ['delivery_date_to']),
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
                                                          "${it['product']['name']}",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                      subtitle: Text(
                                                        "R${it['product']['price']}",
                                                        style: Styles.subtitle,
                                                      ),
                                                      trailing: Text(
                                                          "x${it['quantity']}")),
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
}

Widget tuTableRow(Widget? first, Widget? last,
    {double my = 2, WrapCrossAlignment? crossAxisAlignment}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: my),
    width: double.infinity,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment ?? WrapCrossAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [first ?? none(), last ?? none()],
    ),
  );
}

class TuCard extends StatelessWidget {
  final double radius;
  final double padding;
  final double my;
  final double borderSize;
  final double mx;
  final Widget? child;
  final Function()? onTap;
  final Function()? onLongPress;
  final double? width;
  final double? height;
  final Color? color;
  const TuCard(
      {super.key,
      this.radius = 0,
      this.padding = 8,
      this.my = 0,
      this.mx = 0,
      this.borderSize = 1.6,
      this.child,
      this.onTap,
      this.onLongPress,
      this.height,
      this.color,
      this.width = double.infinity});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(radius),
      //hoverColor: Colors.black,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: my, horizontal: mx),
        height: height,
        width: width,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color ?? cardBGLight,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}
