import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'package:lebzcafe/widgets/prompt_modal.dart';
import 'package:tu/tu.dart';
import "package:via_logger/logger.dart";

class NotifsService {
  static initNotifs() {
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelGroupKey: "order_channel_group",
              channelKey: "order_channel",
              channelName: "Order notifications",
              channelDescription: "Notification channel for order creation",
              defaultColor: Tu.colors.primary,
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

  static requestNotifsPermission(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      Logger.info("Allowed: $isAllowed");
      if (Platform.isLinux) return;
      if (!isAllowed) {
        TuFuncs.dialog(
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

  static createOrderNotification(String orderId) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: "order_channel",
            actionType: ActionType.Default,
            title: "New order",
            body: "A new order has been placed",
            payload: {"orderId": orderId}));
  }

  static createNotif({required String title, required String msg}) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: "order_channel",
            actionType: ActionType.Default,
            title: title,
            body: msg));
  }
}
