import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/views/shop/tab.dart';
import 'package:frust/widgets/common2.dart';
import '../../main.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(title: "Shop"),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.brown,
        tabs: const [
          Tab(
            text: "Trending",
          ),
          Tab(
            text: "Top selling",
          )
        ],
      ),
      child: Container(
        height:
            screenSize(context).height - (appBarH + statusBarH(context) + tabH),
        color: appBGLight,
        child: TabBarView(controller: _tabController, children: const [
          HomeTab(),
          HomeTab(
            q: "top-selling",
          ),
        ]),
      ),
    );
  }
}
