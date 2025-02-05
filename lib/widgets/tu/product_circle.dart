import "package:flutter/material.dart";

import "package:lebzcafe/widgets/common3.dart";
import "package:tu/tu.dart";

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

  final double _avatarW = 80;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: _avatarW + 10,
        margin: const EdgeInsets.only(right: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: _avatarW,
                height: _avatarW,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(100)),
                child: CircleAvatar(
                  // borderRadius: BorderRadius.circular(100),
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.05),
                  backgroundImage: dummy || img == null
                      ? null
                      : Image.network(img!,
                          width: _avatarW,
                          height: _avatarW,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                                child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ));
                          },
                          errorBuilder: (context, error, stackTrace) => svgIcon(
                                name: "br-image-slash",
                                size: 26,
                                color: Colors.black54,
                              )).image,
                  child: dummy || img == null
                      ? const Center(
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              )))
                      : null,
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
