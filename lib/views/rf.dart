import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
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
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/common4.dart';
import 'package:lebzcafe/widgets/prompt_modal.dart';
import 'package:lebzcafe/widgets/tu/form.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  List<String> _comments = ["Hey", "Sho"];
  String _comment = "";

  _connectIO() async {
    socket?.off("rf");
    socket?.off("comment");

    socket?.on('rf', (data) => {clog("RF: $data")});
    socket?.on('comment', (data) {
      setState(() {
        _comments.add(data);
      });
    });
    socket?.onDisconnect((_) => clog('disconnect'));
  }

  @override
  void dispose() {
    super.dispose();
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
        bottomNavigationBar: Container(
          padding: defaultPadding,
          color: cardBGLight,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TuFormField(
              hint: 'Comment:',
              value: _comment,
              onChanged: (val) {
                setState(() {
                  _comment = val;
                });
              },
              suffix: IconButton(
                splashRadius: 20,
                padding: EdgeInsets.zero,
                onPressed: () {
                  socket!.emit('comment', _comment);
                },
                icon: Icon(Icons.send),
              ),
            )
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          child: Icon(Icons.home_outlined),
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: defaultPadding,
              sliver: SliverToBoxAdapter(child: h3("Comments:")),
            ),
            SliverToBoxAdapter(
              child: mY(6),
            ),
            SliverList.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) => TuCard(
                      my: 1,
                      child: Text(_comments[index]),
                    ))
          ],
        ));
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
