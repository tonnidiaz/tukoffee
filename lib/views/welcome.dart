import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:tu/tu.dart";
import "../main.dart";

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        child: Container(
      width: isMobile
          ? screenSize(context).width
          : screenSize(context).width - appBarH,
      padding: const EdgeInsets.all(8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("About us"),
        ],
      ),
    ));
  }
}
