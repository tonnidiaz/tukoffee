import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/services/notifications.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import 'package:lebzcafe/controllers/notifs_ctrl.dart';

import "package:tu/tu.dart";
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

  _checkUpdates() async {
    final mAutoCheck = autoCheck();
    MainApp.appCtrl.setAutoCheckUpdates(mAutoCheck);
    clog("AUTO CHECK: $mAutoCheck");
    if (mAutoCheck && !dev) {
      final res = await checkUpdates();
      if (res != null) {
        Get.bottomSheet(UpdatesView3(
          update: res,
          appName: MainApp.appCtrl.title.value,
        ));
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      NotifsService.requestNotifsPermission(context);
      socket?.on("order", (data) {
        clog("ON ORDER");
        //CREATE NOTIF IF USER IS ADMIN
        if (_appCtrl.user.isNotEmpty &&
            _appCtrl.user["permissions"] != UserPermissions.read) {
          if (data['userId'] != _appCtrl.user['_id']) {
            NotifsService.createOrderNotification("${data['orderId']}");
          }
        }
      });
      _checkUpdates();
      clog("SETTING STATUSBAR COLOR");
      /* SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: colors.bg,
      )); */
    });
  }

  @override
  Widget build(BuildContext context) {
    appCtx = context;
    Map<String, Widget Function(BuildContext)> routes = {};
    for (var page in pages) {
      if (page.to != "/nfn") routes[page.to] = (context) => page.widget;
    }
    return GetMaterialApp(
      navigatorKey: MobileApp.navigatorKey,
      theme: TuTheme(colors: TuColors(), dark: false, context: context)
          .theme(), //(Brightness.light),
      routes: routes,
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      //home: MyReviewsPage(),
      builder: (context, child) {
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.escape): () {
              clog("Popping");
              gpop();
            },
          },
          child: WillPopScope(
            onWillPop: () async {
              clog("BACK ENABLED: $backEnabled");
              return backEnabled;
            },
            child: child!,
          ),
        );
      },
    );
  }
}
