import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';

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

createNotif({required String title, required String msg}) {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: 'order_channel',
          actionType: ActionType.Default,
          title: title,
          body: msg));
}

Future<Address?> getAddressFromLatLng(List center) async {
  try {
    Coordinate coordinate =
        Coordinate(latitude: center.first, longitude: center.last);
    Geocoding geocoding =
        await NominatimGeocoding.to.reverseGeoCoding(coordinate);
    return geocoding.address;
  } catch (e) {
    clog(e);
    return null;
  }
}
