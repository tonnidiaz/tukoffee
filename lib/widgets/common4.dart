import "package:flutter/material.dart";

Widget bulletItem(String text, {TextStyle? style}) => Row(children: [
      const Text(
        "\u2022",
        style: TextStyle(fontSize: 30),
      ), //bullet text
      const SizedBox(
        width: 10,
      ), //space between bullet and text
      Expanded(
        child: Text(
          text,
          style: style,
        ), //text
      )
    ]);
