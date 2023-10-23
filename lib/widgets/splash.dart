import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions2.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/functions.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

initSocketio() {
  final appCtrl = MainApp.appCtrl;
  clog("initing socketio...");
  socket = IO.io(
      appCtrl.apiURL.value,
      IO.OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
          .setExtraHeaders({'foo': 'bar'}) // optional
          .build());
  socket?.onConnect((_) {
    clog('IO connected');
    socket?.emit('test', 'test');
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
    /*  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black12,
    )); */
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      _init();
    });
  }

  void _init() async {
    // Check for internet connection
    clog('Initi splash...');
    if (_appCtrl.store['name'] != null) return;
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
        initSocketio();
      } catch (e) {
        clog(e);
        return;
      }
      clog("await seupStoreDetails...");
      await setupStoreDetails();
      // If server is still down
      clog("Server down: ${_appCtrl.serverDown.value}");
      if (!_appCtrl.serverDown.value || DEV) {
        setupUser();
        setupStoreDetails();
      }
    }
  }

  Widget refreshBtn() {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
            elevation: .5,
            foregroundColor: Colors.white,
            //backgroundColor: TuColors.medium,
            fixedSize: const Size(150, 35),
            shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.5, color: Colors.white38),
                borderRadius: BorderRadius.circular(5))),
        onPressed: () async {
          clog("REFRESHING");
          _init();
        },
        child: const Text("REFRESH"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: false),
      home: Scaffold(
        body: Container(
          width: screenSize(context).width,
          height: screenSize(context).height,
          alignment: Alignment.center,
          color: Colors.black,
          child: _connected
              ? Obx(() => !_appCtrl.serverDown.value
                  ? Container(
                      width: screenSize(context).width / 2,
                      height: screenSize(context).width / 2,
                      alignment: Alignment.center,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/images/logo.jpg",
                          )),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        h4("Server down!",
                            isLight: true, color: Colors.white70),
                        mY(5),
                        refreshBtn(),
                      ],
                    ))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    h4("No internet access",
                        isLight: true, color: Colors.white70),
                    mY(5),
                    refreshBtn()
                  ],
                ),
        ),
      ),
    );
  }
}
