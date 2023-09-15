import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/home.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/product_card.dart';

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
      final res = await apiDio().get('/search', queryParameters: {"q": _query});
      _setProducts(res.data['products']);
    } catch (e) {
      _setProducts([]);
      errorHandler(
          e: e, context: context, msg: "Failed to search for products");
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
        appBar: AppBar(
          //leading: TuBackButton(),
          leadingWidth: appBarH - 5,
          title: TuFormField(
            hint: "Search",
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
            PopupMenuButton(itemBuilder: (context) {
              return [];
            })
          ],
        ),
        body: Container(
            padding: defaultPadding2,
            child: Column(children: [
              Visibility(
                visible: _query.isNotEmpty,
                child: Row(
                  children: [
                    Text(
                      "Search results for:  ",
                      style: Styles.title(isLight: true),
                    ),
                    Text(
                      _query,
                      style: Styles.title(color: Colors.orange),
                    )
                  ],
                ),
              ),
              mY(10),
              _products == null
                  ? Expanded(
                      child: Center(
                          child: Text(
                      "Searching...",
                      style: Styles.h3(isLight: true),
                    )))
                  : _products!.isNotEmpty
                      ? LayoutBuilder(builder: (context, c) {
                          return Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            //runAlignment: WrapAlignment.spaceBetween,
                            //Products
                            children: _products!
                                .map((it) => ProductCard(
                                      product: it,
                                      width: (c.maxWidth / 2) - 5,
                                    ))
                                .toList(),
                          );
                        })
                      : Expanded(
                          child: Center(
                              child: Text(
                          "No results",
                          style: Styles.h3(isLight: true),
                        )))
            ])));
  }
}
