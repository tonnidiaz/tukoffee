import 'package:flutter/material.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common3.dart';
import 'package:google_fonts/google_fonts.dart';

class TuProductCircle extends StatelessWidget {
  final bool dummy;
  final String subtitle;
  final String title;
  final String? img;
  final Function()? onTap;
  const TuProductCircle(
      {super.key,
      this.dummy = false,
      this.subtitle = "",
      this.title = "",
      this.img,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(100)),
                child: CircleAvatar(
                  // borderRadius: BorderRadius.circular(100),
                  backgroundColor: Colors.black12,
                  backgroundImage: dummy || img == null
                      ? null
                      : Image.network(
                          img!,
                          width: 70,
                          height: 70,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.coffee_maker,
                            color: Colors.black54,
                          ),
                        ).image,
                )),
            mY(2.5),
            dummy
                ? placeholderText()
                : Text(
                    subtitle,
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
            dummy
                ? placeholderText(my: 2, width: 70)
                : SizedBox(
                    width: 70,
                    child: Text(
                      title,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ))
          ],
        ),
      ),
    );
  }
}
