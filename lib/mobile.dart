import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frust/main.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/constants.dart';
import 'utils/colors.dart';

class MobileApp extends StatefulWidget {
  static const mChannel = MethodChannel("$package/channel");
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
      initialRoute: "/cart",
      builder: (context, child) {
        return child!;
      },
    );
  }
}

ThemeData tuTheme(bool dark) {
  final border = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: TuColors.fieldBG, width: 0));
  return ThemeData().copyWith(
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: dark ? appBG : appBGLight,
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle:
            const TextStyle(color: Colors.black87, fontSize: 18),
        fillColor: TuColors.fieldBG,
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 10,
        ),
        /* focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.black54, width: 2)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.red, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.red, width: 2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(width: 2, color: Colors.black26)) */
        focusedBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        enabledBorder: border,
        disabledBorder: border,
      ),
      appBarTheme: AppBarTheme(
          centerTitle: true,
          toolbarHeight: appBarH,
          //  iconTheme: IconThemeData(color: ),
          titleTextStyle: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white70 : Colors.black87),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: dark ? Colors.white70 : Colors.black87),
      tabBarTheme: const TabBarTheme(
          labelColor: Colors.black87,
          indicatorColor: Colors.brown,
          dividerColor: Colors.brown),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      cardColor: cardBGLight,
      colorScheme: ThemeData().colorScheme.copyWith(
            primary: Colors.orange,
          ),
      textTheme: GoogleFonts.poppinsTextTheme());
}
