// ignore_for_file: use_build_context_synchronously

import "dart:convert";
import "dart:io";
import "dart:math";

import "package:another_flushbar/flushbar.dart";
import "package:cloudinary/cloudinary.dart";
import "package:dio/dio.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/controllers/store_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:get/get.dart" as getx;
import "package:hive_flutter/hive_flutter.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/widgets/prompt_modal.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:permission_handler/permission_handler.dart";
import "/utils/constants.dart";
import "package:window_manager/window_manager.dart";
import "package:awesome_notifications/awesome_notifications.dart";
import "constants2.dart";

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
  // final appCtrl = MainApp.appCtrl;
  return Flushbar(
    backgroundColor: const Color.fromARGB(255, 236, 236, 236),
    messageColor: isErr ? Colors.red : Colors.black87,
    message: msg,
    duration: autoDismiss ? Duration(seconds: duration) : null,
    animationDuration: const Duration(milliseconds: 500),
    onStatusChanged: (status) {
      /*  if (status == FlushbarStatus.IS_APPEARING) {
        appCtrl.setBackEnabled(false);
      }
      if (status == FlushbarStatus.DISMISSED) {
        appCtrl.setBackEnabled(true);
      } */
    },
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

void pushTo(Widget widget) {
  getx.Get.to(widget);
}

void pushNamed(String name, {Object? arguments}) {
  getx.Get.toNamed(name, arguments: arguments);
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
      final res = await apiDio().get("/store");
      details = res.data;
      appCtrl.setserverDown(false);
    }

    appCtrl.setStore(details["store"]);
    appCtrl.setOwner(details["owner"]);
    appCtrl.setDeveloper(details["developer"]);
    appCtrl.setSlogan(details["store"]["slogan"]);
    appCtrl.setSocials(details["socials"]);
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

setupUser({bool full = true}) async {
  final storeCtrl = MainApp.storeCtrl;
  final appCtrl = MainApp.appCtrl;
  if (full) {
    appCtrl.setReady(false);
  }
  if (appBox == null) {
    appCtrl.setUser({});
    storeCtrl.setcart({});
    appCtrl.setReady(true);
    return;
  }
  var authToken = appBox!.get("authToken");
  clog(authToken);
  if (authToken != null) {
    try {
      final res = await apiDio().post("/auth/login");

      appCtrl.setUser(res.data["user"]);
      setupCart(res.data["user"]["_id"]);
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

void setupCart(String id) async {
  final StoreCtrl storeCtrl = getx.Get.find();
  final AppCtrl appCtrl = getx.Get.find();
  try {
    final res = await apiDio().get("/user/cart?user=$id");
    storeCtrl.setcart(res.data["cart"]);
    appCtrl.setReady(true);
  } catch (e) {
    clog(e);
    appCtrl.setReady(true);
  }
}

logout() async {
  await appBox!.delete("authToken");
  setupUser();
}

void handleDioException(
    {BuildContext? context, required DioException exception, String? msg}) {
  clog("ERROR RESP: ${exception.response}");
  if (exception.response != null &&
      "${exception.response!.data}".startsWith("tuned")) {
    showToast("${exception.response!.data.split("tuned:").last}", isErr: true)
        .show(context ?? appCtx!);
  } else {
    showToast(msg ?? "Something went wrong!", isErr: true)
        .show(context ?? appCtx!);
  }
}

void errorHandler({required e, BuildContext? context, String? msg}) {
  if (e.runtimeType == DioException) {
    handleDioException(
        context: context, exception: e as DioException, msg: msg);
  } else {
    clog(e);
    showToast(msg ?? "Something went wrong!", isErr: true)
        .show(context ?? appCtx!);
  }
}

Future<String?> addProduct(BuildContext context, Map<String, dynamic> product,
    {String mode = "add"}) async {
  clog("$mode product...");
  try {
    final url = "/products/$mode";
    final res = await apiDio().post(url, data: product);
    return "${res.data["pid"]}";
  } catch (e) {
    gpop();
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
    {String dialogTitle = "Import image file",
    String exts = "jpg",
    FileType type = FileType.image}) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: type,
    );

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
        useSafeArea: true,
        isScrollControlled: full,
        context: context,
        builder: (context) => widget);
  }

  static showTDialog(BuildContext context, Widget widget) {
    return showDialog(
        useRootNavigator: false,
        context: context,
        barrierColor: const Color.fromRGBO(0, 0, 0, 0.03),
        builder: (context) => widget);
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
        "X-RapidAPI-Key": "71e962e760mshe177840eb7630a1p1ce7a7jsncff43c280599",
        "X-RapidAPI-Host": "geocode-address-to-location.p.rapidapi.com"
      }),
      cancelToken: token);
}

getStores({required StoreCtrl storeCtrl}) async {
  try {
    storeCtrl.setStores(null);
    final res = await apiDio().get("/stores");
    storeCtrl.setStores(res.data["stores"]);
  } catch (e) {
    clog(e);
    storeCtrl.setStores([]);
  }
}

Future<CloudinaryResponse> uploadImg(File file,
    {required AppCtrl appCtrl, Function(int, int)? onUpload}) async {
  return await cloudinary.unsignedUpload(
      uploadPreset: uploadPreset,
      file: file.path,
      publicId:
          "${appCtrl.store["name"]}_-_product_-_epoch-${DateTime.now().millisecondsSinceEpoch}",
      resourceType: CloudinaryResourceType.image,
      folder: getCloudinaryFolder(storeName: appCtrl.store["name"]),
      progressCallback: onUpload);
}

Future<Response<dynamic>> getProducts({String? q}) async {
  return await apiDio().get("/products?q=$q");
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future requestStoragePermission() async {
  clog("Requesting...");

  return await Permission.storage.request().isGranted;
}

double fullHeight(BuildContext context) {
  return screenSize(context).height - (statusBarH() + appBarH);
}

void pop(BuildContext context) {
  return Navigator.pop(context);
}

void gpop() {
  getx.Get.back();
}

sleep(int ms) async {
  return await Future.delayed(Duration(milliseconds: ms));
}

Future<String> tbURL() async {
  if (DEV) return "$localhost:3000";
  final res = await dio.get(
    githubURL,
  );
  return jsonDecode(res.data)["baseURL"];
}

Future<String> getApiURL() async {
  if (DEV) return "$localhost:8000";
  final res = await dio.get(
    githubURL,
  );
  return jsonDecode(res.data)["lebzcafeURL"];
}

Future<Map<String, dynamic>?> checkUpdates() async {
  final res =
      await dio.get("${await tbURL()}/api/app/updates/check", queryParameters: {
    "uid": "com.tb.tukoffee",
    "v": MainApp.appCtrl.appVersion,
  });
  final ret = res.data.runtimeType == String ? null : res.data;
  return ret;
}

bool autoCheck() {
  final acu = appBox!.get("AUTO_CHECK_UPDATES");
  final autoCheck = acu == null || acu;
  return autoCheck;
}

initNotifs() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: "order_channel_group",
            channelKey: "order_channel",
            channelName: "Order notifications",
            channelDescription: "Notification channel for order creation",
            defaultColor: TuColors.primary,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: "order_channel_group",
            channelGroupName: "Basic group")
      ],
      debug: true);
}

requestNotifsPermission(BuildContext context) {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    clog("Allowed: $isAllowed");
    if (Platform.isLinux) return;
    if (!isAllowed) {
      TuFuncs.showTDialog(
          context,
          PromptDialog(
            title: "Notifications permission",
            msg: "The app requires permission to send notifications",
            onOk: () {
              // This is just a basic example. For real apps, you must show some
              // friendly dialog box before call the request method.
              // This is very important to not harm the user experience
              AwesomeNotifications().requestPermissionToSendNotifications();
            },
          ));
    }
  });
}
