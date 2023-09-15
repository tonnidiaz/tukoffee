import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frust/controllers/appbar.dart';
import 'package:frust/controllers/products_ctrl.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/views/auth/create.dart';
import 'package:frust/views/orders.dart';
import 'package:frust/widgets/form_view.dart';
import 'package:frust/widgets/loader.dart';
import 'package:get/get.dart';
import 'controllers/app_ctrl.dart';
import 'mobile.dart';
import 'utils/constants.dart';
import 'utils/functions.dart';
import 'views/rf.dart';
import 'widgets/drawer.dart';
import 'widgets/titlebars.dart';

enableWebviewDebugging() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    //await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
}

void main() async {
  await initHive();
  WidgetsFlutterBinding.ensureInitialized();
  //setupWindowManager();

  runApp(
    const MainApp(),
  );
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  void initState() {
    super.initState();
    Get.put(FormViewCtrl());
    Get.put(AppCtrl());
    Get.put(StoreCtrl());
    Get.put(AppBarCtrl());
    Get.put(ProductsCtrl());
    Get.put(OrdersCtrl());
    Get.put(SignupCtrl());
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RFPage(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static FormViewCtrl formViewCtrl = Get.put(FormViewCtrl());
  static AppCtrl appCtrl = Get.put(AppCtrl());
  static StoreCtrl storeCtrl = Get.put(StoreCtrl());
  static AppBarCtrl appBarCtrl = Get.put(AppBarCtrl());
  static ProductsCtrl productsCtrl = Get.put(ProductsCtrl());
  static OrdersCtrl ordersCtrl = Get.put(OrdersCtrl());
  static SignupCtrl signupCtrl = Get.put(SignupCtrl());

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
    Get.put(OrdersCtrl());
    Get.put(SignupCtrl());
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
    return Obx(() =>
        !MainApp.appCtrl.ready.value || MainApp.appCtrl.storeName.isEmpty
            ? const TuLoader()
            : const MobileApp());
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
      appBar: widget.appBar ??
          mobileTitleBar(
              context: context, bottom: widget.bottom, actions: widget.actions),
      // drawer: const TDrawer(),
      endDrawer: const TDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          clog("Refreshing...");
          if (widget.onRefresh != null) {
            await widget.onRefresh!();
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: screenSize(context).height - (appBarH + statusBarH(context)),
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
