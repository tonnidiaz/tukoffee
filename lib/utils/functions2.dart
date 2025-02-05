import "package:flutter/material.dart";
import "package:dio/dio.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:tu/tu.dart";

class Shiplogic {
  static Future<String> getOrderStatus(Map order) async {
    try {
      final res = await shiplogicDio()
          .get("/tracking/shipments", queryParameters: {
        "tracking_reference": order["shiplogic"]["shipment"]["tracking_code"]
      });
      return res.data["shipments"][0]["status"];
    } catch (e) {
      if (e.runtimeType == DioException) {
        e as DioException;
        clog(e.response);
      }
      return "cancelled";
    }
  }

  static cancelOrder(Map order) async {
    clog("CANCELLING ON SHIPLOGIC...");
    final res = await shiplogicDio().post("/shipments/cancel", data: {
      "tracking_reference": order["shiplogic"]["shipment"]["tracking_code"]
    });
    return res.data;
  }

  static Map<String, dynamic> parseAddr(Map<String, dynamic> addr) {
    return {
      "street_address": addr["street"],
      "local_area": addr["suburb"],
      "city": addr["city"],
      "zone": addr["state"],
      "country": "ZA",
      "code": "${addr["postcode"]}",
      "lat": addr["center"].first,
      "lng": addr["center"].last
    };
  }

  static Future<Map> createShipment(
      {required Map<String, dynamic> from,
      required Map<String, dynamic> to,
      required double total,
      required String ref,
      required int serviceLevelId,
      required List items}) async {
    final appCtrl = MainApp.appCtrl;
    final today = DateTime.now().toLocal();
    final collectionDate = "${today.year}-${today.month}-${today.day}";
    final reqData = {
      "collection_min_date": collectionDate,
      "delivery_min_date": collectionDate,
      "collection_address": {
        "company": appCtrl.store["name"],
        "type": "business",
        ...parseAddr(from)
      },
      "collection_contact": {
        "name": appCtrl.store["name"],
        "mobile_number": from["phone"] ?? appCtrl.store["phone"],
        "email": from["email"] ?? appCtrl.store["email"],
      },
      "declared_value": total,
      "delivery_address": {"type": "residential", ...parseAddr(to)},
      "delivery_contact": {
        "name": to["name"],
        "mobile_number": to["phone"],
        "email": to["email"],
      },
      "parcels": items
          .map(
            (e) => {
              "submitted_width_cm": 13.5,
              "submitted_height_cm": 27.5,
              "submitted_weight_kg": e["weight"]
            },
          )
          .toList(),
      "customer_reference": ref,
      "mute_notifications": false,
      "service_level_id": serviceLevelId
    };
    final res = await shiplogicDio().post("/shipments", data: reqData);
    return res.data;
  }

  static Future<Map?> getRates(
      {required Map<String, dynamic> from,
      required Map<String, dynamic> to,
      required double total,
      required List items}) async {
    try {
      final today = DateTime.now().toLocal();
      final collectionDate = "${today.year}-${today.month}-${today.day}";
      final reqData = {
        "collection_min_date": collectionDate,
        "delivery_min_date": collectionDate,
        "collection_address": {
          "company": MainApp.appCtrl.store["name"],
          "type": "business",
          ...parseAddr(from)
        },
        "declared_value": total,
        "delivery_address": {"type": "residential", ...parseAddr(to)},
        "parcels": items
            .map(
              (e) => {
                "submitted_width_cm": e["width"],
                "submitted_height_cm": e["height"],
                "submitted_weight_kg": e["weight"]
              },
            )
            .toList()
      };
      final r = await shiplogicDio().post("/rates", data: reqData);

      return r.data;
    } catch (e) {
      errorHandler(e: e, context: appCtx!);
      return null;
    }
  }
}

String camelToSentence(String text) {
  return text.replaceAllMapped(RegExp(r"^([a-z])|[A-Z]"),
      (Match m) => m[1] == null ? " ${m[0]}" : m[1]!.toUpperCase());
}

Future<void> checkServer(BuildContext context) async {
  try {
    showProgressSheet();
    await apiDio().get("/hello");
  } catch (e) {
    gpop();
    if (!context.mounted) return;
    TuFuncs.dialog(
        context,
        const TuDialogView(
          title: "Server down",
          hasActions: false,
          content: Text(
            "Unable to create order at this moment. Please try again later.",
            textAlign: TextAlign.center,
          ),
        ));

    throw Error();
  }
}

String toRealTime(String time) {
  String mTime = time.trim().toLowerCase();
  final timeAsList = mTime.split(" ").first.split(":");
  if (mTime.endsWith("am")) {
    if (int.parse(timeAsList.first) == 12) {
      return "00:${timeAsList.last}";
    }
    return mTime.split(" ").first;
  } else if (mTime.endsWith("pm")) {
    if (int.parse(timeAsList.first) == 12) return "12:${timeAsList.last}";
    return "${int.parse(timeAsList.first) + 12}:${timeAsList.last}";
  } else {
    return time;
  }
}
