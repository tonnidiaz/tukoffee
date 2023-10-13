import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/views/rf.dart';
import 'package:lebzcafe/widgets/common.dart';

class PageWithSearchAndList extends StatefulWidget {
  const PageWithSearchAndList({super.key});

  @override
  State<PageWithSearchAndList> createState() => _PageWithSearchAndListState();
}

class _PageWithSearchAndListState extends State<PageWithSearchAndList> {
  List? _data = ['d', 'd'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TUNEDBASS')),
      body: RefreshIndicator(
          onRefresh: () async {
            await sleep(1500);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: topMargin),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    /* SEARCHBAR */
                    height: 50,
                    width: double.infinity,
                    color: Colors.green,
                  ),
                ),
              ),
              _data == null
                  ? const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _data!.isEmpty
                      ? SliverFillRemaining(
                          child: Center(child: h3('Ohhhwee!')),
                        )
                      : DecoratedSliver(
                          decoration: BoxDecoration(color: cardBGLight),
                          sliver: SliverPadding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                            sliver: SliverList.builder(
                              itemBuilder: (c, i) => cont(),
                              itemCount: 20,
                            ),
                          ),
                        )
            ],
          )),
    );
  }
}
