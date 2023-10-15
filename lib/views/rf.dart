import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/templates/page_with_search_and_list.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/common4.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  final _storeCtrl = MainApp.storeCtrl;
  int _selected = 0;

  _connectIO() async {
    socket?.on('event', (data) => clog(data));
    socket?.on('payment', (data) => {clog(data)});
    socket?.onDisconnect((_) => clog('disconnect'));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _connectIO();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: childAppbar(showCart: false),
      body: Container(
        child: Column(
          children: [
            TuButton(onPressed: _connectIO, text: "Connect IO"),
            TuButton(
                onPressed: () {
                  clog('EMMIT');
                  clog(socket?.connected);
                  socket?.emit("event", "HELLO");
                },
                text: "EMIT"),
          ],
        ),
      ),
    );
  }
}

Widget cont({Color? color, String text = "", Widget? child}) => Container(
      height: 100,
      width: 100,
      color: color ?? Colors.red,
      margin: defaultPadding,
      child: Center(child: child ?? Text(text)),
    );

class MButton extends StatelessWidget {
  const MButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor:
                TuColors.coffee1, //const Color.fromRGBO(26, 92, 255, 1),
            shadowColor: TuColors
                .coffee1Shadow, // const Color.fromRGBO(26, 92, 255, .5),
            elevation: 5,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13))),
        child: const Text("Button"),
      ),
    );
  }
}

class MBottomBar extends StatefulWidget {
  const MBottomBar({super.key});

  @override
  State<MBottomBar> createState() => _MBottomBarState();
}

class _MBottomBarState extends State<MBottomBar> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
