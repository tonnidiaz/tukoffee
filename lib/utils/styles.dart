import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static TextStyle h1 =
      GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w900);
  static TextStyle h2({Color? color, bool isLight = false}) {
    return GoogleFonts.rubik(
        fontSize: 18,
        fontWeight: isLight ? FontWeight.w500 : FontWeight.w800,
        color: color);
  }

  static TextStyle h3({Color? color, bool isLight = false}) {
    return GoogleFonts.rubik(
        fontSize: 16,
        fontWeight: isLight ? FontWeight.w500 : FontWeight.w700,
        color: color);
  }

  static TextStyle label(
      {Color? color, bool isLight = false, bool isBold = false}) {
    return GoogleFonts.rubik(
        fontSize: 16,
        fontWeight: isLight ? FontWeight.w500 : FontWeight.w600,
        color: color);
  }

  static TextStyle h4({Color? color, bool isLight = false}) {
    return GoogleFonts.rubik(
        fontSize: 16,
        fontWeight: isLight ? FontWeight.w500 : FontWeight.w600,
        color: color);
  }

  static TextStyle subtitle =
      GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle title({Color? color, bool isLight = false}) =>
      GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: isLight ? FontWeight.w400 : FontWeight.w600,
          color: color);
  static TextStyle h6 = GoogleFonts.rubik(fontSize: 14);
  static BorderRadius btnRadius = BorderRadius.circular(7);
}
