import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:tu/tu.dart";

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppCtrl appCtrl = Get.find();
    return Visibility(
      visible: false,
      child: Container(
        width: screenSize(context).width,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: footerH,
        alignment: Alignment.center,
        color: const Color.fromRGBO(112, 112, 112, .78),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Copyright © ${DateTime.now().year} | ${appCtrl.store["name"]}",
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            )
          ],
        ),
      ),
    );
  }
}
