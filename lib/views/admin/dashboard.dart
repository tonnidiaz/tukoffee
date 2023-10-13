import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/admin/index.dart';
import 'package:lebzcafe/views/admin/reviews.dart';
import 'package:lebzcafe/widgets/common3.dart';

import 'package:get/get.dart';

import '../../utils/colors.dart';

import '/widgets/common.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashCtrl _ctrl = Get.find();
  void _setupDash() async {
    try {
      var res = await apiDio().get("/admin/dash");
      final data = res.data;
      _ctrl.setData(data);
    } catch (e) {
      clog(e);
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
      body: Container(
        padding: EdgeInsets.all(6),
        width: double.infinity,
        child: Obx(
          () =>  StaggeredGrid.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: [
                    ItemCard(
                      title: "Products",
                      onTap: () {
                        _ctrl.selectedTab.value = 1;
                      },
                      icon: svgIcon(
                          name: "br-box-open-full",
                          color: TuColors.coffee2,
                          size: 24),
                      subtitle: "${_ctrl.data.value['products'].length}",
                    ),
                    ItemCard(
                      title: "Orders",
                      onTap: () {
                        _ctrl.selectedTab.value = 2;
                      },
                      icon: svgIcon(
                        name: 'br-person-dolly',
                        size: 24,
                        color: Colors.orangeAccent,
                      ),
                      subtitle: "${_ctrl.data.value['orders'].length}",
                    ),
                    ItemCard(
                      title: "Accounts",
                      onTap: () {
                        _ctrl.selectedTab.value = 3;
                      },
                      icon: svgIcon(
                        name: 'br-users',
                        size: 24,
                        color: TuColors.text2,
                      ),
                      subtitle: "${_ctrl.data.value['customers'].length}",
                    ),
                    ItemCard(
                      title: "Product reviews",
                      onTap: () {
                        pushTo(context, const ProductsReviews());
                      },
                      icon: svgIcon(
                        name: 'br-comment-user',
                        size: 24,
                        color: TuColors.success,
                      ),
                      subtitle: "${_ctrl.data.value['reviews'].length}",
                    ),
                    ItemCard(
                      title: "Settings",
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/settings');
                      },
                      icon: Icon(
                        Icons.settings_outlined,
                        color: TuColors.text2,
                      ),
                    ),
                  ],
                ),
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
