import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              mY(10),
              Text(
                "The best coffee in town!",
                textAlign: TextAlign.center,
                style: Styles.title(isLight: true),
              ),
              Text(
                "Grab yours now!",
                textAlign: TextAlign.center,
                style: GoogleFonts.pacifico(
                    fontSize: 30, fontWeight: FontWeight.w900),
              ),
              mY(5),
              Obx(() {
                var location = _appCtrl.location;
                return TuFormField(
                  hint: "Search",
                  prefixIcon: TuIcon(Icons.search),
                  radius: 50,
                  value: location['name'],
                  onTap: () {},
                );
              }),
              mY(15),
              Column(
                //top-selling section
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Top selling",
                    style: Styles.title(isLight: false),
                  ),
                  mY(15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(
                            10, (index) => const TuProductCircle())),
                  )
                ],
              ),
              mY(15),
              Column(
                //special section
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's special",
                    style: Styles.title(isLight: false),
                  ),
                  mY(15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(
                            10, (index) => const TuProductCircle())),
                  )
                ],
              ),
            ],
          ),
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

class TuProductCircle extends StatelessWidget {
  const TuProductCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(100)),
              child: CircleAvatar(
                // borderRadius: BorderRadius.circular(100),
                backgroundColor: Colors.black12,
                backgroundImage: Image.network(
                  randomImg(),
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.coffee_maker,
                    color: Colors.black54,
                  ),
                ).image,
              )),
          mY(2.5),
          const Text(
            "R40.00",
            style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const Text("La koff")
        ],
      ),
    );
  }
}
