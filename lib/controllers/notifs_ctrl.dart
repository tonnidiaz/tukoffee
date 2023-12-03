import "package:awesome_notifications/awesome_notifications.dart";
import "package:get/get.dart";
import "package:lebzcafe/views/order/index.dart";

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
    final payload = receivedAction.payload;
    if (payload != null && payload["orderId"] != null) {
      // Navigate into pages, avoiding to open the notification details page over another details page already opened
      /* MobileApp.navigatorKey.currentState?.pushAndRemoveUntil("/order",
          (route) => (route.settings.name != "/order") || route.isFirst,
          arguments: OrderPageArgs(id: payload["orderId"]!)); */
      Get.offAllNamed('/');
      Get.to(OrderPage(id: '${payload['orderId']}'));
    }

    return;
  }
}
