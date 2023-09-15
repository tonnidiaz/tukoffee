import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common2.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    return Scaffold(
      appBar: childAppbar(title: "About", showCart: false),
      body: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: defaultPadding2,
          //color: cardBGLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoItem(
                  onTap: () {
                    showAboutDialog(
                        context: context,
                        applicationName: appCtrl.storeName.value,
                        applicationIcon: Obx(
                          () => Image.network(
                            appCtrl.storeImage['url'],
                            
                            width: 70,
                            height: 70,
                          ),
                        ),
                        applicationVersion: appCtrl.appVersion.value);
                  },
                  child: const Text("About app")),
              InfoItem(
                  onTap: () {
                    pushNamed(context, '/admin/settings');
                  },
                  child: Obx(() => Text("About ${MainApp.appCtrl.storeName}"))),
              InfoItem(
                  onTap: () async {
                    try {
                      await launchUrl(Uri.parse(appCtrl.developerLink.value));
                    } catch (e) {
                      clog(e);
                    }
                  },
                  child: const Text("About Developer")),
              InfoItem(
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const UpdatesView();
                        });
                    /*  appCtrl.sethasUpdates(false);
                    // check for update
                    var t = showToast("Checking for updates...",
                        autoDismiss: false);
                    t.show(context);
                    await Future.delayed(Duration(seconds: 5));
                    appCtrl.sethasUpdates(true);
                    if (t.isShowing() && t.isDismissible) {
                      t.dismiss();
                    } */
                  },
                  child: tuTableRow(
                      const Text("Check for updates"),
                      Obx(() => Visibility(
                            visible: appCtrl.hasUpdates.value,
                            child: const CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          )))),
            ],
          )),
    );
  }
}

class UpdatesView extends StatelessWidget {
  const UpdatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: childAppbar(showCart: false),
      body: Container(
        padding: defaultPadding2,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Checking for updates..."),
          ],
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final Function()? onTap;
  final Widget? child;
  const InfoItem({super.key, this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          height: 40,
          padding: defaultPadding,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: .5),
          child: child),
    );
  }
}
