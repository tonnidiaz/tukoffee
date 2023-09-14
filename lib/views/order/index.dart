// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/account/settings.dart';
import 'package:frust/views/map.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/form_view.dart';
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
  final _formViewCtrl = MainApp.formViewCtrl;
  Map<String, dynamic>? _order;
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
      final res = await dio.get("$apiURL/orders?oid=${_args!.id}");
      if (res.data["orders"].isNotEmpty) {
        _setOrder(res.data["orders"][0]);
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
                hasBorder: false,
                isRequired: true,
                label: "Name:",
                hint: "e.g. John Doe",
                value: form['name'],
                onChanged: (val) {
                  form["name"] = val;
                },
              ),
              TuFormField(
                hasBorder: false,
                isRequired: true,
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
                final res = await apiDio()
                    .post('/order/edit?id=${_order!['_id']}', data: {
                  field: {...val, ...form}
                });
                _reload(res);
              } catch (e) {
                errorHandler(
                    e: e, context: context, msg: "Error editing fields!");
              }
            }));
  }

  _onEditAddressPress() async {
    _formViewCtrl.setForm({"delivery_address": _order!['delivery_address']});

    TuFuncs.showBottomSheet(
        context: context,
        widget: MapPage(onSubmit: (val) async {
          if (val.isEmpty) return;
          try {
            final res =
                await apiDio().post('/order/edit?id=${_order!['_id']}', data: {
              "delivery_address": {
                ..._order!['delivery_address'],
                "location": val
              }
            });
            _reload(res);
          } catch (e) {
            errorHandler(e: e, context: context, msg: "Error editing fields!");
          }
        }));
  }

  _reload(res) async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    Navigator.pushNamed(context, '/order',
        arguments: OrderPageArgs(id: "${res.data['id']}"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: childAppbar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _init();
        },
        child: Container(
          color: Colors.transparent,
          height: screenSize(context).height - appBarH,
          child: _order == null
              ? Center(
                  child: Text(
                  "Loading...",
                  style: Styles.h3(),
                ))
              : SingleChildScrollView(
                  child: Container(
                    padding: defaultPadding2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #${_args?.id}",
                            style: Styles.h1,
                          ),
                          _order!['status'] == "cancelled"
                              ? TuButton(
                                  text: "Delete order",
                                  width: double.infinity,
                                  bgColor: Colors.red,
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (c) {
                                          return ConfirmPassForm(
                                            onOk: () async {
                                              try {
                                                await apiDio().post(
                                                    '/order/cancel?action=delete',
                                                    data: {
                                                      "ids": [_order!['_id']]
                                                    });
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        '/',
                                                        (route) => false);
                                              } catch (e) {
                                                errorHandler(
                                                    e: e, context: context);
                                              }
                                            },
                                          );
                                        });
                                  })
                              : Obx(
                                  () => _appCtrl.user['permissions'] < 1
                                      ? none()
                                      : TuLabeledCheckbox(
                                          activeColor: Colors.orange,
                                          onChanged: (val) {
                                            showDialog(
                                                context: context,
                                                builder: (c) {
                                                  return ConfirmPassForm(
                                                    onOk: () async {
                                                      var status = val == true
                                                          ? "delivered"
                                                          : "pending";
                                                      try {
                                                        final res =
                                                            await apiDio().post(
                                                                '/order/edit?id=${_order!['_id']}',
                                                                data: {
                                                              "status": status
                                                            });
                                                        _reload(res);
                                                      } catch (e) {
                                                        errorHandler(
                                                            e: e,
                                                            context: context,
                                                            msg:
                                                                "Error modifying order status!");
                                                      }
                                                    },
                                                  );
                                                });
                                          },
                                          value:
                                              _order!['status'] == "delivered",
                                          label: "Mark as delivered",
                                          fontWeight: FontWeight.w600),
                                ),
                          mY(5),
                          TuCard(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Details",
                                    style: Styles.h2(),
                                  ),
                                  mY(10),
                                  Column(
                                    //id=order-details
                                    children: [
                                      tuTableRow(
                                        Text(
                                          "Order ID:",
                                          style: Styles.h3(),
                                        ),
                                        Text(
                                          _args!.id,
                                          style: Styles.h3(isLight: true),
                                        ),
                                      ),
                                      tuTableRow(
                                        Text(
                                          "Order status:",
                                          style: Styles.h3(),
                                        ),
                                        Text(
                                          "${_order!['status']}",
                                          style: Styles.h3(isLight: true),
                                        ),
                                      ),
                                      tuTableRow(
                                        Text(
                                          "Date created:",
                                          style: Styles.h3(),
                                        ),
                                        Text(
                                          DateTime.parse(
                                                  "${_order!["date_created"]}")
                                              .toLocal()
                                              .toString()
                                              .split(" ")
                                              .first,
                                          style: Styles.h3(isLight: true),
                                        ),
                                      ),
                                      tuTableRow(
                                        Text(
                                          "Last modified:",
                                          style: Styles.h3(),
                                        ),
                                        Text(
                                          DateTime.parse(
                                                  "${_order!["last_modified"]}")
                                              .toLocal()
                                              .toString()
                                              .split(" ")
                                              .first,
                                          style: Styles.h3(isLight: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                  mY(10),
                                  TuCard(
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Customer",
                                            style: Styles.h2(),
                                          ),
                                          Column(
                                            //id=customer-details
                                            children: [
                                              tuTableRow(
                                                Text(
                                                  "Name:",
                                                  style: Styles.h3(),
                                                ),
                                                Text(
                                                  "${_order!["customer"]["first_name"]} ${_order!["customer"]["last_name"]}",
                                                  style:
                                                      Styles.h3(isLight: true),
                                                ),
                                              ),
                                              tuTableRow(
                                                Text(
                                                  "Phone:",
                                                  style: Styles.h3(),
                                                ),
                                                Text(
                                                  "${_order!["customer"]["phone"]}",
                                                  style:
                                                      Styles.h3(isLight: true),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  mY(10),
                                  TuCard(
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          tuTableRow(
                                              Text(
                                                "Recipient",
                                                style: Styles.h2(),
                                              ),
                                              IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed:
                                                      _onEditRecipientBtnPress,
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                  )),
                                              my: 0),
                                          Column(
                                            //id=customer-details
                                            children: [
                                              tuTableRow(
                                                Text(
                                                  "Name:",
                                                  style: Styles.h3(),
                                                ),
                                                Text(
                                                  "${_order!["delivery_address"]["name"] ?? _order!["collector"]["name"]}",
                                                  style:
                                                      Styles.h3(isLight: true),
                                                ),
                                              ),
                                              tuTableRow(
                                                Text(
                                                  "Phone:",
                                                  style: Styles.h3(),
                                                ),
                                                Text(
                                                  "${_order!["delivery_address"]["phone"] ?? _order!["collector"]["phone"]}",
                                                  style:
                                                      Styles.h3(isLight: true),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  mY(10),
                                  _order!['mode'] == 1
                                      ? TuCard(
                                          child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Store",
                                              style: Styles.h2(),
                                            ),
                                            Obx(
                                              () => _storeCtrl.stores.value ==
                                                      null
                                                  ? none()
                                                  : TuDropdownButton(
                                                      label: "Store:",
                                                      value: _order!['store']
                                                          ['_id'],
                                                      items: _storeCtrl
                                                          .stores.value!
                                                          .map((e) {
                                                        return SelectItem(
                                                            e['location']
                                                                ['name'],
                                                            e['_id']);
                                                      }).toList(),
                                                      onChanged: (val) async {
                                                        var store = _storeCtrl
                                                            .stores.value!
                                                            .where((element) =>
                                                                element[
                                                                    '_id'] ==
                                                                val)
                                                            .first;
                                                        clog(store);
                                                        //_ctrl.setStore(store);
                                                        final res =
                                                            await apiDio().post(
                                                                '/order/edit?id=${_order!['_id']}',
                                                                data: {
                                                              'store': store
                                                            });
                                                        _reload(res);
                                                      },
                                                    ),
                                            )
                                          ],
                                        ))
                                      : TuCard(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              tuTableRow(
                                                  Text(
                                                    "Delivery address",
                                                    style: Styles.h2(),
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
                                              Builder(builder: (context) {
                                                final addr =
                                                    _order!["delivery_address"];
                                                return addr['location'] == null
                                                    ? const Text("No address")
                                                    : Text(
                                                        addr['location']
                                                            ['name'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      );
                                              }),
                                            ],
                                          )),
                                ],
                              )),
                          mY(10),
                          TuCard(
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Items",
                                      style: Styles.h2(),
                                    ),
                                    mY(10),
                                    Builder(builder: (context) {
                                      final items =
                                          _order!["products"] as List<dynamic>;
                                      return Column(
                                        children: items
                                            .map((it) => TuListTile(
                                                leading: const CircleAvatar(
                                                  foregroundColor: Colors.black,
                                                  backgroundColor:
                                                      Colors.black12,
                                                  child: Icon(
                                                      Icons.coffee_outlined),
                                                ),
                                                title: Text(
                                                  "${it['product']['name']}",
                                                  style: Styles.title(),
                                                ),
                                                subtitle: Text(
                                                  "R${it['product']['price']}",
                                                  style: Styles.subtitle,
                                                ),
                                                trailing:
                                                    Text("x${it['quantity']}")))
                                            .toList(),
                                      );
                                    })
                                  ]))
                        ]),
                  ),
                ),
        ),
      ),
    );
  }
}

Widget tuTableRow(Widget? first, Widget? last, {double my = 2}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: my),
    width: double.infinity,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
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
  final Widget child;
  final Function()? onTap;
  final Function()? onLongPress;
  final double width;
  final double? height;
  const TuCard(
      {super.key,
      this.radius = 7,
      this.padding = 8,
      this.my = 0,
      this.mx = 0,
      this.borderSize = 1.6,
      required this.child,
      this.onTap,
      this.onLongPress,
      this.height,
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
            color: appBGLight,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              width: borderSize,
              color: Colors.black12,
            )),
        child: child,
      ),
    );
  }
}
