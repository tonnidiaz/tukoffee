// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/map.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/views/order/payment.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/form_view.dart';
import 'package:get/get.dart';
import '../../controllers/app_ctrl.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/common.dart';

enum OrderMode { deliver, collect }

class CheckoutCtrl extends GetxController {
  Rx<OrderMode> mode = OrderMode.deliver.obs;
  setOrderMode(OrderMode val) {
    mode.value = val;
  }

  RxString collectionTime = collectionTimes[0].obs;
  setCollectionTime(String val) {
    collectionTime.value = val;
  }

  RxMap<String, dynamic> collector = <String, dynamic>{}.obs;
  setCollector(Map<String, dynamic> val) {
    collector.value = val;
  }

  RxMap<String, dynamic> store = <String, dynamic>{}.obs;
  setStore(Map<String, dynamic> val) {
    store.value = val;
  }

  RxMap<String, dynamic> selectedAddr = <String, dynamic>{}.obs;
  void setSelectedAddr(Map<String, dynamic> val) {
    selectedAddr.value = val;
  }

  RxList<dynamic> deliveryAddresses = [].obs;
  void setdeliveryAddresses(List<dynamic> val) {
    deliveryAddresses.value = val;
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final StoreCtrl _storeCtrl = Get.find();
  final AppCtrl _appCtrl = Get.find();
  final CheckoutCtrl _ctrl = Get.put(CheckoutCtrl());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_appCtrl.user.isEmpty) {
        pushNamed(context, "/auth/login");
        return;
      }

      final user = _appCtrl.user;
      _ctrl.setdeliveryAddresses(user['delivery_addresses']);
      if (_ctrl.collector.isEmpty) {
        _ctrl.setCollector({
          'name': "${user['first_name']} ${user['last_name']}",
          'phone': user['phone']
        });
      }

      getStores(storeCtrl: _storeCtrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _appCtrl.user.isEmpty
        ? PageWrapper(
            appBar: childAppbar(),
          )
        : PageWrapper(
            appBar: childAppbar(),
            bottomSheet: Container(
              decoration: const BoxDecoration(
                  color: cardBGLight,
                  border:
                      Border(top: BorderSide(color: appBGLight, width: 1.5))),
              padding: defaultPadding,
              height: 100,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total:",
                          style: Styles.h4(),
                        ),
                        Obx(
                          () {
                            double total = 0;
                            if (_storeCtrl.cart.isNotEmpty) {
                              for (var it in _storeCtrl.cart["products"]) {
                                total +=
                                    (it["product"]["price"] * it["quantity"])
                                        .toDouble();
                              }
                            }
                            total += _storeCtrl.deliveryFee.value;
                            return Text(
                              "R${roundDouble(total, 2)}",
                              style: Styles.h4(color: Colors.green),
                            );
                          },
                        )
                      ],
                    ),
                    mY(4),
                    TuButton(
                      onPressed: _onCheckoutBtnPress,
                      bgColor: Colors.green,
                      text: "Pay now",
                    )
                  ]),
            ),
            child: Container(
                color: Colors.transparent,
                height: screenSize(context).height -
                    100 -
                    statusBarH(context) -
                    appBarH,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order review",
                          style: Styles.h1,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Obx(() => TuLabeledCheckbox(
                                      radius: 50,
                                      value:
                                          _ctrl.mode.value == OrderMode.deliver,
                                      onChanged: (val) {
                                        if (val == true) {
                                          _ctrl.setOrderMode(OrderMode.deliver);
                                        }
                                      },
                                      label: "Deliver",
                                    )),
                                Obx(() => TuLabeledCheckbox(
                                      radius: 50,
                                      value:
                                          _ctrl.mode.value == OrderMode.collect,
                                      onChanged: (val) {
                                        if (val == true) {
                                          _ctrl.setOrderMode(OrderMode.collect);
                                        }
                                      },
                                      label: "Collect",
                                    )),
                              ],
                            )
                          ],
                        ),
                        mY(5),
                        Column(
                          //id=ordersummarysec
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order summary",
                              style: Styles.h2(),
                            ),
                            mY(5),
                            Table(
                              border: TableBorder.all(
                                  width: 2,
                                  color: const Color.fromRGBO(0, 0, 0, 0.116),
                                  borderRadius: BorderRadius.circular(0)),
                              children: [
                                TableRow(children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Items"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Obx(
                                          () => Text(
                                              "${_storeCtrl.cart['products']?.length ?? 0}"),
                                        ),
                                        SizedBox(
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              splashRadius: 20,
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, "/cart");
                                              },
                                              icon: const Icon(
                                                Icons.visibility,
                                                color: Colors.black54,
                                              )),
                                        )
                                      ],
                                    ),
                                  )
                                ]),
                                TableRow(children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Subtotal"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Obx(() {
                                      double total = 0;
                                      if (_storeCtrl.cart["products"] != null) {
                                        for (var it
                                            in _storeCtrl.cart["products"]) {
                                          total += (it["product"]["price"] *
                                                  it["quantity"])
                                              .toDouble();
                                        }
                                      }

                                      return Text("R${roundDouble(total, 2)}");
                                    }),
                                  )
                                ]),
                                TableRow(children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Delivery fee"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Obx(() =>
                                        Text("R${_storeCtrl.deliveryFee}")),
                                  )
                                ]),
                              ],
                            )
                          ],
                        ),
                        mY(5),
                        Obx(() => _ctrl.mode.value == OrderMode.collect
                            ? TuCard(
                                radius: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    tuTableRow(
                                      Text(
                                        "Collection info",
                                        style: Styles.h3(),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        child: IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (c) {
                                                  return editCollectorModal(
                                                      context);
                                                });
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    mY(5),
                                    Obx(() {
                                      return _storeCtrl.stores.value == null
                                          ? none()
                                          : TuDropdownButton(
                                              label: "Store:",
                                              value: _ctrl.store['_id'],
                                              items: _storeCtrl.stores.value!
                                                  .map((e) {
                                                return SelectItem(
                                                    e['location']['name'],
                                                    e['_id']);
                                              }).toList(),
                                              onChanged: (val) {
                                                var store = _storeCtrl
                                                    .stores.value!
                                                    .where((element) =>
                                                        element['_id'] == val)
                                                    .first;
                                                _ctrl.setStore(store);
                                              },
                                            );
                                    }),
                                    mY(10),
                                    Obx(
                                      () => TuListTile(
                                        leading: const Icon(
                                          Icons.person,
                                          color:
                                              Color.fromRGBO(255, 152, 0, .7),
                                        ),
                                        title: Text(
                                          _ctrl.collector['name'] ?? "",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          _ctrl.collector['phone'] ?? "",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                            : Column(
                                //id=delivery-address-section
                                children: [
                                  tuTableRow(
                                      Text("Delivery address",
                                          style: Styles.h2()),
                                      SizedBox(
                                        width: 25,
                                        child: IconButton(
                                            onPressed: () {
                                              TuFuncs.showBottomSheet(
                                                  context: context,
                                                  widget:
                                                      const EditAddressForm());
                                            },
                                            splashRadius: 24,
                                            padding: EdgeInsets.zero,
                                            icon:
                                                const Icon(Icons.add_outlined)),
                                      )),
                                  mY(5),
                                  Obx(
                                    () => _appCtrl.user['delivery_addresses']
                                            .isNotEmpty
                                        ? Column(
                                            children: (_appCtrl.user[
                                                        'delivery_addresses']
                                                    as List)
                                                .map((e) {
                                            return addressCard(
                                                context: context, address: e);
                                          }).toList())
                                        : Center(
                                            child: SizedBox(
                                            width: double.infinity,
                                            height: 70,
                                            child: InkWell(
                                              onTap: () {
                                                TuFuncs.showBottomSheet(
                                                    context: context,
                                                    widget:
                                                        const EditAddressForm());
                                              },
                                              child: const Card(
                                                  elevation: .5,
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black87,
                                                    // size: 50,
                                                  )),
                                            ),
                                          )),
                                  ),
                                ],
                              )),
                      ],
                    ),
                  ),
                )));
  }

  _createOrder() async {
    //create the order
    showToast("Creating order...").show(context);
    try {
      final res = await apiDio().post(
          "/order/create?mode=${_ctrl.mode.value == OrderMode.deliver ? 0 : 1}&cartId=${_storeCtrl.cart["_id"]}",
          data: {"address": _ctrl.selectedAddr, 'store': _ctrl.store});
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      Navigator.pushNamed(context, "/order",
          arguments: OrderPageArgs(id: "${res.data["order"]["oid"]}"));
    } catch (e) {
      errorHandler(
          e: e,
          context: context,
          msg: "Failed to create order. Please contact the developer");
    }
  }

  _onCheckoutBtnPress() async {
    if (_ctrl.mode.value == OrderMode.deliver && _ctrl.selectedAddr.isEmpty) {
      // Disallow if user has no delivery addresses
      return showToast("Delivery address is required!", isErr: true)
          .show(context);
    } else if (_ctrl.mode.value == OrderMode.collect && _ctrl.store.isEmpty) {
      return showToast("Please select a store", isErr: true).show(context);
    } else if (_storeCtrl.cart.isEmpty) {
      return showToast("Please Add some items to your cart!", isErr: true)
          .show(context);
    }
    try {
      double total = 0;
      if (_storeCtrl.cart.isNotEmpty) {
        for (var it in _storeCtrl.cart["products"]) {
          total += (it['product']["price"] * it['quantity']).toDouble();
        }
      }
      clog(total);
      total += _storeCtrl.deliveryFee.value;

      var body = {
        "name":
            "${_appCtrl.user['first_name']} ${_appCtrl.user['last_name']}'s ${_appCtrl.storeName} Order",
        "amount": total * 100,
        "description": "Checkout your Tukoffee order.",
        "redirect_url": "$apiURL/payment"
      };
      clog(body);
      final res = await paystackDio.post("/page", data: body);
      final resData = res.data["data"];
      final checkoutUrl = "$paystackPayUrl/${resData['slug']}";
      if (Platform.isLinux || Platform.isWindows) {
        _createOrder();
        return;
      }
      // Navigate to payment page and pass checkoutUrl as arg to be used in webview
      Navigator.pushNamed(context, "/order/checkout/payment",
          arguments: PaymentScreenArgs(checkoutUrl));
    } catch (e) {
      clog(e);
      if (e.runtimeType == DioException) {
        e as DioException;
        clog(e.response);
        if (e.response != null) {
          var msg = e.response!.data.runtimeType == String
              ? "Something went wrong"
              : e.response!.data["message"] ?? e.response!.data["msg"];
          showToast(msg, isErr: true).show(context);
        }
      }
    }
    //Navigator.pushNamed(context, "/order/checkout/payment");
  }
}

Widget addressCard(
    {required BuildContext context, required Map<String, dynamic> address}) {
  final CheckoutCtrl checkoutCtrl = Get.find();
  return TuCard(
    my: 1.5,
    onTap: () {
      checkoutCtrl.setSelectedAddr(address);
    },
    child: TuListTile(
        leading: Radio(
            value: checkoutCtrl.selectedAddr['_id'] == address['_id'],
            groupValue: true,
            onChanged: (val) {
              if (val == false) checkoutCtrl.setSelectedAddr(address);
            }),
        title: Text(
          address['name'] ?? "",
          style: Styles.h3(),
        ),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            address['location']['name'],
            style: const TextStyle(fontSize: 13),
          ),
          mY(4),
          Text(
            address['phone'] ?? "",
            style: const TextStyle(
                fontSize: 13, color: Color.fromARGB(255, 33, 149, 243)),
          ),
        ]),
        trailing: Row(
          children: [
            SizedBox(
              width: 25,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 24,
                  iconSize: 20,
                  onPressed: () async {
                    // delete address
                    try {
                      var res = await apiDio().post(
                          '/user/delivery-address?action=remove',
                          data: {"address": address});
                      MainApp.appCtrl.setUser(res.data['user']);
                      checkoutCtrl.setSelectedAddr({});
                    } catch (e) {
                      errorHandler(
                          e: e,
                          context: context,
                          msg: "Failed to remove addresss");
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
            )
          ],
        )),
  );
}

class EditAddressForm extends StatefulWidget {
  const EditAddressForm({super.key});

  @override
  State<EditAddressForm> createState() => _EditAddressFormState();
}

class _EditAddressFormState extends State<EditAddressForm> {
  Map<String, dynamic> _deliveryAddress = {};
  void _setDeliveryAddressField(String key, dynamic val) {
    setState(() {
      _deliveryAddress = {..._deliveryAddress, key: val};
    });
  }

  _addAddress() async {
    try {
      var res = await apiDio().post('/user/delivery-address?action=add',
          data: {"address": _deliveryAddress});
      MainApp.appCtrl.setUser(res.data['user']);
      Navigator.pop(context);
    } catch (e) {
      errorHandler(e: e, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormView(
        title: "Delivery address",
        fields: [
          TuFormField(
            label: "Address:",
            isRequired: true,
            prefixIcon: TuIcon(Icons.location_on),
            readOnly: true,
            value: _deliveryAddress['location'] == null
                ? ""
                : _deliveryAddress['location']['name'],
            onTap: () {
              TuFuncs.showBottomSheet(
                  context: context,
                  widget: MapPage(
                    onSubmit: (val) {
                      clog(val);
                      _setDeliveryAddressField('location', val);
                    },
                  ));
            },
          ),
          TuFormField(
            label: "Recipient name:",
            hint: "e.g. John Doe",
            value: _deliveryAddress['name'],
            isRequired: true,
            keyboard: TextInputType.name,
            onChanged: (val) {
              _setDeliveryAddressField('name', val);
            },
          ),
          TuFormField(
            label: "Recipient phone:",
            hint: "e.g. 0712345678",
            value: _deliveryAddress['phone'],
            isRequired: true,
            keyboard: TextInputType.phone,
            onChanged: (val) {
              _setDeliveryAddressField('phone', val);
            },
          ),
          mY(5)
        ],
        useBottomSheet: true,
        onSubmit: () {
          _addAddress();
        });
  }
}

Widget editCollectorModal(BuildContext context) {
  final ctrl = Get.find<CheckoutCtrl>();
  return FormView(
    useBottomSheet: true,
    title: "Order Collector",
    onSubmit: () {
      Navigator.pop(context);
    },
    btnTxt: "Done",
    fields: [
      Obx(() => TuFormField(
            label: "Collector Name:",
            hint: "e.g. John Doe",
            isRequired: true,
            value: ctrl.collector['name'],
            onChanged: (val) {
              ctrl.setCollector({...ctrl.collector, 'name': val});
            },
          )),
      Obx(() => TuFormField(
            label: "Collector Phone:",
            hint: "e.g. 0712345678",
            isRequired: true,
            keyboard: TextInputType.phone,
            value: ctrl.collector['phone'],
            onChanged: (val) {
              ctrl.setCollector({...ctrl.collector, 'phone': val});
            },
          )),
    ],
  );
}
