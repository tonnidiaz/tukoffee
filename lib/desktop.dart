import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/utils/constants.dart';

class DesktopApp extends StatefulWidget {
  static const mChannel = MethodChannel("$package/channel");
  const DesktopApp({Key? key}) : super(key: key);

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  @override
  Widget build(BuildContext context) {
    Map<String, Widget Function(BuildContext)> routes = {};
    for (var page in pages) {
      routes[page.name] = (context) => page.widget;
    }
    return MaterialApp(
      theme: ThemeData(fontFamily: "Poppins", brightness: Brightness.dark),
      routes: routes,
      builder: (context, wid) {
        return Column(
          children: [
            Container(
                height: screenSize(context).height,
                color: Colors.cyan,
                child: wid ?? Container()),
          ],
        );
      },
      initialRoute: "/",
    );
  }
}
