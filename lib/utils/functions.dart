// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/app_ctrl.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/main.dart';
import 'package:get/get.dart' as getx;
import 'package:hive_flutter/hive_flutter.dart';
import '/utils/constants.dart';
import 'package:window_manager/window_manager.dart';

import 'constants2.dart';

void clog(dynamic p) {
  debugPrint("$tag: $p");
}

void setupWindowManager() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(288, 533),
    //maximumSize: Size(288, 533),
    center: true,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Flushbar showToast(String msg,
    {bool isErr = false, int duration = 2, bool autoDismiss = true}) {
  return Flushbar(
    backgroundColor: const Color.fromARGB(255, 236, 236, 236),
    messageColor: isErr ? Colors.red : Colors.black87,
    message: msg,
    duration: autoDismiss ? Duration(seconds: duration) : null,
    animationDuration: const Duration(milliseconds: 500),
  ); //.show(context);
}

Future<List> rateProduct(dynamic pid, Map<String, dynamic> rating) async {
  try {
    final res = await apiDio()
        .post("/products/rate?pid=$pid", data: {"rating": rating});
    return [null, res.data];
  } catch (e) {
    return ["Something went wrong!", null];
  }
}

bool isNumeric(dynamic s) {
  if (s == null) {
    return false;
  }
  return double.tryParse("$s") != null;
}

void pushTo(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (ctx) => widget));
}

void pushNamed(BuildContext context, String name) {
  Navigator.pushNamed(context, name);
}

double roundDouble(double value, int places) {
  double mod = pow(10.0, places).toDouble();
  return ((value * mod).round().toDouble() / mod);
}

setupStoreDetails({Map<String, dynamic>? data}) async {
  final AppCtrl appCtrl = getx.Get.find();
  try {
    appCtrl.setserverDown(false);
    Map<String, dynamic> details;
    if (data != null) {
      details = data;
    } else {
      final res = await dio.get("$apiURL/store");
      details = res.data;
      appCtrl.setserverDown(false);
    }

    appCtrl.setstoreName(details['name']);
    appCtrl.setStoreAddress(details['address']);
    appCtrl.setStorePhone(details['phone']);
    appCtrl.setownerName(details['ownerName']);
    appCtrl.setownerPhone(details['ownerPhone']);
    appCtrl.setstoreSite(details['site']);
  } catch (e) {
    if (e.runtimeType == DioException) {
      e as DioException;
      appCtrl.setserverDown(true);
      clog(e.response);
    }
  }
}

Future<void> initHive() async {
  if (Platform.isLinux || Platform.isWindows) {
    setupWindowManager();
  }
  try {
    await Hive.initFlutter(hivePath);
    var box = await Hive.openBox("app");
    appBox = box;
    clog("Hive initialized");
  } catch (e) {
    clog(e);
  }
}

setupUser() async {
  final storeCtrl = MainApp.storeCtrl;
  final appCtrl = MainApp.appCtrl;
  appCtrl.setReady(false);
  if (appBox == null) {
    appCtrl.setUser({});
    storeCtrl.setcart({});
    appCtrl.setReady(true);
    return;
  }
  var authToken = appBox!.get("authToken");
  if (authToken != null) {
    try {
      final res = await apiDio().post("/auth/login");

      appCtrl.setUser(res.data['user']);
      setupCart(res.data['user']["phone"]);
    } catch (e) {
      clog(e);
      appCtrl.setUser({});
      storeCtrl.setcart({});
      appCtrl.setReady(true);
    }
  } else {
    appCtrl.setUser({});
    storeCtrl.setcart({});
    appCtrl.setReady(true);
  }
  clog("User setup");
}

void setupCart(String phone) async {
  final StoreCtrl storeCtrl = getx.Get.find();
  final AppCtrl appCtrl = getx.Get.find();
  try {
    final res = await dio.get("$apiURL/user/cart?user=$phone");
    storeCtrl.setcart(res.data["cart"]);
    appCtrl.setReady(true);
  } catch (e) {
    clog(e);
    appCtrl.setReady(true);
  }
}

void logout() async {
  await appBox!.delete("authToken");
  setupUser();
}

void handleDioException(
    {required BuildContext context,
    required DioException exception,
    String? msg}) {
  clog(exception.response);
  if (exception.response != null &&
      "${exception.response!.data}".startsWith("tuned")) {
    showToast("${exception.response!.data.split('tuned:').last}", isErr: true)
        .show(context);
  } else {
    showToast(msg ?? "Something went wrong!", isErr: true).show(context);
  }
}

void errorHandler({required e, required BuildContext context, String? msg}) {
  if (e.runtimeType == DioException) {
    handleDioException(
        context: context, exception: e as DioException, msg: msg);
  } else {
    clog(e);
    showToast(msg ?? "Something went wrong!", isErr: true).show(context);
  }
}

Future<String?> addProduct(BuildContext context, Map<String, dynamic> product,
    {String mode = "add"}) async {
  clog("$mode product...");
  clog(product);
  try {
    final url = "/products/$mode";
    final res = await apiDio().post(url, data: product);
    return "${res.data["pid"]}";
  } catch (e) {
    clog(e);
    if (e.runtimeType == DioException) {
      e as DioException;
      handleDioException(
          context: context, exception: e, msg: "Error adding/editing product!");
    } else {
      showToast("Error adding/editing product!", isErr: true).show(context);
    }
    return null;
  }
}

Future<File?> importFile(
    {String dialogTitle = "Import audio file",
    String exts = "mp3",
    FileType? type}) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle,
        type: type ?? FileType.custom,
        allowedExtensions: type != null ? null : exts.split(","));

    if (result != null) {
      //File file =
      return File(result.files.single.path!);
    } else {
      return null;
    }
  } catch (e) {
    clog(e);
  }
  return null;
}

class TuFuncs {
  static void showBottomSheet(
      {required BuildContext context,
      bool full = true,
      required Widget widget}) {
    showModalBottomSheet(
        isScrollControlled: full,
        context: context,
        builder: (context) => widget);
  }

  static showTDialog(BuildContext context, Widget widget) {
    return showDialog(context: context, builder: (context) => widget);
  }
}

Future<Response> searchLocation(String query,
    {required CancelToken token, int limit = 4}) async {
  const geocodeURL =
      "https://geocode-address-to-location.p.rapidapi.com/v1/geocode/autocomplete";
  return dio.get(geocodeURL,
      queryParameters: {
        "text": query,
        "limit": limit,
        "countrycodes": "za",
        "lang": "en"
      },
      options: Options(headers: {
        'X-RapidAPI-Key': '71e962e760mshe177840eb7630a1p1ce7a7jsncff43c280599',
        'X-RapidAPI-Host': 'geocode-address-to-location.p.rapidapi.com'
      }),
      cancelToken: token);
}

getStores({required StoreCtrl storeCtrl}) async {
  try {
    storeCtrl.setStores(null);
    final res = await apiDio().get('/stores');
    storeCtrl.setStores(res.data['stores']);
  } catch (e) {
    clog(e);
    storeCtrl.setStores([]);
  }
}
