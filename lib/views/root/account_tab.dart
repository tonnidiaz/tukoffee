import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/widgets/common2.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                    pushNamed(context, '/admin/settings');
                  },
                  child: Obx(
                      () => Text("About ${MainApp.appCtrl.store['name']}"))),
              InfoItem(
                  onTap: () {
                    TuFuncs.showTDialog(context, const FeedbackForm());
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
                  TuFuncs.showTDialog(context, const UpdatesView2());
                },
                child: const Text("Check updates"),
              ),
              InfoItem(
                child: const Text("Licences"),
                onTap: () async {
                  pushTo(
                      context,
                      LicensePage(
                        applicationName: appCtrl.store['name'],
                        applicationVersion: await getAppVersion(),
                      ));
                },
              )
            ],
          )),
    );
  }
}
