import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/product/reviews/review.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/review_item.dart';

class ProductsReviews extends StatefulWidget {
  const ProductsReviews({super.key});

  @override
  State<ProductsReviews> createState() => _ProductsReviewsState();
}

class _ProductsReviewsState extends State<ProductsReviews> {
  List? _reviews;
  _setReviews(List? val) {
    setState(() {
      _reviews = val;
    });
  }

  void _getReviews() async {
    _setReviews(null);
    try {
      final res = await apiDio().get("/products/reviews");
      _setReviews(res.data['reviews']);
    } catch (e) {
      errorHandler(e: e, context: context, msg: 'Failed to fetch reviews');
      _setReviews([]);
    }
  }

  @override
  void initState() {
    super.initState();
    _getReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product reviews")),
      body: Container(
          child: _reviews == null
              ? Center(
                  child: Text(
                    "No reviews yet",
                    style: Styles.h3(),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: defaultPadding,
                      color: cardBGLight,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    Column(
                      children: _reviews!
                          .map((e) => ReviewItem(
                                item: e,
                              ))
                          .toList(),
                    ),
                  ],
                )),
    );
  }
}
