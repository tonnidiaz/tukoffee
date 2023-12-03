import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";

import "package:tu/tu.dart";

class PageWithSearchAndList extends StatefulWidget {
  const PageWithSearchAndList({super.key});

  @override
  State<PageWithSearchAndList> createState() => _PageWithSearchAndListState();
}

class _PageWithSearchAndListState extends State<PageWithSearchAndList> {
  List? _data = ["d", "d"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TUNEDBASS")),
      body: RefreshIndicator(
          onRefresh: () async {
            await sleep(1500);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: topMargin),
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
                  : _data!.isEmpty || true
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(children: [
                            cont(),
                            cont(),
                            cont(),
                          ]), // Center(child: h3("Ohhhwee!")),
                        )
                      : DecoratedSliver(
                          decoration: BoxDecoration(color: colors.surface),
                          sliver: SliverPadding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                            sliver: SliverList.builder(
                              itemBuilder: (c, i) => cont(),
                              itemCount: 2,
                            ),
                          ),
                        )
            ],
          )),
    );
  }
}
