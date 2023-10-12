import 'dart:io';

import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/tab_item.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  final _storeCtrl = MainApp.storeCtrl;
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/icons/box-open-full.svg';
    final Widget svgIcon = SvgPicture.asset(assetName,
        color: Colors.red, semanticsLabel: 'A red up arrow');

    final border = OutlineInputBorder(
        borderRadius: mFieldRadius,
        borderSide: BorderSide(color: TuColors.fieldBG, width: .2));
    return Scaffold(
        appBar: childAppbar(showCart: false),
        body: Container(
            padding: defaultPadding,
            child: tuColumn(
              min: true,
              children: [
                const Text("Small text"),
                mY(5),
                const Text("Small text"),
                mY(5),
                const Text("Small text"),
                Chip(
                  visualDensity: VisualDensity.defaultDensityForPlatform(
                      TargetPlatform.android),
                  label: Text(
                    "My chip",
                  ),
                  backgroundColor: Colors.blue,
                ),
                mY(20),
                svgIcon
              ],
            )),
        bottomNavigationBar: MBottomBar());
  }
}

class MButton extends StatelessWidget {
  const MButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor:
                TuColors.coffee1, //const Color.fromRGBO(26, 92, 255, 1),
            shadowColor: TuColors
                .coffee1Shadow, // const Color.fromRGBO(26, 92, 255, .5),
            elevation: 5,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13))),
        child: const Text("Button"),
      ),
    );
  }
}

class MBottomBar extends StatefulWidget {
  const MBottomBar({super.key});

  @override
  State<MBottomBar> createState() => _MBottomBarState();
}

class _MBottomBarState extends State<MBottomBar> {
  int _tab = 0;
  final List<TabItem> items = [
    const TabItem(
      icon: Icons.home,
      // title: 'Home',
    ),
    const TabItem(
      icon: Icons.search_sharp,
      title: 'Shop',
    ),
    const TabItem(
      icon: Icons.favorite_border,
      title: 'Wishlist',
    ),
    const TabItem(
      icon: Icons.shopping_cart_outlined,
      title: 'Cart',
    ),
    const TabItem(
      icon: Icons.account_box,
      title: 'profile',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BottomBarInspiredInside(
      items: items,
      backgroundColor: cardBGLight,
      color: Colors.black54,
      colorSelected: Colors.black87,
      indexSelected: _tab,
      onTap: (int index) => setState(() {
        _tab = index;
      }),
      animated: true,
      chipStyle:
          const ChipStyle(convexBridge: true, background: Colors.black12),
      itemStyle: ItemStyle.circle,
    );
  }
}
