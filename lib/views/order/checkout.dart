// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lebzcafe/utils/functions2.dart';
import 'package:lebzcafe/utils/types.dart';
import 'package:lebzcafe/views/order/checkout/step1.dart';
import 'package:lebzcafe/views/order/checkout/step2.dart';
import 'package:lebzcafe/widgets/tu/browser.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:tu/tu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/auth/login.dart';
import 'package:lebzcafe/views/map.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/form_view.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/widgets/tu/stepper.dart';
import '../../controllers/app_ctrl.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/common.dart';

enum OrderMode { deliver, collect }

class CheckoutCtrl extends GetxController {
  RxInt step = 0.obs;

  setStep(int val) {
    step.value = val;
  }

  Rx<OrderMode> mode = OrderMode.collect.obs;
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

  RxMap<String, dynamic> form = <String, dynamic>{}.obs;
  setForm(Map<String, dynamic> val) {
    form.value = val;
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

  createOrder(
      {required BuildContext context,
      Map<String, dynamic>? yocoData,
      Map<String, dynamic>? paystackData,
      MyInAppBrowser? browser}) async {
    final storeCtrl = MainApp.storeCtrl;
    //create the order

    try {
      if (browser?.isOpened() == true) {
        await browser?.close();
      }

      showProgressSheet(msg: "Creating order...");

      if (mode.value == OrderMode.deliver) {
        // Create shiplogic shipment
        List items = [];
        for (var item in storeCtrl.cart['products']) {
          for (var pr in List.filled(item['quantity'], 0)) {
            items.add(item['product']);
          }
        }
        final shiplogicRes = await Shiplogic.createShipment(
            items: items,
            total: storeCtrl.total.value - storeCtrl.deliveryFee.value,
            from: storeCtrl.stores.value?[0]['address'],
            to: selectedAddr,
            ref: "DELIVERY FOR ${selectedAddr['name']}",
            serviceLevelId: form['shiplogic']['service_level']['id']);

        // SAVE TRACKING CODE
        form['shiplogic']['shipment'] = {
          "tracking_code": shiplogicRes['short_tracking_reference']
        };
      }

      try {
        final res = await apiDio().post(
            "/order/create?mode=${mode.value == OrderMode.deliver ? 0 : 1}&cartId=${MainApp.storeCtrl.cart["_id"]}",
            data: {
              "address": selectedAddr,
              'store': store['_id'],
              'collector': collector,
              'yocoData': yocoData,
              'paystackData': paystackData,
              "form": {...form, "fee": storeCtrl.deliveryFee.value},
            });
        var oid = res.data["order"]["oid"];

        Get.offAllNamed("/");
        pushTo(OrderPage(id: "$oid"));
        storeCtrl.cart['products'] = [];
      } catch (e) {
        gpop();
        //PROBLEM WITH BACKEND
        if (paystackData != null) {
          clog(jsonEncode(paystackData));
        }
        TuFuncs.dialog(
            context,
            const TuDialogView(
              hasActions: false,
              title: "Failed to create order",
              content: Text(
                "An email has been sent to support with your transaction ID. We will be in touch ASAP!",
                textAlign: TextAlign.center,
              ),
            ));
      }
    } catch (e) {
      gpop();
      if (browser?.isOpened() == true) {
        await browser?.close();
      }

      errorHandler(e: e, context: context, msg: "Failed to create order");
    }
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

  _onPayment(data) {
    clog('On payment: $data');
    final gateway = data['gateway'];
    final user = data['user'];
    final mData = data['data'];
    if (user != _appCtrl.user['_id']) return;
    if (gateway == EGateway.yoco.index) {
      if (mData['type'] == 'payment.succeeded') {
        _ctrl.createOrder(context: context, yocoData: mData, browser: _browser);
      } else {
        clog(mData);
      }
    } else if (gateway == EGateway.paystack.index) {
      _ctrl.createOrder(
          context: context, paystackData: mData, browser: _browser);
    }
  }

  _initSocketio() {
    clog('Socketio init...');
    socket?.off("payment");
    socket?.on('payment', _onPayment);
  }

  late MyInAppBrowser _browser;
  final _webviewOptions = InAppBrowserClassOptions(
      crossPlatform:
          InAppBrowserOptions(hideUrlBar: true, hideToolbarTop: false),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));

  void _onWebviewLoad(Uri? uri) async {
    if (uri != null) {
      final url = uri.toString();
      if (url.contains("${MainApp.appCtrl.apiURL}/payment")) {}
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initSocketio();
      _browser = MyInAppBrowser(onLoad: _onWebviewLoad);
      if (_appCtrl.user.isEmpty) {
        Get.bottomSheet(const LoginPage());
        return;
      }

      final user = _appCtrl.user;
      _storeCtrl.setDeliveryFee(0);
      _ctrl.setdeliveryAddresses(user['delivery_addresses']);
      if (_ctrl.collector.isEmpty) {
        _ctrl.setCollector({
          'name': "${user['first_name']} ${user['last_name']}",
          'phone': user['phone']
        });
      }
      if (_storeCtrl.stores.value == null || _storeCtrl.stores.value!.isEmpty) {
        getStores(storeCtrl: _storeCtrl);
      }
    });
  }

  @override
  void dispose() {
    clog('Disposing');
    Get.delete<CheckoutCtrl>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = childAppbar(showCart: false, title: "Checkout");
    return _appCtrl.user.isEmpty
        ? PageWrapper(
            appBar: appBar,
            child: Container(
              padding: defaultPadding2,
              height:
                  screenSize(context).height - statusBarH(context) - appBarH,
              child: Center(
                child: TuButton(
                  text: "Login",
                  onPressed: () {
                    Get.bottomSheet(const LoginPage());
                  },
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: appBar,
            bottomNavigationBar: Obx(
              () => _ctrl.step.value < 1
                  ? none()
                  : TuBottomBar(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total:",
                                  style: styles.h4(),
                                ),
                                Obx(
                                  () {
                                    return Text(
                                      "R${roundDouble(_storeCtrl.total.value + _storeCtrl.deliveryFee.value, 2)}",
                                      style: styles.h4(),
                                    );
                                  },
                                )
                              ],
                            ),
                            mY(4),
                            TuButton(
                              width: double.infinity,
                              onPressed: _onCheckoutBtnPress,
                              bgColor: Colors.green,
                              text: "CONTINUE",
                            )
                          ]),
                    ),
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: Container(
                  width: screenSize(context).width,
                  height: screenSize(context).height -
                      appBarH -
                      statusBarH(context),
                  child: Obx(
                    () => TuStepper(
                      elevation: .5,
                      currentStep: _ctrl.step.value,
                      type: StepperType.horizontal,
                      onStepTapped: (step) {
                        if (step == 0) _ctrl.setStep(step);
                      },
                      /* onStepContinue: () {
                        if (_ctrl.step < 1) {
                          _ctrl.step.value++;
                        }
                      },
                      onStepCancel: () {
                        if (_ctrl.step > 0) {
                          _ctrl.step.value--;
                        }
                      }, */
                      controlsBuilder: (context, details) => none(),
                      steps: [
                        Step(
                          title: Text(CheckoutStep1.title),
                          isActive: _ctrl.step.value >= 0,
                          content: CheckoutStep1(
                            ctrl: _ctrl,
                          ),
                        ),
                        Step(
                          isActive: _ctrl.step.value == 1,
                          title: Text(CheckoutStep2.title),
                          content: const CheckoutStep2(),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ));
  }

  _onCheckoutBtnPress() async {
    if (_ctrl.mode.value == OrderMode.deliver && _ctrl.selectedAddr.isEmpty) {
      // Disallow if user has no delivery addresses
      showToast("Delivery address is required!", isErr: true).show(context);
      return;
    } else if (_ctrl.mode.value == OrderMode.collect && _ctrl.store.isEmpty) {
      showToast("Please select a store", isErr: true).show(context);
      return;
    } else if (_storeCtrl.cart.isEmpty) {
      showToast("Please Add some items to your cart!", isErr: true)
          .show(context);
      return;
    }

    // SELECT PAYMENT GATEWAY

    try {
      Get.bottomSheet(GatewaysSheet(
        total: _storeCtrl.total.value + _storeCtrl.deliveryFee.value,
        browser: _browser,
        options: _webviewOptions,
      ));
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
    //pushNamed( "/order/checkout/payment");
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
            value: checkoutCtrl.selectedAddr == address,
            groupValue: true,
            onChanged: (val) {
              if (val == false) checkoutCtrl.setSelectedAddr(address);
            }),
        title: Text(
          address['name'] ?? "",
          style: Tu.styles.h4(),
        ),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            address['place_name'],
            style: const TextStyle(fontSize: 13),
          ),
          mY(4),
          Text(
            address['phone'] ?? "",
            style: TextStyle(fontSize: 13, color: Tu.colors.primary),
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
                      showProgressSheet();
                      var res = await apiDio().post(
                          '/user/delivery-address?action=remove',
                          data: {"address": address});
                      MainApp.appCtrl.setUser(res.data['user']);
                      checkoutCtrl.setSelectedAddr({});
                      gpop();
                    } catch (e) {
                      gpop();
                      errorHandler(
                          e: e,
                          context: context,
                          msg: "Failed to remove addresss");
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Tu.colors.text2,
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
            required: true,
            prefixIcon: TuIcon(Icons.location_on),
            readOnly: true,
            value: _deliveryAddress['place_name'],
            onTap: () {
              MainApp.formCtrl.clear();
              Get.bottomSheet(MapPage(
                onSubmit: (val) {
                  clog(val);
                  setState(() {
                    _deliveryAddress = {..._deliveryAddress, ...val};
                  });
                },
              ));
            },
          ),
          TuFormField(
            label: "Address line 2:",
            hint: "Apt / Suite / Bldng / Unit",
            value: _deliveryAddress['line2'],
            required: true,
            keyboard: TextInputType.streetAddress,
            onChanged: (val) {
              _setDeliveryAddressField("line2", val);
            },
          ),
          TuFormField(
            label: "Recipient name:",
            hint: "e.g. John Doe",
            value: _deliveryAddress['name'],
            required: true,
            keyboard: TextInputType.name,
            onChanged: (val) {
              _setDeliveryAddressField('name', val);
            },
          ),
          TuFormField(
            label: "Recipient phone:",
            hint: "e.g. 0712345678",
            value: _deliveryAddress['phone'],
            required: true,
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
            required: true,
            value: ctrl.collector['name'],
            onChanged: (val) {
              ctrl.setCollector({...ctrl.collector, 'name': val});
            },
          )),
      Obx(() => TuFormField(
            label: "Collector Phone:",
            hint: "e.g. 0712345678",
            required: true,
            keyboard: TextInputType.phone,
            value: ctrl.collector['phone'],
            onChanged: (val) {
              ctrl.setCollector({...ctrl.collector, 'phone': val});
            },
          )),
    ],
  );
}

class GatewaysSheet extends StatelessWidget {
  final double total;
  final MyInAppBrowser browser;
  final InAppBrowserClassOptions options;
  const GatewaysSheet(
      {super.key,
      required this.total,
      required this.browser,
      required this.options});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    final CheckoutCtrl ctrl = Get.find();

    createPaystackURL() async {
      var body = {
        "email": "${appCtrl.user['email']}",
        "name":
            "${appCtrl.user['first_name']} ${appCtrl.user['last_name']}'s ${appCtrl.store['name']} Order",
        "amount": total * 100,
        "description": "Checkout your ${appCtrl.store['name']} order.",
        "callback_url":
            "${MainApp.appCtrl.apiURL}/hooks/paystack/${appCtrl.user['_id']}",
        "metadata": jsonEncode({"customerId": appCtrl.user['_id']})
      };
      final res = await paystackDio.post("/transaction/initialize", data: body);
      final resData = res.data["data"];

      // Navigate to payment page and pass checkoutUrl as arg to be used in webview
      return resData['authorization_url'];
    }

    createYocoURL() async {
      final res = await yocoDio.post('/checkouts', data: {
        "amount": total * 100,
        'currency': "ZAR",
        "metadata": {"user": appCtrl.user['_id']}
      });

      return res.data['redirectUrl'];
    }

    dynamic onPayBtnClick({required String uri}) async {
      checkServer(context).then((v) async {
        try {
          if (Platform.isLinux) {
            await launchUrl(Uri.parse(uri));
            gpop();
            //gpop();
            return;
          }

          //pushTo(PaymentPage(url: url));
          await browser.openUrlRequest(
              urlRequest: URLRequest(url: Uri.parse(uri)), options: options);
          gpop();
          gpop();
        } catch (e) {
          errorHandler(e: e, context: context);
        }
      }).catchError((e) {});
    }

    return Container(
      padding: defaultPadding2,
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          h3('CONTINUE WITH'),
          mY(10),
          const Text(
            "These secure payment gateways accept MasterCard, VISA, EFT, and a few other methods.",
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          mY(16),
          TuButton(
            onPressed: () async {
              final uri = await createPaystackURL();
              onPayBtnClick(uri: uri);
            },
            radius: 100,
            bgColor: colors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                svgIcon(name: 'paystack'),
                mX(10),
                Text(
                  "Paystack",
                  style: GoogleFonts.poppins(
                      color: const Color.fromARGB(221, 27, 16, 16),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )
              ],
            ),
          ),
          mY(5),
          TuButton(
            width: double.infinity,
            bgColor: colors.surface,
            radius: 100,
            onPressed: () async {
              final uri = await createYocoURL();
              onPayBtnClick(uri: uri);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/yoco.png',
                  height: 35,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
