import "dart:core";
import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";

class TuSelect extends StatelessWidget {
  final dynamic value;
  final void Function(dynamic)? onChanged;
  final String? label;
  final double? width;
  final double? radius;
  final double elevation;
  final double? height;
  final double? labelFontSize;
  final bool disabled;
  final Color? bgColor;
  final Color? borderColor;
  final List<SelectItem> items;
  const TuSelect(
      {Key? key,
      this.items = const [],
      this.value,
      this.label = "Dropdown",
      this.width,
      this.height = 40,
      this.radius,
      this.bgColor,
      this.borderColor,
      this.labelFontSize,
      this.elevation = .5,
      this.onChanged,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      //height: height,
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: Material(
        color: /* mFieldBG2, */ bgColor ?? appBGLight,
        elevation: elevation,
        shadowColor: Colors.black87,
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButtonFormField(
            value: value, // ?? formats[0],
            dropdownColor: bgColor ?? appBGLight,
            focusColor: bgColor ?? appBGLight,
            isExpanded: true,
            isDense: true,
            icon: const Icon(
              Icons.expand_more_outlined,
              color: Colors.black54,
            ),
            decoration: InputDecoration(
              label: label == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(left: 22.0),
                      child: Text(label!),
                    ),
            ),
            items: items.map((e) {
              return DropdownMenuItem(
                value: e.value,
                child: Text(
                  e.label,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: tuTextTheme(context).labelLarge,
                ),
              );
            }).toList(),
            onChanged: disabled ? null : onChanged,
          ),
        ),
      ),
    );
  }
}
