import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lebzcafe/controllers/appbar.dart';
import 'package:lebzcafe/controllers/common_ctrls.dart';
import 'package:lebzcafe/controllers/products_ctrl.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/views/auth/create.dart';
import 'package:lebzcafe/widgets/form_view.dart';
import 'package:lebzcafe/widgets/splash.dart';
import 'package:get/get.dart';
import 'controllers/app_ctrl.dart';
import 'mobile.dart';
import 'utils/constants.dart';
import 'utils/functions.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

enableWebviewDebugging() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    //await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
}

void main() async {
  await initHive();
  initNotifs();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  //setupWindowManager();
  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterDownloader.initialize(
        debug:
            true, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl:
            true // option: set to false to disable working with http links (default: false)
        );
  }

  runApp(
    const MainApp(),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static FormViewCtrl formCtrl = Get.put(FormViewCtrl());
  static AppCtrl appCtrl = Get.put(AppCtrl());
  static StoreCtrl storeCtrl = Get.put(StoreCtrl());
  static AppBarCtrl appBarCtrl = Get.put(AppBarCtrl());
  static ProductsCtrl productsCtrl = Get.put(ProductsCtrl());
  static SignupCtrl signupCtrl = Get.put(SignupCtrl());
  static ProgressCtrl progressCtrl = Get.put(ProgressCtrl());
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  void _init() async {
    Get.put(FormViewCtrl());
    Get.put(AppCtrl());
    Get.put(StoreCtrl());
    Get.put(AppBarCtrl());
    Get.put(ProductsCtrl());
    Get.put(SignupCtrl());

    /* SETUP APP VERSION */
    MainApp.appCtrl.appVersion.value = await getAppVersion();
  }

  @override
  void initState() {
    super.initState();

    _init();
    _getDeviceID(MainApp.appCtrl);
  }

  void _getDeviceID(AppCtrl appCtrl) async {
    try {
      if (appCtrl.deviceID.isNotEmpty) return;
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = "";
      if (Platform.isAndroid) {
        var r = await deviceInfo.androidInfo;
        deviceId = r.id;
      } else if (Platform.isWindows) {
        var r = await deviceInfo.windowsInfo;
        deviceId = r.deviceId;
      } else if (Platform.isLinux) {
        var r = await deviceInfo.linuxInfo;
        deviceId = r.machineId ?? "";
      }

      clog('DeviceID: $deviceId');
      appCtrl.setDeviceID(deviceId);
    } catch (e) {
      clog(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Obx(() => MainApp.appCtrl.ready.value &&
              MainApp.appCtrl.store['name'] != null &&
              MainApp.appCtrl.store['name'].isNotEmpty
          ? const MobileApp()
          : const TuSplash()),
    );
  }
}

class PageWrapper extends StatefulWidget {
  final Widget? titleBar;
  final Widget? child;
  final double? padding;
  final Function()? onRefresh;
  final PreferredSizeWidget? bottom;
  final PreferredSizeWidget? appBar;
  final Widget? bottomSheet;
  final Widget? bottomNavBar;
  final int tabLength;
  final List<PopupMenuItem> actions;
  final FloatingActionButton? floatingActionButton;
  const PageWrapper(
      {Key? key,
      this.child,
      this.bottomSheet,
      this.titleBar,
      this.padding,
      this.appBar,
      this.onRefresh,
      this.bottom,
      this.tabLength = 0,
      this.floatingActionButton,
      this.bottomNavBar,
      this.actions = const []})
      : super(key: key);

  @override
  State<PageWrapper> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: RefreshIndicator(
        onRefresh: () async {
          clog("Refreshing...");
          if (widget.onRefresh != null) {
            await widget.onRefresh!();
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: screenSize(context).height -
              (appBarH + statusBarH(context: context)),
          child: SingleChildScrollView(
            physics: widget.onRefresh != null
                ? const AlwaysScrollableScrollPhysics()
                : null,
            child: Padding(
              padding: EdgeInsets.all(widget.padding ?? 0),
              child: widget.child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.bottomNavBar,
      bottomSheet: widget.bottomSheet,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
