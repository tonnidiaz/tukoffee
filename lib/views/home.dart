// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/search.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/tu/product_circle.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/functions.dart';
import '../widgets/common3.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class HomeCtrl extends GetxController {
  Rx<List?> topSelling = (null as List?).obs;
  setTopSelling(List? val) {
    topSelling.value = val;
  }

  Rx<List?> special = (null as List?).obs;
  setSpecial(List? val) {
    special.value = val;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _appCtrl = MainApp.appCtrl;
  final _ctrl = Get.put(HomeCtrl());

  _getToSelling() async {
    try {
      _ctrl.setTopSelling(null);
      final res = await getProducts(q: 'top-selling');
      _ctrl.setTopSelling(res.data['data']);
    } catch (e) {
      _ctrl.setTopSelling([]);
      errorHandler(e: e, context: context);
    }
  }

  _getSpecial() async {
    try {
      _ctrl.setSpecial(null);
      final res = await getProducts(q: 'special');
      _ctrl.setSpecial(res.data['data']);
    } catch (e) {
      _ctrl.setSpecial([]);
      errorHandler(e: e, context: context);
    }
  }

  _init() async {
    _getToSelling();
    _getSpecial();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
      //getStores(storeCtrl: _storeCtrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
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
              TuFormField(
                hint: "Search",
                prefixIcon: TuIcon(Icons.search),
                radius: 50,
                onTap: () {
                  TuFuncs.showBottomSheet(
                      context: context, widget: const SearchPage());
                },
              ),
              mY(15),
              Obx(
                () => _ctrl.topSelling.value != null &&
                        _ctrl.topSelling.value!.isEmpty
                    ? none()
                    : Column(
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
                            child: Obx(
                              () => Row(
                                  children: _ctrl.topSelling.value == null
                                      ? List.generate(
                                          10,
                                          (index) => const TuProductCircle(
                                              dummy: true))
                                      : _ctrl.topSelling.value!.map((it) {
                                          return TuProductCircle(
                                            subtitle:
                                                "R${roundDouble(it['price'].toDouble(), 2)}",
                                            title: "${it['name']}",
                                            img: it['images'].isNotEmpty
                                                ? it['images'][0]['url']
                                                : null,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/product',
                                                  arguments: {
                                                    "pid": it["pid"]
                                                  });
                                            },
                                          );
                                        }).toList()),
                            ),
                          )
                        ],
                      ),
              ),
              mY(15),
              Obx(
                () =>
                    _ctrl.special.value != null && _ctrl.special.value!.isEmpty
                        ? none()
                        : Column(
                            //top-selling section
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's special",
                                style: Styles.title(isLight: false),
                              ),
                              mY(15),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Obx(
                                  () => Row(
                                      children: _ctrl.special.value == null
                                          ? List.generate(
                                              10,
                                              (index) => const TuProductCircle(
                                                  dummy: true))
                                          : _ctrl.special.value!.map((it) {
                                              return TuProductCircle(
                                                subtitle:
                                                    "R${roundDouble(it['price'].toDouble(), 2)}",
                                                img: it['images'].isNotEmpty
                                                    ? it['images'][0]['url']
                                                    : null,
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, '/product',
                                                      arguments: {
                                                        "pid": it["pid"]
                                                      });
                                                },
                                              );
                                            }).toList()),
                                ),
                              )
                            ],
                          ),
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
