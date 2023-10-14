import 'package:flutter/material.dart';
import 'package:lebzcafe/controllers/app_ctrl.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

class TDrawer extends StatefulWidget {
  const TDrawer({super.key});

  @override
  State<TDrawer> createState() => _TDrawerState();
}

class _TDrawerState extends State<TDrawer> {
  final AppCtrl _appCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    final currPage = ModalRoute.of(context)!.settings.name;

    return Drawer(
      width: screenSize(context).width - 35,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
                height: 120,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                    /*  image: DecorationImage(
                        image: Image.asset("assets/images/coffee2.jpg").image), */
                    color: cardBGLight),
                child: Center(
                  child: Text(
                    _appCtrl.store['name'],
                    style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 30,
                        fontWeight: FontWeight.w900),
                  ),
                )),
            TDrawerItem(
                title: "Home",
                index: 0,
                leading: const Icon(Icons.home),
                selected: currPage == "/",
                onTap: () {
                  pushNamed("/");
                }),
            TDrawerItem(
                title: "Shop",
                index: 0,
                leading: const Icon(Icons.storefront),
                selected: currPage == "/shop",
                onTap: () {
                  pushNamed("/shop");
                }),
            Obx(() {
              return !_appCtrl.isAdmin.value
                  ? none()
                  : TDrawerItem(
                      title: "Dashboard",
                      index: 1,
                      leading: const Icon(Icons.space_dashboard),
                      selected: currPage == "/admin/dashboard",
                      onTap: () {
                        pushNamed("/admin/dashboard");
                      });
            }),
            TDrawerItem(
                title: "Cart",
                index: 3,
                leading: const Icon(Icons.shopping_cart),
                selected: currPage == "/cart",
                onTap: () {
                  pushNamed("/cart");
                }),
            /*     Obx(
              () => Visibility(
                visible: _appCtrl.user.isNotEmpty,
                child: TDrawerItem(
                    title: "Orders",
                    index: 4,
                    leading: const Icon(
                      FontAwesomeIcons.truckRampBox,
                      size: 20,
                    ),
                    selected: currPage == "/orders",
                    onTap: () {
                      pushNamed( "/orders");
                    }),
              ),
            ), */
            Visibility(
              visible: dev,
              child: TDrawerItem(
                  title: "Research",
                  index: 6,
                  leading: const Icon(Icons.science),
                  selected: currPage == "/rf",
                  onTap: () {
                    pushNamed("/rf");
                  }),
            ),
          ],
        )),
        Container(
          color: cardBGLight,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => _appCtrl.user.isEmpty
                    ? iconText("Login", Icons.login,
                        fontSize: 18,
                        fw: FontWeight.w400,
                        iconSize: 18, onClick: () {
                        pushNamed("/auth/login");
                      })
                    : PopupMenuButton(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                                onTap: () {
                                  pushNamed("/account");
                                },
                                child: iconText(
                                    "Account", Icons.person_2_rounded)),
                            PopupMenuItem(
                                onTap: () async {
                                  try {
                                    logout();
                                  } catch (e) {
                                    clog(e);
                                  }
                                },
                                child: iconText("Logout", Icons.logout)),
                          ];
                        },
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Visibility(
                              visible: false,
                              child: Container(
                                // width: 35,
                                height: 35,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35 / 2),
                                    border:
                                        Border.all(color: orange, width: 2)),
                                child: Text(
                                  "${_appCtrl.user["first_name"]}",
                                  style: const TextStyle(
                                      //color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              width: 35,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Colors.black54, width: 2)),
                              child: Text(
                                "${_appCtrl.user["first_name"][0].toString().capitalize}${_appCtrl.user["last_name"][0].toString().capitalize}",
                                style: GoogleFonts.poppins(
                                    // color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Row(
                children: [
                  IconButton(
                      padding: const EdgeInsets.only(left: 10),
                      onPressed: () {
                        pushNamed('/app/settings');
                      },
                      splashRadius: 24,
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Color.fromRGBO(33, 33, 33, .8),
                        size: 30,

                        // color: Colors.white,
                      )),
                ],
              )
            ],
          ),
        )
      ]),
    );
  }
}
