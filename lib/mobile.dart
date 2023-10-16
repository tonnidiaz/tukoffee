import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/theme.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/views/getx/home.dart';
import 'package:lebzcafe/widgets/tu/updates3.dart';

import '/utils/constants.dart';

class MobileApp extends StatefulWidget {
  const MobileApp({Key? key}) : super(key: key);

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  bool _darkMode = false;
  _setDarkMode(bool val) {
    setState(() {
      _darkMode = val;
    });
  }

  final getxPages = [TuPage('/', GetxHomePage())];

  _checkUpdates() async {
    final _autoCheck = autoCheck();
    MainApp.appCtrl.setAutoCheckUpdates(_autoCheck);
    clog('AUTO CHECK: $_autoCheck');
    if (_autoCheck) {
      final res = await checkUpdates();
      if (res != null) {
        Get.bottomSheet(UpdatesView3(update: res));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    ever(MainApp.appCtrl.darkMode, (val) {
      _setDarkMode(val);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    appCtx = context;
    Map<String, Widget Function(BuildContext)> routes = {};
    for (var page in pages) {
      if (page.name != '/nfn') routes[page.name] = (context) => page.widget;
    }
    return GetMaterialApp(
      theme: tuTheme(_darkMode), //(Brightness.light),
      scrollBehavior: MyCustomScrollBehavior(),
      routes: routes,
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      //home: MyReviewsPage(),
      builder: (context, child) {
        return child!;
      },
    );
  }
}
