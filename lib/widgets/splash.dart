import "package:lebzcafe/utils/extensions.dart";
import "package:tu/tu.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:internet_connection_checker/internet_connection_checker.dart";

import "../utils/functions.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;

initSocketio() {
  final appCtrl = MainApp.appCtrl;
  clog("initing socketio...");
  socket = IO.io(
      appCtrl.apiURL.value,
      IO.OptionBuilder().setTransports(["websocket"]) // for Flutter or Dart VM
          .setExtraHeaders({"foo": "bar"}) // optional
          .build());
  socket?.onConnect((_) {
    clog("IO connected");
    socket?.emit("test", "test");
  });
}

class TuSplash extends StatefulWidget {
  const TuSplash({super.key});

  @override
  State<TuSplash> createState() => _TuSplashState();
}

class _TuSplashState extends State<TuSplash> {
  final _appCtrl = MainApp.appCtrl;
  bool _connected = true;
  _setConnected(bool val) {
    clog("Set connected");
    setState(() {
      _connected = val;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      _init();
    });
  }

  void _init() async {
    // Check for internet connection
    clog("Initi splash...");
    if (_appCtrl.store["name"] != null) return;
    _setConnected(true);
    final isReachable = await InternetConnectionChecker()
        .isHostReachable(AddressCheckOptions(hostname: "1.1.1.1"));
    //clog(isReachable.isSuccess);
    bool result = isReachable
        .isSuccess; // await InternetConnectionChecker().hasConnection;
    await Future.delayed(const Duration(milliseconds: 100));
    clog("Connected: $result");
    _setConnected(result);
    if (result) {
      try {
        //GET APIURL
        final apiURL = await getApiURL();
        _appCtrl.setApiURL(apiURL);
        clog(apiURL);
        initSocketio();
      } catch (e) {
        clog(e);
        return;
      }
      clog("await seupStoreDetails...");
      await setupStoreDetails();
      // If server is still down
      clog("Server down: ${_appCtrl.serverDown.value}");
      if (!_appCtrl.serverDown.value || dev) {
        setupUser();
        setupStoreDetails();
      }
    }
  }

  Widget refreshBtn() {
    return OutlinedButton(
      onPressed: _init,
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: const BorderSide(
                color: Colors.white, width: 10, style: BorderStyle.solid),
          )),
      child: const Text("REFRESH"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: TuTheme(colors: TuColors(), dark: false, context: context).theme(),
      home: Scaffold(
        backgroundColor: colors.coffee4,
        body: Container(
          width: screenSize(context).width,
          height: screenSize(context).height,
          alignment: Alignment.center,
          child: _connected
              ? Obx(() => !_appCtrl.serverDown.value
                  ? Container(
                      width: screenSize(context).width / 2,
                      height: screenSize(context).width / 2,
                      alignment: Alignment.center,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/images/logo.png",
                          )),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Server down!",
                            style: styles.h4(
                                isLight: true, color: Colors.white70)),
                        mY(5),
                        refreshBtn(),
                      ],
                    ))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("No internet access",
                        style: styles.h3(isLight: true, color: Colors.white70)),
                    mY(5),
                    refreshBtn()
                  ],
                ),
        ),
      ),
    );
  }
}
