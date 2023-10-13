import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/views/product/reviews/review.dart';
import 'package:lebzcafe/widgets/common.dart';
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

  _getReviews() async {
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
        body: RefreshIndicator(
            onRefresh: () async {
              await _getReviews();
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: topMargin),
                  sliver: const SliverToBoxAdapter(
                    child: TuCard(
                        /* SEARCHBAR */

                        ),
                  ),
                ),
                _reviews == null
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _reviews!.isEmpty
                        ? SliverFillRemaining(
                            child: Center(child: h3('No reviews yet!')),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                            sliver: SliverList.builder(
                              itemBuilder: (c, i) => ReviewItem(
                                item: _reviews![i],
                              ),
                              itemCount: _reviews!.length,
                            ),
                          ),
              ],
            )));
  }
}
