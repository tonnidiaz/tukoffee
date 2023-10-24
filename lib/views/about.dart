import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "../main.dart";
import "/utils/constants.dart";

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        child: Container(
      width: double.infinity,
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
