import 'dart:async';
import 'dart:math';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'constants.dart';

const hivePath = "Tunedbass/db/hive_db/tukoffee";
String randomImg() {
  return "https://loremflickr.com/g/320/240/tea?random=${Random().nextInt(100)}";
}

ThemeData buildTheme(brightness) {
  var baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    appBarTheme: AppBarTheme(
        centerTitle: true,
        toolbarHeight: appBarH,
        //  iconTheme: IconThemeData(color: ),
        titleTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w800, color: Colors.black87),
        backgroundColor: appBGLight,
        elevation: 0,
        foregroundColor: Colors.black87), // end appbar
    //canvasColor: Colors.purple,
    colorScheme: const ColorScheme.light(
      background: Colors.pink,
    ),
    cardColor: cardBGLight,
    primaryColor: Colors.brown,
    tabBarTheme: const TabBarTheme(
        labelColor: Colors.black87,
        indicatorColor: Colors.brown,
        dividerColor: Colors.brown),
    textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
  );
}

const uploadPreset = "t6pie4cq";
const cloudinaryApiKey = "262393494665286";
const cloudinarySecretKey = "eQKKfmQ__WkvkCoPaUScVsqbj_o";
const cloudinaryCloudName = "sketchi";
final cloudinary = Cloudinary.unsignedConfig(
  cloudName: cloudinaryCloudName,
);

const cloudinaryURL =
    "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload";
const dev = true;

String getCloudinaryFolder(
    {required String storeName, String folder = "products"}) {
  return "TunedBass/$storeName/${dev ? "DEV" : "PROD"}/images/$folder";
}

enum ProductStatus { all, instock, out }

final signedCloudinary = Cloudinary.signedConfig(
    apiKey: cloudinaryApiKey,
    apiSecret: cloudinarySecretKey,
    cloudName: cloudinaryCloudName);

final List<String> collectionTimes = [
  "asap",
  "10:15",
  '10:30',
  '10:45',
  '11:00',
  "11:15",
  '11:30',
  '11:45',
  '12:00',
  "12:15",
  '12:30',
  '12:45',
  '13:00',
  "13:15",
  '13:30',
  '13:45',
  '14:00',
  "14:15",
  '14:30',
  '14:45',
  '15:00',
  "15:15",
  '15:30',
  '15:45',
  '16:00',
  "16:15",
  '16:30',
  '16:45',
  '17:00',
  "17:15",
  '17:30',
  '17:45',
  '18:00',
];

var dummyLocations = [
  '50 Davies, Kimberley, Northern Cape 8301, South Africa',
  '50 Davies Street, Westonaria, Gauteng 1779, South Africa',
  '50 Davies Street, Johannesburg, Johannesburg, Gauteng 2094, South Africa',
  '50 Sutton Street, Port Elizabeth, Eastern Cape 6001, South Africa',
  '50 Davies Street, Surry Hills New South Wales 2010, Australia'
];

var dummyLocations2 = [
  'Gill Street, Vanderbijlpark, Gauteng 1911, South Africa',
  '16 Gill Street, Bloemfontein, Bloemfontein, Free State 9301, South Africa',
  '16 Gill Street, Johannesburg, Johannesburg, Gauteng 2198, South Africa',
  '16 Gill Street, Germiston, Gauteng 1401, South Africa',
  '16 Gill Street, Klein Brakrivier, Western Cape 6503, South Africa'
];

var dummLocs = [
  {
    "name": 'Gill Street, Vanderbijlpark, Gauteng 1911, South Africa',
    "coordinates": [27.82563, -26.6948865]
  },
  {
    "name":
        '16 Gill Street, Bloemfontein, Bloemfontein, Free State 9301, South Africa',
    "coordinates": [26.173052, -29.143129]
  },
];

class Debouncer {
  final int milliseconds;

  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

const mapboxToken =
    "sk.eyJ1IjoidG9ubmlkaWF6IiwiYSI6ImNsbWJobm96NTA0amQzZHA0NzRvYnJvaW8ifQ.rJV4SlKxtuoP6YiegoMBfg";
const mapboxPublicToken =
    "pk.eyJ1IjoidG9ubmlkaWF6IiwiYSI6ImNsbTg5YTk1eTBhaHczZHJyYmR1ZHhsM2cifQ.ockDRt9KPFkge-1zeyDhhA";
