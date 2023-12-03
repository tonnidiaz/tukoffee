import "package:flutter/material.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/widgets/review_item.dart";
import "package:tu/tu.dart";

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
      _setReviews(res.data["reviews"].reversed.toList());
    } catch (e) {
      errorHandler(e: e, context: context, msg: "Failed to fetch reviews");
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
                const SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: topMargin),
                  sliver: SliverToBoxAdapter(
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
                            child: Center(child: h3("No reviews yet!")),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                            sliver: SliverList.builder(
                              itemBuilder: (c, i) =>
                                  ReviewItem(item: _reviews![i], isAdmin: true),
                              itemCount: _reviews!.length,
                            ),
                          ),
              ],
            )));
  }
}
