import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/product/reviews/review.dart';
import 'package:frust/widgets/common3.dart';

class ReviewItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool hasStars;
  final bool hasTap;
  const ReviewItem(
      {super.key,
      required this.item,
      this.hasStars = false,
      this.hasTap = true});

  @override
  Widget build(BuildContext context) {
    Widget revBadge() {
      return Chip(
        //largeSize: 18

        backgroundColor: item['status'] == 0
            ? TuColors.medium
            : item['status'] == 1
                ? TuColors.success
                : TuColors.danger,
        label: Text(
          reviewStatuses[item['status']],
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
          onTap: !hasTap
              ? null
              : () {
                  pushTo(context, ProductReviewPage(id: item['_id']));
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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item['product']['images'].isEmpty
                  ? svgIcon(
                      name: "br-image-slash",
                      size: 26,
                      color: Colors.black54,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child:
                          Image.network(item['product']['images'][0]['url'])),
            ),
          ),

          title: Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Text(
              hasTap ? "${item['title']}" : item['product']['name'],
              softWrap: false,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          subtitle: hasStars
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    RatingBarIndicator(
                      rating: item['rating'].toDouble(),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemSize: 14,
                    ),
                    revBadge()
                  ],
                )
              : tuColumn(
                  children: [
                    Text(
                      "R${item["name"]}",
                      style: TextStyle(
                          color: TuColors.text2,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    revBadge()
                  ],
                ),
          trailing: hasStars
              ? null
              : PopupMenuButton(
                  splashRadius: 24,
                  itemBuilder: (context) => [
                    const PopupMenuItem(child: Text('Edit')),
                    const PopupMenuItem(child: Text('Delete')),
                  ],
                ),
        ));
  }
}
