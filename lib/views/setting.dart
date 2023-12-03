import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/views/order/index.dart";
import "package:lebzcafe/widgets/dialogs/loading_dialog.dart";
import "package:tu/tu.dart";

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Container(
        margin: const EdgeInsets.only(top: topMargin),
        child: Column(children: [
          InfoItem(
            child: tuTableRow(
                const Text("Auto check updates"),
                Obx(
                  () => Switch(
                      value: appCtrl.autoCheckUpdates.value,
                      onChanged: (val) {
                        appBox!.put("AUTO_CHECK_UPDATES", val);
                        appCtrl.setAutoCheckUpdates(val);
                      }),
                )),
          ),
          InfoItem(
              child: tuTableRow(
                  const Text("App version"), Text("${appCtrl.appVersion}"))),
          InfoItem(
            onTap: () async {
              try {
                showLoading(
                  context,
                  widget: const LoadingDialog(
                    msg: "Checking updates...",
                  ),
                );

                final res = await checkUpdates();
                gpop();
                Get.bottomSheet(UpdatesView3(
                  update: res,
                  appName: appCtrl.title.value,
                ));
              } catch (e) {
                gpop();
                if (context.mounted) {
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
