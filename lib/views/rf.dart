import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/dummies.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/functions2.dart';
import 'package:lebzcafe/views/map.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/tu/common.dart';
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
    //socket?.off("order");

    socket?.on('rf', (data) => {clog("RF: $data")});
    socket?.on('comment', (data) {
      createNotif(title: "Anonymous says", msg: data);
      if (context.mounted) {
        setState(() {
          _comments.add(data);
        });
      }
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
        bottomNavigationBar: TuBottomBar(
          child: Container(
            margin: EdgeInsets.only(bottom: keyboardPadding(context)),
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              Get.bottomSheet(Container(
                  height: screenSize(context).height, child: MapPage()));
              return;
              showProgressSheet();
              String query = '50 davies street';
              final mapboxPlaceRes = await dio.get(
                  "https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json",
                  queryParameters: {
                    "access_token": mapboxPublicToken,
                    "proximity": "28.0534776,-26.1974939",
                    "types": "address"
                  });
              gpop();
              clog(jsonEncode(mapboxPlaceRes.data['features']));
              return;
              final davies = dummyFeatures[0]['center'].reversed.toList();
              final daviesBox = dummyFeatures[0]['center'];
              final placemarks =
                  await placemarkFromCoordinates(davies[0], davies[1]);
              var addr1 = placemarks[1];

              final mapboxres = await dio.get(
                  "https://api.mapbox.com/geocoding/v5/mapbox.places/${daviesBox[0]},${daviesBox[1]}.json",
                  queryParameters: {
                    "access_token": mapboxPublicToken,
                    "proximity": "28.0534776,-26.1974939",
                  });

              clog(addr1.postalCode);
              clog(mapboxres.data);
              gpop();
            } catch (e) {
              gpop();
              errorHandler(e: e, context: context);
            }
            // Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
