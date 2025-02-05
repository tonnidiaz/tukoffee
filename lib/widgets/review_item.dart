import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:lebzcafe/views/product/reviews/review.dart";
import "package:lebzcafe/widgets/views/add_review.dart";
import "package:tu/tu.dart";

class ReviewItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool hasStars;
  final bool hasTap;
  final bool isAdmin;
  const ReviewItem(
      {super.key,
      required this.item,
      this.hasStars = false,
      this.isAdmin = false,
      this.hasTap = true});

  @override
  Widget build(BuildContext context) {
    Widget revBadge() {
      return Chip(
        //largeSize: 18

        backgroundColor: item["status"] == "pending"
            ? colors.medium
            : item["status"] == "approved"
                ? colors.success
                : colors.danger,
        label: Text(
          item["status"],
          // style: const TextStyle(fontSize: 10, color: Colors.white),
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
                  pushTo(ProductReviewPage(id: item["_id"], isAdmin: isAdmin));
                },
          tileColor: colors.surface,
          isThreeLine: !hasStars,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
              child: item["product"]["images"].isEmpty
                  ? svgIcon(
                      name: "br-image-slash",
                      size: 26,
                      color: Colors.black54,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        item["product"]["images"][0]["url"],
                        errorBuilder: ((context, error, stackTrace) {
                          clog(error);
                          return svgIcon(
                            name: "br-image-slash",
                            size: 26,
                            color: Colors.black54,
                          );
                        }),
                      )),
            ),
          ),
          title: Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Text(
              hasTap ? "${item["title"]}" : item["product"]["name"],
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          subtitle: hasStars
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    RatingBarIndicator(
                      rating: item["rating"].toDouble(),
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
                          color: colors.text2,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    revBadge()
                  ],
                ),
          trailing: hasStars
              ? null
              : SizedBox(
                  width: 24,
                  child: PopupMenuButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 24,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text("Edit"),
                        onTap: () {
                          Tu.bottomSheet(AddReviewView(
                              product: item["product"],
                              rev: item,
                              isAdmin: isAdmin,
                              onOk: () {
                                // _getReviews();
                                //TODO: RELOAD
                              }));
                        },
                      ),
                    ],
                  ),
                ),
        ));
  }
}
