// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/checkout.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/functions.dart';
import '../../widgets/common2.dart';
import 'index.dart';

class PaymentScreenArgs {
  final String? url;
  const PaymentScreenArgs(this.url);
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

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
    if (url != null && url.contains("$apiURL/payment")) {
      if (_isLoading) {
        _createOrder();
        _isLoading = false;
        setState(() {
          _isLoading = false;
        });
      } else {}
    }
  }

  PaymentScreenArgs? _args;

  _createOrder() async {
    //create the order
    showToast("Creating order...").show(context);
    try {
      final res = await apiDio().post(
          "/order/create?cartId=${_storeCtrl.cart["_id"]}",
          data: {"address": checkoutCtrl.selectedAddr});
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final args =
          ModalRoute.of(context)?.settings.arguments as PaymentScreenArgs;
      if (args.url == null) {
        Navigator.pushNamed(context, '/');
        return;
      }
      setState(() {
        _args = args;

        _controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
                clog("Progress: $progress%");
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
          ..loadRequest(Uri.parse(_args!.url!));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          _controller.loadRequest(Uri.parse(_args!.url!));
        },
        child: const Icon(Icons.refresh),
      ),
      child: SizedBox(
          height: screenSize(context).height -
              appBarH -
              statusBarH(context: context),
          child: _args == null || _progress < 100
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$_progress%"),
                    Text(
                      "Loading...",
                      style: Styles.h3(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                        child: WebViewWidget(
                      controller: _controller,
                    ))
                  ],
                )),
    );
  }
}
