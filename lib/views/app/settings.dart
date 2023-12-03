// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";

import "package:tu/tu.dart";

import "../../widgets/common.dart";

class OldSettingsPage extends StatelessWidget {
  const OldSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    return Scaffold(
      appBar: childAppbar(title: "Settings", showCart: false),
      body: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: defaultPadding2,
          //color: cardBGLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoItem(
                  onTap: () {
                    pushNamed("/admin/settings");
                  },
                  child: Obx(
                      () => Text("About ${MainApp.appCtrl.store["name"]}"))),
              InfoItem(
                  onTap: () {
                    // TuFuncs.dialog(context, const FeedbackForm());
                    //TODO: feedback view
                  },
                  child: const Text("Help/Feedback")),
              InfoItem(
                  child: tuTableRow(
                      const Text("Version"),
                      FutureBuilder<String>(
                          future: getAppVersion(),
                          builder: (context, snapshot) {
                            return Text("${snapshot.data}");
                          }))),
              InfoItem(
                onTap: () async {
                  /*  TuFuncs.showBottomSheet(
                      context: context,
                      widget: const UpdatesView(),
                      full: true); */
                  //  TuFuncs.showTDialog(context, const UpdatesView2());
                },
                child: const Text("Check updates"),
              ),
              InfoItem(
                child: const Text("Licences"),
                onTap: () async {
                  pushTo(LicensePage(
                    applicationName: appCtrl.store["name"],
                    applicationVersion: await getAppVersion(),
                  ));
                },
              )
            ],
          )),
    );
  }
}
