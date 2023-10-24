// ignore_for_file: use_build_context_synchronously

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/utils/styles.dart";
import "package:lebzcafe/views/account/reviews/index.dart";
import "package:lebzcafe/views/auth/login.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/common4.dart";

class ProductReviewsPage extends StatefulWidget {
  final String id;
  const ProductReviewsPage({super.key, required this.id});

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  Map<String, dynamic>? _product;
  List? _reviews;

  _getProduct() async {
    try {
      setState(() {
        _product = null;
      });
      final url = "/products?pid=${widget.id}";
      final res = await apiDio().get(url);
      final List<dynamic> data = res.data["data"];
      setState(() {
        _product = data[0];
      });
      await _getReviews(data[0]["_id"]);
    } catch (e) {
      errorHandler(e: e, context: context, msg: "Failed to fetch product");
    }
  }

  _getReviews(String id) async {
    setState(() {
      _reviews = null;
    });
    try {
      final res = await apiDio().get("/products/reviews?pid=$id");
      setState(() {
        //Filter only approved reviews
        _reviews =
            res.data["reviews"].where((it) => it["status"] == 1).toList();
      });
    } catch (e) {
      errorHandler(e: e, context: context, msg: "Failed to fetch reviews");
      setState(() {
        _reviews = [];
      });
      //errorHandler(e, "Failed to fetch product");
    }
  }

  @override
  void initState() {
    super.initState();
    _getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product == null
            ? "Product reviews"
            : "${_product!["name"]} reviews"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (MainApp.appCtrl.user["_id"] == null) {
            pushTo(const LoginPage(
              pop: true,
            ));
          } else {
            pushTo(const MyReviewsPage());
          }
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getProduct();
        },
        child: TuScrollview(
          child: SizedBox(
            height: screenSize(context).height - appBarH,
            child: Column(children: [
              Visibility(
                  visible: _reviews == null,
                  child: const LinearProgressIndicator()),
              _reviews == null || _product == null
                  ? none()
                  : Expanded(
                      child: Column(children: [
                        mY(2.5),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                                color: cardBGLight,
                                border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(10, 10, 10, .05)))),
                            //height: 110,
                            child: ListTile(
                              //Checkbox, cover, content, deleteBtn
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              leading: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 70,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _product!["images"].isEmpty
                                      ? const Icon(
                                          Icons.coffee_outlined,
                                          size: 45,
                                          color: Colors.black54,
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.network(
                                              _product!["images"][0]["url"])),
                                ),
                              ),

                              title: Container(
                                margin: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "${_product!["name"]}",
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )),
                        Expanded(
                          child: ListView.builder(
                              itemCount: _reviews!.length,
                              itemBuilder: (context, i) {
                                final review = _reviews![i];
                                return Container(
                                  color: cardBGLight,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 2.5, horizontal: 8),
                                  padding: defaultPadding,
                                  child: tuColumn(children: [
                                    RatingBarIndicator(
                                      itemSize: 20,
                                      rating: review["rating"].toDouble(),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    mY(2.5),
                                    Text(
                                      review["title"],
                                      style: Styles.h4(),
                                    ),
                                    Text(
                                      "${DateTime.parse(review["date_created"]).toLocal()}",
                                      style: TextStyle(
                                          fontSize: 14, color: TuColors.text2),
                                    ),
                                    mY(3),
                                    Text(
                                      review["name"],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    mY(10),
                                    Text(review["body"])
                                  ]),
                                );
                              }),
                        )
                      ]),
                    )
            ]),
          ),
        ),
      ),
    );
  }
}
