import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/product/reviews/review.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/views/add_review.dart';

class ReviewItem2 extends StatelessWidget {
  final Map<String, dynamic> prod;
  final Map<String, dynamic>? rev;
  final bool hasStars;
  final bool hasTap;
  const ReviewItem2(
      {super.key,
      required this.prod,
      required this.rev,
      this.hasStars = false,
      this.hasTap = true});

  @override
  Widget build(BuildContext context) {
    Widget revBadge() {
      return Chip(
        //largeSize: 18

        backgroundColor: rev!['status'] == 0
            ? TuColors.medium
            : rev!['status'] == 1
                ? TuColors.success
                : TuColors.danger,
        label: Text(
          reviewStatuses[rev!['status']],
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    }

    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color.fromRGBO(10, 10, 10, .05)))),
        //height: 110,
        child: ListTile(
          onTap: rev == null
              ? null
              : () {
                  pushTo(context, ProductReviewPage(id: rev!['_id']));
                },
          //Checkbox, cover, content, deleteBtn
          tileColor: cardBGLight,
          isThreeLine: !hasStars,
          contentPadding: const EdgeInsets.symmetric(horizontal: 7),
          leading: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: prod['images'].isEmpty
                  ? const Icon(
                      Icons.coffee_outlined,
                      size: 45,
                      color: Colors.black54,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(prod['images'][0]['url'])),
            ),
          ),

          title: Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Text(
              prod['name'],
              softWrap: false,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          subtitle: rev != null
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    RatingBarIndicator(
                      rating: rev!['rating'].toDouble(),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemSize: 14,
                    ),
                    revBadge()
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          TuFuncs.showBottomSheet(
                              context: context,
                              widget: AddReviewView(
                                product: prod,
                              ));
                        },
                        child: const Text('WRITE REVIEW'))
                  ],
                ),
        ));
  }
}
