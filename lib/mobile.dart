import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/theme.dart';
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
    Map<String, Widget Function(BuildContext)> routes = {};
    for (var page in pages) {
      routes[page.name] = (context) => page.widget;
    }
    return MaterialApp(
      theme: tuTheme(_darkMode), //(Brightness.light),
      routes: routes,
      debugShowCheckedModeBanner: false,
      initialRoute: "/rf",
      builder: (context, child) {
        return child!;
      },
    );
  }
}
