import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/product_card.dart";
import "package:tu/tu.dart";

import "package:via_logger/logger.dart";

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = "";
  _setQuery(String val) {
    setState(() {
      _query = val;
    });
  }

  String? _searchBy;
  _setSearchBy(String? val) {
    setState(() {
      _searchBy = val;
    });
  }

  List? _products;
  _setProducts(List? val) {
    setState(() {
      _products = val;
    });
  }

  _init() async {}

  _searchProducts(String q) async {
    try {
      _setProducts(null);
      final res = await apiDio()
          .get("/search", queryParameters: {"q": _query, "by": _searchBy});
      _setProducts(res.data["products"]);
    } catch (e) {
      _setProducts([]);
      Logger.info(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: tuAppbar(
          elevation: .5,
          title: TuFormField(
            hint: "Search",
            hasBorder: false,
            fill: Colors.transparent,
            autofocus: true,
            prefixIcon: TuIcon(Icons.search),
            radius: 0,
            value: _query,
            onSubmitted: (val) {
              _setQuery(val);
              _searchProducts(val);
            },
            onChanged: (val) {},
          ),
          actions: [
            TuPopupBtn(items: [
              PopupMenuItem(
                child: const Text("Reset"),
                onTap: () {
                  _setProducts(null);
                  _setQuery("");
                  _setSearchBy(null);
                },
              ),
              /*       PopupMenuItem(
                      child: const Text("Show sheet"),
                      onTap: () {
                        TuFuncs.showBottomSheet(
                            context: context, widget: const SearchPage());
                      },
                    ), */
            ])
          ],
        ),
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: mY(topMargin)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: TuSelect(
                label: "Search by:",
                value: _searchBy,
                onChanged: (val) {
                  _setSearchBy(val);
                },
                items: [
                  SelectItem("Product ID", "pid"),
                  SelectItem("Name", "name"),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Visibility(
              visible: _query.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      "Search results for:  ",
                      // style: styles.title(isLight: true),
                    ),
                    Text(
                      _query,
                      style: styles.title(color: colors.primary),
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: mY(10)),
          _products == null
              ? _query.isEmpty
                  ? SliverToBoxAdapter(child: none())
                  : SliverFillRemaining(
                      child: Center(
                          child: Text(
                      "Searching...",
                      style: styles.h3(isLight: true),
                    )))
              : _products!.isNotEmpty
                  ? SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 10),
                      sliver: SliverGrid.builder(
                        itemCount: _products!.length,
                        itemBuilder: (context, i) =>
                            ProductCard(product: _products![i]),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 9),
                      ),
                    )
                  : SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                          child: Text(
                        "No results",
                        style: styles.h3(isLight: true),
                      )))
        ]));
  }
}
