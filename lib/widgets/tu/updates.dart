import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';

class UpdatesView extends StatefulWidget {
  const UpdatesView({super.key});

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  int? _updates;
  _setUpdates(int? val) {
    setState(() {
      _updates = val;
    });
  }

  _checkUpdates() async {
    _setUpdates(null);
    await Future.delayed(Duration(seconds: 3));
    _setUpdates(4);
  }

  _init() async {
    _checkUpdates();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(showCart: false),
      onRefresh: () async {
        await _checkUpdates();
      },
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(42, 42, 42, 1),
        onPressed: () {
          _checkUpdates();
        },
        child: const Icon(Icons.refresh),
      ),
      child: Container(
        padding: defaultPadding2,
        width: double.infinity,
        height: screenSize(context).height - appBarH - statusBarH(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _updates != null
                ? Column(
                    children: [
                      TuCard(
                          padding: 14,
                          child: Column(
                            children: [
                              tuTableRow(Text("Your version: "), Text("1.0.0")),
                              mY(5),
                              tuTableRow(
                                  Text("Latest version: "), Text("3.0.0")),
                              mY(5),
                              TuCard(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Release notes:",
                                    style: Styles.title(),
                                  ),
                                  mY(10),
                                  ...List.generate(
                                      4,
                                      (index) => iconText("Fixed issue $index",
                                          Icons.radio_button_unchecked,
                                          iconSize: 10,
                                          my: 2.5,
                                          alignment: MainAxisAlignment.start))
                                ],
                              )),
                              mY(5),
                              TextButton(
                                child: Text(
                                  "Update now",
                                  style: Styles.title(),
                                ),
                                onPressed: () {},
                              ),
                            ],
                          )),
                    ],
                  )
                : Text(
                    "Checking for updates...",
                    style: Styles.h3(),
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}
