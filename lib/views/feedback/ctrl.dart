import 'package:flutter/material.dart';
import 'package:tu/tu.dart';
import 'package:tu/utils.dart';
import '../../main.dart';

class Ctrl extends GetxController {
  sendFeedback(
      {required Map<String, dynamic> data,
      required BuildContext context}) async {
    try {
      final cancelToken = CancelToken();
      showProgressSheet(onDismiss: () {
        cancelToken.cancel();
      });
      await (await bassDio()).post("/api/message",
          data: {...data, "appName": MainApp.appCtrl.title},
          cancelToken: cancelToken);
      gpop();

      if (context.mounted) {
        showToast("Feedback sent successfully").show(context);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      errorHandler(e: e, msg: "Failed to send feedback");
    }
  }
}
