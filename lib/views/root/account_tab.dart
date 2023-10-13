import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/auth/logout.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/feedback_form.dart';
import 'package:lebzcafe/widgets/tu/updates2.dart';
import 'package:get/get.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = MainApp.appCtrl;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account",
        ),
        titleSpacing: 14,
        actions: const [CartBtn()],
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Column(
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
                            pushNamed(context, '/account/profile');
                          },
                          child: const Text("Profile")),
                      InfoItem(
                          onTap: () {
                            pushNamed(context, '/cart');
                          },
                          child: const Text("Cart")),
                      InfoItem(
                          onTap: () {
                            pushNamed(context, '/orders');
                          },
                          child: const Text("Orders")),
                      InfoItem(
                          onTap: () {
                            pushNamed(context, '/store/details');
                          },
                          child: const Text("Store details")),
                    ],
                  ),
                ),
                Obx(() => Visibility(
                      visible: appCtrl.user['_id'] != null &&
                          appCtrl.user['permissions'] > 0,
                      child: Container(
                          color: cardBGLight,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(children: [
                            InfoItem(
                                onTap: () {
                                  pushNamed(context, '/admin/dashboard');
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
                          pushNamed(context, '/settings');
                        },
                        child: const Text("Settings")),
                    InfoItem(
                        onTap: () {
                          TuFuncs.showTDialog(context, const FeedbackForm());
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
                      bool logged = appCtrl.user['_id'] != null;
                      return TuButton(
                        text: !logged ? "Login" : "Logout",
                        bgColor: Colors.black87,
                        width: double.infinity,
                        onPressed: () {
                          if (logged) {
                            pushTo(context, const LogoutPage());
                          } else {
                            pushNamed(context, '/auth/login');
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
