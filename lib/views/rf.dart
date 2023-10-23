import 'package:flutter/material.dart';
import 'package:lebzcafe/main.dart';

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(title: Text("RF")),
    );
  }
}
