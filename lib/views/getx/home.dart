import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";

import "package:tu/tu.dart";

class GetxHomePage extends StatelessWidget {
  const GetxHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: defaultPadding2,
        child: Column(
          children: [
            const Text("Hello"),
            mY(6),
            ElevatedButton(
              onPressed: () {
                clog("p");

                Get.bottomSheet(const MySheet(),
                    useRootNavigator: false,
                    backgroundColor: colors.surface,
                    enableDrag: true);
              },
              child: const Column(
                children: [
                  Text("Press me"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MySheet extends StatelessWidget {
  const MySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Center(
          child: TuButton(
        text: "Show toast",
        onPressed: () async {
          Get.bottomSheet(
              Container(
                height: 30,
                child: const Column(
                  children: [
                    LinearProgressIndicator(),
                  ],
                ),
              ),
              backgroundColor: colors.bg);
          // await sleep(1500);
          Get.back();
        },
      )),
    );
  }
}
