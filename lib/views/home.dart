import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import '../utils/functions.dart';
import '../widgets/common3.dart';
import 'package:get/get.dart';

import 'map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _appCtrl = MainApp.appCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      clog("Getting stores...");
      //getStores(storeCtrl: _storeCtrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      /* appBar: AppBar(
        leading: none(),
        title: const Text("TuKoffee"),
        actions: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              child: const EndDrawerButton())
        ],
      ), */
      child: Container(
        padding: defaultPadding2,
        height: screenSize(context).height - statusBarH(context) - appBarH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              var location = _appCtrl.location;
              return TuFormField(
                label: "Address:",
                prefixIcon: TuIcon(Icons.location_on),
                readOnly: true,
                value: location['name'],
                onTap: () {
                  pushTo(context, MapPage(
                    onSubmit: (addr) {
                      _appCtrl.setLocation(addr);
                    },
                  ));
                },
              );
            }),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TuButton(
                    text: "Shop now",
                    onPressed: () {
                      pushNamed(context, '/shop');
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget tuIconBtn(
    {double? width,
    required IconData icon,
    Function()? onPressed,
    Color? color}) {
  return SizedBox(
    width: width,
    child: IconButton(
      padding: EdgeInsets.zero,
      splashRadius: 25,
      icon: Icon(
        icon,
        color: color,
      ),
      onPressed: onPressed,
    ),
  );
}
