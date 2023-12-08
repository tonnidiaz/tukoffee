// ignore_for_file: use_build_context_synchronously

import "dart:convert";
import "dart:io";
import "package:cloudinary/cloudinary.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/controllers/store_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:get/get.dart" as getx;
import "package:hive_flutter/hive_flutter.dart";

import "package:tu/tu.dart";
import "/utils/constants.dart";
import "package:window_manager/window_manager.dart";
import "constants2.dart";

/* void cclog(dynamic p) {
  //debugPrint("$tag: $p");
  clog(p);
}
 */
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

Future<List> rateProduct(dynamic pid, Map<String, dynamic> rating) async {
  try {
    final res = await apiDio()
        .post("/products/rate?pid=$pid", data: {"rating": rating});
    return [null, res.data];
  } catch (e) {
    return ["Something went wrong!", null];
  }
}

setupStoreDetails({Map<String, dynamic>? data}) async {
  final AppCtrl appCtrl = getx.Get.find();
  try {
    clog("SETTING UP STORE DETAILS");
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
    clog(e);
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

Future<Map?> addEditProduct(BuildContext context, Map<String, dynamic> product,
    {String mode = "add"}) async {
  clog("$mode product...");
  try {
    final url = "/products/$mode";
    final res = await apiDio().post(url, data: product);
    clog(res.data);
    return res.data;
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

double fullHeight(BuildContext context) {
  return screenSize(context).height - (statusBarH(context) + appBarH);
}

void pop(BuildContext context) {
  return Navigator.pop(context);
}

Future<String> tbURL() async {
  if (dev) return "$localhost:3000";
  final res = await dio.get(
    githubURL,
  );
  return jsonDecode(res.data)["baseURL"];
}

Future<String> getApiURL() async {
  if (dev) return "$localhost:8000";
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
