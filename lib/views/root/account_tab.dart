import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";

import "package:lebzcafe/views/admin/refunds.dart";

import "package:get/get.dart";
import "package:lebzcafe/widgets/titlebars.dart";
import "package:tu/tu.dart";

import "../../widgets/common2.dart";
import "../auth/logout.dart";

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    return Scaffold(
      appBar: tuAppbar(
        title: Text(
          "${appCtrl.store["name"]}",
        ),
        centerTitle: true,
        // titleSpacing: 14,
        actions: const [CartBtn()],
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: defaultPadding2,
            child: Obx(
              () => ClipRRect(
                borderRadius: defaultBorderRadius,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: defaultBorderRadius,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InfoItem(
                              onTap: () {
                                pushNamed("/account/profile");
                              },
                              child: const Text("Profile")),
                          InfoItem(
                              onTap: () {
                                pushNamed("/cart");
                              },
                              child: const Text("Cart")),
                          Visibility(
                            visible: appCtrl.user.isNotEmpty,
                            child: InfoItem(
                                onTap: () {
                                  pushNamed("/orders");
                                },
                                child: const Text("Orders")),
                          ),
                          Visibility(
                            visible: appCtrl.user.isNotEmpty,
                            child: InfoItem(
                                onTap: () {
                                  pushTo(const RefundsPage());
                                },
                                child: const Text("Refunds")),
                          ),
                          InfoItem(
                              onTap: () {
                                pushNamed("/store/info");
                              },
                              child: const Text("About store")),
                          Visibility(
                            visible: dev,
                            child: InfoItem(
                                onTap: () {
                                  pushNamed("/rf");
                                },
                                child: const Text("RF")),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => Visibility(
                          visible: appCtrl.user["_id"] != null &&
                              appCtrl.user["permissions"] > 0,
                          child: Container(
                              color: colors.surface,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              child: Column(children: [
                                InfoItem(
                                    onTap: () {
                                      pushNamed("/admin/dashboard");
                                    },
                                    child: const Text("Admin dashboard")),
                              ])),
                        )),
                    Column(children: [
                      InfoItem(
                          onTap: () {
                            pushNamed("/settings");
                          },
                          child: const Text("Settings")),
                      InfoItem(
                          onTap: () {
                            //     Get.bottomSheet(const Feedba());
                          },
                          child: const Text("Help/Feedback")),
                    ]),
                    TuCard(
                      radius: defaultBorderRadius.bottomLeft.x,
                      child: Obx(
                        () {
                          bool logged = appCtrl.user["_id"] != null;
                          return TuButton(
                            text: !logged ? "Login" : "Logout",
                            bgColor: Colors.black,
                            color: Colors.white,
                            width: double.infinity,
                            onPressed: () {
                              if (logged) {
                                pushTo(const LogoutPage());
                              } else {
                                pushNamed("/auth/login");
                              }
                            },
                          );
                        },
                      ),
                    ),
                    mY(10)
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
