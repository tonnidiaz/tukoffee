import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/services/notifications.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/utils/functions2.dart";
import 'package:lebzcafe/controllers/notifs_ctrl.dart';
import "package:lebzcafe/utils/theme.dart";
import "package:get/get.dart";
import "package:lebzcafe/views/getx/home.dart";
import "package:lebzcafe/widgets/tu/updates3.dart";
import "package:via_logger/logger.dart";
import "/utils/constants.dart";

class MobileApp extends StatefulWidget {
  const MobileApp({Key? key}) : super(key: key);
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  final _appCtrl = MainApp.appCtrl;
  bool _darkMode = false;
  _setDarkMode(bool val) {
    setState(() {
      _darkMode = val;
    });
  }

  final getxPages = [TuPage("/", GetxHomePage())];

  _checkUpdates() async {
    final _autoCheck = autoCheck();
    MainApp.appCtrl.setAutoCheckUpdates(_autoCheck);
    Logger.info("AUTO CHECK: $_autoCheck");
    if (_autoCheck && !DEV) {
      final res = await checkUpdates();
      if (res != null) {
        Get.bottomSheet(UpdatesView3(update: res));
      }
    }
  }

  _setNotifsListeners() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
  }

  @override
  void initState() {
    super.initState();

    _setNotifsListeners();
    ever(_appCtrl.darkMode, (val) {
      _setDarkMode(val);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      NotifsService.requestNotifsPermission(context);
      socket?.on("order", (data) {
        Logger.info("ON ORDER");
        //CREATE NOTIF IF USER IS ADMIN
        if (_appCtrl.user.isNotEmpty &&
            _appCtrl.user["permissions"] != UserPermissions.read) {
          if (data['userId'] != _appCtrl.user['_id']) {
            NotifsService.createOrderNotification("${data['orderId']}");
          }
        }
      });
      _checkUpdates();
      Logger.info("SETTING STATUSBAR COLOR");
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: appBGLight,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    appCtx = context;
    Map<String, Widget Function(BuildContext)> routes = {};
    for (var page in pages) {
      if (page.name != "/nfn") routes[page.name] = (context) => page.widget;
    }
    return GetMaterialApp(
      navigatorKey: MobileApp.navigatorKey,
      theme: tuTheme(_darkMode), //(Brightness.light),
      scrollBehavior: MyCustomScrollBehavior(),
      routes: routes,
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      //home: MyReviewsPage(),
      builder: (context, child) {
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.escape): () {
              Logger.info("Popping");
              gpop();
            },
          },
          child: WillPopScope(
            onWillPop: () async {
              Logger.info("BACK ENABLED: $backEnabled");
              return backEnabled;
            },
            child: child!,
          ),
        );
      },
    );
  }
}
