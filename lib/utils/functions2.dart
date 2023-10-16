import 'package:awesome_notifications/awesome_notifications.dart';

createOrderNotification(String orderId) {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: 'order_channel',
          actionType: ActionType.Default,
          title: 'New order',
          body: 'A new order has been placed',
          payload: {'orderId': orderId}));
}
