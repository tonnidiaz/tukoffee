// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/checkout.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/functions.dart';
import '../../widgets/common2.dart';
import 'index.dart';

class PaymentPage extends StatefulWidget {
  final String url;
  const PaymentPage({super.key, required this.url});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

const testURL = "https://paystack.com/pay/spy9pzsw5u";
const testURLLive = "https://paystack.com/pay/8f3nqkd4vg";

class _PaymentPageState extends State<PaymentPage> {
  final WebViewController _controller = WebViewController();
  final StoreCtrl _storeCtrl = Get.find();
  final CheckoutCtrl checkoutCtrl = Get.find();
  int _progress = 0;
  bool _isLoading = true;
  _setProgress(int val) async {
    setState(() {
      _progress = val;
    });
    final url = await _controller.currentUrl();
    clog(_isLoading);
    if (url != null && url.contains("${MainApp.appCtrl.apiURL}/payment")) {
      if (_isLoading) {
        _createOrder();
        _isLoading = false;
        setState(() {
          _isLoading = false;
        });
      } else {}
    }
  }

  _createOrder({
    Map<String, dynamic>? yocoData,
    Map<String, dynamic>? paystackData,
  }) async {
    //create the order
    showProgressSheet(msg: "Creating order...");
    try {
      final res = await apiDio().post(
          "/order/create?cartId=${_storeCtrl.cart["_id"]}&mode=${checkoutCtrl.mode.value == OrderMode.deliver ? 0 : 1}",
          data: {
            "address": checkoutCtrl.selectedAddr,
            "store": checkoutCtrl.store['_id'],
            "collector": checkoutCtrl.collector,
            'yocoData': yocoData,
            'paystackData': paystackData
          });
      Get.offAllNamed("/");
      pushNamed("/order",
          arguments: OrderPageArgs(id: "${res.data["order"]["oid"]}"));
    } catch (e) {
      Get.back(); //HIDE LOADER
      errorHandler(
          e: e,
          context: context,
          msg: "Failed to create order. Please contact the developer");
    }
  }

  _initSocketio() {
    clog('Socketio init...');
    socket?.on('payment', (data) {
      clog('On payment');
      if (data['gateway'] == 'yoco') {
        final yocoData = data['data'];
        if (yocoData['type'] == 'payment.succeeded') {
          _createOrder(yocoData: yocoData);
        } else {
          clog(yocoData);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initSocketio();
      setState(() {
        _controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
                _setProgress(progress);
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {
                clog("URL changed to: $url");
              },
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TuColors.primary,
        onPressed: () {
          _controller.loadRequest(Uri.parse(widget.url));
        },
        child: const Icon(Icons.refresh),
      ),
      body: _progress < 100
          ? LinearProgressIndicator(
              value: _progress / 100,
            )
          : WebViewWidget(
              controller: _controller,
            ),
    );
  }
}
