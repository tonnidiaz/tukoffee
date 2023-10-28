import "dart:async";
import "dart:math";
import "package:cloudinary/cloudinary.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:socket_io_client/socket_io_client.dart" as io;
import "package:via_logger/log_record.dart";
import "package:via_logger/output.dart";
import "colors.dart";
import "constants.dart";

const hivePath = "Tunedbass/db/hive_db/tukoffee";
String randomImg() {
  return "https://picsum.photos/80/80?random==${Random().nextInt(100)}";
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

String getCloudinaryFolder(
    {required String storeName, String folder = "products"}) {
  return "TunedBass/$storeName/${DEV ? "DEV" : "PROD"}/images/$folder";
}

const paystackTestURL = "https://paystack.com/pay/spy9pzsw5u";
const paystackTestURLLive = "https://paystack.com/pay/8f3nqkd4vg";

enum ProductStatus { all, instock, out, topSelling, special, sale }

final signedCloudinary = Cloudinary.signedConfig(
    apiKey: cloudinaryApiKey,
    apiSecret: cloudinarySecretKey,
    cloudName: cloudinaryCloudName);

final List<String> collectionTimes = [
  "asap",
  "10:15",
  "10:30",
  "10:45",
  "11:00",
  "11:15",
  "11:30",
  "11:45",
  "12:00",
  "12:15",
  "12:30",
  "12:45",
  "13:00",
  "13:15",
  "13:30",
  "13:45",
  "14:00",
  "14:15",
  "14:30",
  "14:45",
  "15:00",
  "15:15",
  "15:30",
  "15:45",
  "16:00",
  "16:15",
  "16:30",
  "16:45",
  "17:00",
  "17:15",
  "17:30",
  "17:45",
  "18:00",
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

const mFieldBG = Color.fromRGBO(244, 247, 248, 1);
const mFieldBG2 = Color.fromRGBO(231, 234, 235, 1);
final mFieldRadius = BorderRadius.circular(15);

TextTheme tuTextTheme(BuildContext context) {
  return Theme.of(context).textTheme;
}

List<String> reviewStatuses = ["pending", "approved", "rejected"];

const sheetRadius = BorderRadius.only(
    topLeft: Radius.circular(10), topRight: Radius.circular(10));

double topMargin = 4;

io.Socket? socket;

bool backEnabled = true;

class Console extends Output {
  @override
  void output(LogRecord record) {
    ///Custom print style
    debugPrint('[${record.path}:${record.lineNumber}] ${record.message}');
  }
}
