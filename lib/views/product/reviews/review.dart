import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/functions.dart";

import "package:lebzcafe/widgets/review_item.dart";
import "package:lebzcafe/widgets/views/add_review.dart";
import "package:tu/tu.dart";

class ProductReviewPage extends StatefulWidget {
  final String id;
  final bool isAdmin;
  const ProductReviewPage({super.key, required this.id, this.isAdmin = false});

  @override
  State<ProductReviewPage> createState() => _ProductReviewPageState();
}

class _ProductReviewPageState extends State<ProductReviewPage> {
  Map<String, dynamic>? _review;
  _setReview(Map<String, dynamic>? val) {
    setState(() {
      _review = val;
    });
  }

  _getReview() async {
    try {
      _setReview(null);
      final res = await apiDio().get("/products/reviews?id=${widget.id}");
      _setReview(res.data["reviews"][0]);
    } catch (e) {
      if (mounted) {
        errorHandler(e: e, context: context, msg: "Failed to fetch reviews");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review"),
        actions: [
          Visibility(
            visible: false,
            child: IconButton(
                splashRadius: 20,
                onPressed: () {
                  //TODO: DEL REVIEW
                },
                icon: const Icon(
                  CupertinoIcons.delete,
                  size: 20,
                )),
          ),
          IconButton(
              splashRadius: 20,
              onPressed: () {
                Get.bottomSheet(AddReviewView(
                    product: _review!["product"],
                    rev: _review!,
                    isAdmin: widget.isAdmin,
                    onOk: () {
                      _getReview();
                    }));
              },
              icon: svgIcon(
                name: "br-pencil",
                color: colors.text2,
              ) // widget

              ),
        ],
      ),
      body: _review == null
          ? SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      child: CircularProgressIndicator(
                    color: colors.medium,
                  )),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _getReview();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: fullHeight(context),
                  child: Column(children: [
                    mY(6),
                    ReviewItem(
                      item: _review!,
                      hasStars: true,
                      hasTap: false,
                    ),
                    mY(6),
                    Container(
                      color: colors.surface,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          tuColumn(children: [
                            const Text(
                              "Date added",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            mY(6),
                            Text(
                              formatDate(_review!['createdAt'] ??
                                  _review!['date_created']),
                              style: const TextStyle(fontSize: 12.5),
                            )
                          ]),
                          tuColumn(children: [
                            const Text(
                              "Last modified",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            mY(6),
                            Text(
                              formatDate(_review!['updatedAt']),
                              style: const TextStyle(fontSize: 12.5),
                            )
                          ]),
                        ],
                      ),
                    ),
                    mY(6),
                    Container(
                      width: double.infinity,
                      color: colors.surface,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 14),
                      child: tuColumn(children: [
                        Text(
                          "${_review!["title"]}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        mY(6),
                        Text(
                          "${_review!["name"]}",
                          style: TextStyle(color: colors.text2, fontSize: 14),
                        ),
                        mY(10),
                        Text(_review!["body"])
                      ]),
                    )
                  ]),
                ),
              ),
            ),
    );
  }
}
