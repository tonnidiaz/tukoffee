import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
import 'package:google_fonts/google_fonts.dart';

var amber = const Color.fromRGBO(255, 193, 7, 1);
var black12 = Colors.black12;

ThemeData tuTheme(bool dark) {
  return ThemeData(
      scaffoldBackgroundColor: appBGLight,
      appBarTheme: AppBarTheme(
          centerTitle: false,
          toolbarHeight: appBarH,
          //  iconTheme: IconThemeData(color: ),
          titleTextStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: dark ? Colors.white70 : TuColors.text2),
          backgroundColor: cardBGLight,
          elevation: 0,
          foregroundColor: dark ? Colors.white70 : Colors.black87),
      colorScheme: ColorScheme.fromSeed(
          seedColor: TuColors.primary, brightness: Brightness.light),
      popupMenuTheme: PopupMenuThemeData(
        color: appBGLight,
        //shape: RoundedRectangleBorder(borderRadius: mFieldRadius),
      ),
      textTheme: GoogleFonts.inclusiveSansTextTheme(
        TextTheme(
          bodyMedium: TextStyle(color: TuColors.text, fontSize: 15),
        ),
      ));
}
