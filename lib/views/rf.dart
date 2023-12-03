import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/extensions.dart";
import "package:tu/tu.dart";

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RF")),
      body: Column(children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Hello on card"),
          ),
        ),
        mY(10),
        TuCard(
          child: Column(
            children: [
              Text("My name is SquashE Tonics"),
              Text("And I'm here to rule Earth"),
              mY(10),
              TuCard(
                height: 50,
                color: colors.coffee,
              ),
              TuCard(
                height: 50,
                color: const Color.fromRGBO(141, 96, 78, 1),
              ),
            ],
          ),
        ),
        const Expanded(
          child: TuFormField(
            label: "Message:",
            minLines: null,
            maxLines: null,
            expands: true,
          ),
        )
      ]),
    );
  }
}
