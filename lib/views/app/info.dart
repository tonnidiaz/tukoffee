import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common.dart';
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
                    TuFuncs.showBottomSheet(
                        context: context, widget: const UpdatesView());
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

class UpdatesView extends StatefulWidget {
  const UpdatesView({super.key});

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  int? _updates;
  _setUpdates(int? val) {
    setState(() {
      _updates = val;
    });
  }

  _checkUpdates() async {
    _setUpdates(null);
    await Future.delayed(Duration(seconds: 3));
    _setUpdates(4);
  }

  _init() async {
    _checkUpdates();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(showCart: false),
      onRefresh: () async {
        await _checkUpdates();
      },
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(42, 42, 42, 1),
        onPressed: () {
          _checkUpdates();
        },
        child: const Icon(Icons.refresh),
      ),
      child: Container(
        padding: defaultPadding2,
        width: double.infinity,
        height: screenSize(context).height - appBarH - statusBarH(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _updates != null
                ? Column(
                    children: [
                      TextButton(
                        child: Text(
                          "($_updates) Updates found",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {},
                      ),
                      TuButton(
                        text: "Update now",
                        onPressed: () {},
                      ),
                    ],
                  )
                : Text(
                    "Checking for updates...",
                    style: Styles.h3(),
                    textAlign: TextAlign.center,
                  ),
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
