import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/theme.dart';
import 'package:frust/views/account/reviews/index.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/constants.dart';
import 'utils/colors.dart';

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

  @override
  void initState() {
    super.initState();
    ever(MainApp.appCtrl.darkMode, (val) {
      _setDarkMode(val);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    appCtx = context;
    Map<String, Widget Function(BuildContext)> routes = {};
    for (var page in pages) {
      /* TODO: CHANGE THIS FOR NO HOME WIDGET */
      if (page.name != '/nfn') routes[page.name] = (context) => page.widget;
    }
    return MaterialApp(
      theme: tuTheme(_darkMode), //(Brightness.light),
      scrollBehavior: MyCustomScrollBehavior(),
      routes: routes,
      debugShowCheckedModeBanner: false,
      initialRoute: "/admin/dashboard",
      //home: MyReviewsPage(),
      builder: (context, child) {
        return child!;
      },
    );
  }
}
