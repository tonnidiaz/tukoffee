import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:google_fonts/google_fonts.dart";

var amber = const Color.fromRGBO(255, 193, 7, 1);
var black12 = Colors.black12;

ThemeData tuTheme(bool dark) {
  return ThemeData(
      useMaterial3: false,
      platform: TargetPlatform.linux,
      scaffoldBackgroundColor: appBGLight,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: TuColors.medium,
      ),
      tabBarTheme:
          TabBarTheme(labelColor: TuColors.text2, indicatorColor: Colors.red),
      appBarTheme: AppBarTheme(
          centerTitle: false,
          toolbarHeight: appBarH,

          //  iconTheme: IconThemeData(color: ),
          //titleSpacing: 3,
          titleTextStyle: GoogleFonts.inclusiveSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: dark ? Colors.white70 : TuColors.text2),
          backgroundColor: cardBGLight,
          elevation: 0.5,
          foregroundColor: dark ? Colors.white70 : TuColors.text2),
      colorScheme: ColorScheme.fromSeed(
          primary: TuColors.primary,
          secondary: TuColors.secondary,
          seedColor: TuColors.primary,
          brightness: Brightness.light),
      popupMenuTheme: const PopupMenuThemeData(
        color: cardBGLight,

        //shape: RoundedRectangleBorder(borderRadius: mFieldRadius),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: TuColors.medium,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        labelPadding: const EdgeInsets.only(top: -6, bottom: -4),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero, foregroundColor: TuColors.secondary)),
      textTheme: GoogleFonts.inclusiveSansTextTheme(
        TextTheme(
          bodyMedium: TextStyle(color: TuColors.text, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: TuColors.primary,
          showUnselectedLabels: true,
          unselectedItemColor: TuColors.text2,
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600)),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.only(right: 0, left: 14),
      ));
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
