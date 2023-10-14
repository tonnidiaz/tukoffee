import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/utils/colors.dart';

Widget progressSheet({Color? color, String? msg}) => Visibility(
    child: Container(
        height: 45,
        color: color ?? appBGLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(msg ?? 'Hang on...')],
              ),
            )
          ],
        )));
void showProgressSheet({String? msg}) {
  Get.bottomSheet(progressSheet(msg: msg), isDismissible: false);
}
