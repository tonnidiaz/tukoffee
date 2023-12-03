import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";
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
        Expanded(
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
