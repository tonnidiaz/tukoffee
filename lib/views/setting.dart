import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/common4.dart';
import 'package:lebzcafe/widgets/dialogs/loading_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Container(
        margin: EdgeInsets.only(top: topMargin),
        child: Column(children: [
          InfoItem(
            child: tuTableRow(const Text("Auto check updates"),
                Switch(value: true, onChanged: (val) {})),
          ),
          InfoItem(
              child: tuTableRow(
                  const Text("App version"), Text("${appCtrl.appVersion}"))),
          InfoItem(
            onTap: () async {
              try {
                showLoading(context,
                    widget: const LoadingDialog(
                      msg: 'Checking updates...',
                    ));
                await sleep(1500);
                Get.back();
                Get.bottomSheet(const UpdatesView(updates: {
                  "_id": "65258fc3edb12e71231d0e13",
                  "is_lts": true,
                  "notes": ["Note 1", "Note2", "Note 3"],
                  "date_created": "2023-10-10T17:50:34.701Z",
                  "last_modifed": "2023-10-10T17:50:34.701Z",
                  "app": "65204189961633afa277ffc3",
                  "version": "1.0",
                  "file":
                      "https://github.com/tonnidiaz/tunedapps/releases/download/v1.0/Tukoffee-v0.1.apk",
                  "size": 13.6,
                  "__v": 0
                }));

                return;

                final res = await dio.get(
                    "${await tbURL()}/api/app/updates/check",
                    queryParameters: {
                      "uid": "com.tb.tukoffee",
                      "v": appCtrl.appVersion,
                    });

                clog(res.data);
                if (context.mounted) pop(context);
              } catch (e) {
                if (context.mounted) {
                  pop(context);
                  errorHandler(e: e, context: context);
                }
              }
            },
            child: const Text("Check updates"),
          )
        ]),
      ),
    );
  }
}

class UpdatesView extends StatelessWidget {
  final Map<String, dynamic> updates;
  const UpdatesView({super.key, required this.updates});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: defaultPadding2,
      color: cardBGLight,
      child: SingleChildScrollView(
        child: tuColumn(min: true, children: [
          h3('Updates available'),
          mY(8),
          tuTableRow(Text("Version:"), Text("${updates['version']}")),
          mY(10),
          Text(
            "Release notes",
            style: Styles.h4(),
          ),
          Padding(
            padding: defaultPadding,
            child: tuColumn(children: [
              ...updates['notes'].map((e) => bulletItem(e)).toList()
            ]),
          ),
          TuButton(
            bgColor: TuColors.success,
            width: double.infinity,
            text: "UPDATE NOW",
            onPressed: () async {
              showLoading(context,
                  widget: const LoadingDialog(
                    msg: "Downloading updates...",
                  ));

              await sleep(1500);
              // Close downloader loader
              Get.back();
              Get.back();
            },
          )
        ]),
      ),
    );
  }
}
