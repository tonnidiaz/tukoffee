import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/product_card.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

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
          .get('/search', queryParameters: {"q": _query, 'by': _searchBy});
      _setProducts(res.data['products']);
    } catch (e) {
      _setProducts([]);
      clog(e);
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
          leading: BackButton(),
          leadingWidth: appBarH - 8,
          backgroundColor: cardBGLight,
          elevation: .5,
          title: TuFormField(
            hint: "Search",
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
            PopupMenuButton(
                splashRadius: 20,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: const Text("Reset"),
                      onTap: () {
                        _setProducts(null);
                        _setQuery("");
                        _setSearchBy(null);
                      },
                    )
                  ];
                })
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: defaultPadding2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TuDropdownButton(
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
                    Visibility(
                      visible: _query.isNotEmpty,
                      child: Row(
                        children: [
                          Text(
                            "Search results for:  ",
                            // style: Styles.title(isLight: true),
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
                        ? _query.isEmpty
                            ? none()
                            : Expanded(
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
                  ])),
        ));
  }
}
