import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My reviews"),
          bottom: const TabBar(tabs: [
            Tab(
              text: "ITEMS",
            ),
            Tab(
              text: "HISTORY",
            ),
          ]),
        ),
        body: const TabBarView(children: [ItemsTab(), HistoryTab()]),
      ),
    );
  }
}

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: defaultPadding,
      color: cardBGLight,
      child: const Text("items"),
    );
  }
}

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: defaultPadding,
      child: const Text("HISTORY"),
    );
  }
}
