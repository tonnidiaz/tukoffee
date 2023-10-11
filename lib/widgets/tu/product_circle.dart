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
        width: 85,
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
            mY(10),
            dummy
                ? placeholderText()
                : Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
            dummy
                ? placeholderText(my: 2, width: 70)
                : SizedBox(
                    width: double.infinity,
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
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
