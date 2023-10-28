import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/views/admin/refunds.dart";
import "package:lebzcafe/views/auth/login.dart";
import "package:lebzcafe/views/auth/logout.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/feedback_form.dart";
import "package:get/get.dart";

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${appCtrl.store["name"]}",
        ),
        titleSpacing: 14,
        actions: const [CartBtn()],
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Obx(
              () => Column(
                children: [
                  Container(
                    color: cardBGLight,
                    margin: const EdgeInsets.symmetric(vertical: 2),
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
                          visible: DEV,
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
                            color: cardBGLight,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Column(children: [
                              InfoItem(
                                  onTap: () {
                                    pushNamed("/admin/dashboard");
                                  },
                                  child: const Text("Admin dashboard")),
                            ])),
                      )),
                  Container(
                    color: cardBGLight,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(children: [
                      InfoItem(
                          onTap: () {
                            pushNamed("/settings");
                          },
                          child: const Text("Settings")),
                      InfoItem(
                          onTap: () {
                            TuFuncs.showBottomSheet(
                                context: context, widget: const FeedbackForm());
                          },
                          child: const Text("Help/Feedback")),
                    ]),
                  ),
                  Container(
                    color: cardBGLight,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: defaultPadding,
                    child: Obx(
                      () {
                        bool logged = appCtrl.user["_id"] != null;
                        return TuButton(
                          text: !logged ? "Login" : "Logout",
                          bgColor: Colors.black87,
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
                ],
              ),
            )),
      ),
    );
  }
}
