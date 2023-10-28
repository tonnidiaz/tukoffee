import "package:flutter/material.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/views/admin/index.dart";
import "package:lebzcafe/views/admin/reviews.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:via_logger/logger.dart";
import "package:get/get.dart";

import "../../utils/colors.dart";

import "/widgets/common.dart";

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashCtrl _ctrl = Get.find();
  Future<void> _setupDash() async {
    try {
      _ctrl.setData(initDashData);
      var res = await apiDio().get("/admin/dash");
      final data = res.data;
      _ctrl.setData(data);
    } catch (e) {
      Logger.info(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _setupDash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _setupDash();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Obx(
                () => Visibility(
                    visible: _ctrl.data["customers"].isEmpty,
                    child: const LinearProgressIndicator()),
              ),
            ),
            SliverFillRemaining(
              child: Container(
                padding: EdgeInsets.all(topMargin),
                width: double.infinity,
                child: Obx(
                  () => StaggeredGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    children: [
                      ItemCard(
                        title: "Products",
                        onTap: () {
                          _ctrl.tab.value = 1;
                        },
                        icon: svgIcon(
                            name: "br-box-open-full",
                            color: TuColors.coffee2,
                            size: 24),
                        subtitle: "${_ctrl.data["products"].length}",
                      ),
                      ItemCard(
                        title: "Orders",
                        onTap: () {
                          _ctrl.tab.value = 2;
                        },
                        icon: svgIcon(
                          name: "br-person-dolly",
                          size: 24,
                          color: Colors.orangeAccent,
                        ),
                        subtitle: "${_ctrl.data["orders"].length}",
                      ),
                      ItemCard(
                        title: "Accounts",
                        onTap: () {
                          _ctrl.tab.value = 3;
                        },
                        icon: svgIcon(
                          name: "br-users",
                          size: 24,
                          color: TuColors.text2,
                        ),
                        subtitle: "${_ctrl.data["customers"].length}",
                      ),
                      ItemCard(
                        title: "Product reviews",
                        onTap: () {
                          pushTo(const ProductsReviews());
                        },
                        icon: svgIcon(
                          name: "br-comment-user",
                          size: 24,
                          color: TuColors.success,
                        ),
                        subtitle: "${_ctrl.data["reviews"].length}",
                      ),
                      ItemCard(
                        title: "Store Info",
                        onTap: () {
                          pushNamed("/store/info");
                        },
                        icon: Icon(
                          Icons.info_outline,
                          color: TuColors.text2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Function()? onTap;
  final Color? avatarBG;
  final Color? avatarFG;
  final dynamic icon;
  final String title;
  final String? subtitle;
  const ItemCard(
      {super.key,
      this.onTap,
      this.avatarBG,
      this.avatarFG,
      this.icon = "A",
      this.title = "",
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    final bRad = BorderRadius.circular(5);
    return Material(
      color: cardBGLight,
      borderRadius: bRad,
      child: InkWell(
          onTap: onTap,
          borderRadius: bRad,
          /*   my: 0,
          borderSize: 0, */
          //radius: 0,
          hoverColor: const Color.fromRGBO(236, 236, 236, 0.5),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: appBGLight,
                      child: icon,
                    ),
                    mY(6),
                    subtitle == null
                        ? none()
                        : Text(
                            subtitle!,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: TuColors.text2),
                          ),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: TuColors.text),
                    ),
                  ]))),
    );
  }
}
