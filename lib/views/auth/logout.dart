import "package:flutter/material.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:tu/tu.dart";

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  _logout() async {
    await logout();
    Get.offAllNamed("/");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _logout();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Loging out...",
                style: styles.h3(),
              )
            ]),
      ),
    );
  }
}
