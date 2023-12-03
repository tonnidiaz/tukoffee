import "package:tu/tu.dart";
import "package:via_logger/logger.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:internet_connection_checker/internet_connection_checker.dart";

import "../utils/functions.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;

initSocketio() {
  final appCtrl = MainApp.appCtrl;
  Logger.info("initing socketio...");
  socket = IO.io(
      appCtrl.apiURL.value,
      IO.OptionBuilder().setTransports(["websocket"]) // for Flutter or Dart VM
          .setExtraHeaders({"foo": "bar"}) // optional
          .build());
  socket?.onConnect((_) {
    Logger.info("IO connected");
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
    Logger.info("Set connected");
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
    Logger.info("Initi splash...");
    if (_appCtrl.store["name"] != null) return;
    _setConnected(true);
    final isReachable = await InternetConnectionChecker()
        .isHostReachable(AddressCheckOptions(hostname: "1.1.1.1"));
    //Logger.info(isReachable.isSuccess);
    bool result = isReachable
        .isSuccess; // await InternetConnectionChecker().hasConnection;
    await Future.delayed(const Duration(milliseconds: 100));
    Logger.info("Connected: $result");
    _setConnected(result);
    if (result) {
      try {
        //GET APIURL
        final apiURL = await getApiURL();
        _appCtrl.setApiURL(apiURL);
        Logger.info(apiURL);
        initSocketio();
      } catch (e) {
        Logger.info(e);
        return;
      }
      Logger.info("await seupStoreDetails...");
      await setupStoreDetails();
      // If server is still down
      Logger.info("Server down: ${_appCtrl.serverDown.value}");
      if (!_appCtrl.serverDown.value || dev) {
        setupUser();
        setupStoreDetails();
      }
    }
  }

  Widget refreshBtn() {
    return TuButton(
      text: "Refresh",
      onPressed: _init,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: Container(
          width: screenSize(context).width,
          height: screenSize(context).height,
          alignment: Alignment.center,
          color: const Color.fromRGBO(141, 96, 78, 1),
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
