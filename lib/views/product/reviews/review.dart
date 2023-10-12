import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/review_item.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';

class ProductReviewPage extends StatefulWidget {
  final String id;
  const ProductReviewPage({super.key, required this.id});

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

  void _getReview() async {
    try {
      _setReview(null);
      final res = await apiDio().get("/products/reviews?id=${widget.id}");
      _setReview(res.data['reviews'][0]);
    } catch (e) {
      errorHandler(e: e, context: context, msg: "Failed to fetch reviews");
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
        title: const Text('Review'),
        actions: [
          IconButton(
              splashRadius: 20,
              onPressed: () {
                //TODO: DEL REVIEW
              },
              icon: const Icon(
                CupertinoIcons.delete,
                size: 20,
              )),
          IconButton(
              splashRadius: 20,
              onPressed: () {
                //TODO: SHOW EDIT SHEET
              },
              icon: Iconify(
                Bx.edit_alt,
                color: TuColors.text2,
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
                    color: TuColors.medium,
                  )),
                ],
              ),
            )
          : Container(
              child: Column(children: [
                mY(6),
                ReviewItem(
                  item: _review!,
                  hasStars: true,
                  hasTap: false,
                ),
                mY(6),
                Container(
                  color: cardBGLight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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
                          "${DateTime.parse(_review!['date_created']).toLocal()}"
                              .split(' ')
                              .first,
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
                          "${DateTime.parse(_review!['last_modified']).toLocal()}"
                              .split(' ')
                              .first,
                          style: const TextStyle(fontSize: 12.5),
                        )
                      ]),
                    ],
                  ),
                ),
                mY(6),
                Container(
                  width: double.infinity,
                  color: cardBGLight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  child: tuColumn(children: [
                    Text(
                      "${_review!['title']}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    mY(6),
                    Text(
                      "${_review!['name']}",
                      style: TextStyle(color: TuColors.text2, fontSize: 14),
                    ),
                    mY(10),
                    Text(_review!['body'])
                  ]),
                )
              ]),
            ),
    );
  }
}
