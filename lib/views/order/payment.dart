import "package:flutter/material.dart";

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
/* 
class PaymentPage extends StatefulWidget {
  final String url;
  const PaymentPage({super.key, required this.url});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final WebViewController _controller = WebViewController();
  final StoreCtrl _storeCtrl = Get.find();
  final CheckoutCtrl _ctrl = Get.find();
  int _progress = 0;
  bool _isLoading = true;
  _setProgress(int val) async {
    setState(() {
      _progress = val;
    });
    final url = await _controller.currentUrl();
    Logger.info(_isLoading);
    if (url != null && url.contains("${MainApp.appCtrl.apiURL}/payment")) {
      if (_isLoading) {
        _ctrl.createOrder(context: context);
        _isLoading = false;
        setState(() {
          _isLoading = false;
        });
      } else {}
    }
  }

  _initSocketio() {
    Logger.info("Socketio init...");
    socket?.on("payment", (data) {
      Logger.info("On payment");
      if (data["gateway"] == "yoco") {
        final yocoData = data["data"];
        if (yocoData["type"] == "payment.succeeded") {
          _ctrl.createOrder(context: context, yocoData: yocoData);
        } else {
          Logger.info(yocoData);
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
                Logger.info("URL changed to: $url");
              },
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith("https://www.youtube.com/")) {
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
 */