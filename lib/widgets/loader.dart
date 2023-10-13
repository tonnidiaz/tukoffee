import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/functions.dart';

class TuLoader extends StatefulWidget {
  const TuLoader({super.key});

  @override
  State<TuLoader> createState() => _TuLoaderState();
}

class _TuLoaderState extends State<TuLoader> {
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
    if (_appCtrl.store['name'] != null) return;
    _setConnected(true);
    bool result = await InternetConnectionChecker().hasConnection;
    await Future.delayed(const Duration(milliseconds: 100));
    clog("Connected: $result");
    _setConnected(result);
    if (result) {
      await setupStoreDetails();
      // If server is still down
      clog("Server down: ${_appCtrl.serverDown.value}");
      if (!_appCtrl.serverDown.value) {
        setupUser();
        setupStoreDetails();
      }
    }
  }

  Widget refreshBtn() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: .5,
            foregroundColor: Colors.white,
            backgroundColor: TuColors.coffee1,
            fixedSize: const Size(150, 35),
            shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.5, color: Colors.white38),
                borderRadius: BorderRadius.circular(5))),
        onPressed: () async {
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
          color: TuColors.coffee1,
          child: _connected
              ? Obx(() => !_appCtrl.serverDown.value
                  ? Text(
                      "Tukoffee",
                      style: Styles.h1,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Server down",
                          textAlign: TextAlign.center,
                        ),
                        mY(5),
                        refreshBtn(),
                      ],
                    ))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 40,
                        backgroundColor: TuColors.coffee,
                        child: const Icon(
                          Icons.signal_wifi_off_rounded,
                          color: Colors.white70,
                          size: 40,
                        )),
                    mY(5),
                    refreshBtn()
                  ],
                ),
        ),
      ),
    );
  }
}
