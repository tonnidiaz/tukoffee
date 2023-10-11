import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/utils/constants.dart';

import '../main.dart';
import '../widgets/common2.dart';

class RFPage2 extends StatefulWidget {
  const RFPage2({super.key});

  @override
  State<RFPage2> createState() => _RFPage2State();
}

class _RFPage2State extends State<RFPage2> {
  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: childAppbar(showCart: false),
      child: SizedBox(
          height: screenSize(context).height -
              appBarH -
              statusBarH(context) -
              keyboardPadding(context),
          child: const Column(
            children: [
              /* Expanded(
                child: MapboxMap(
                  accessToken: mapboxPublicToken,
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(27.82563, -26.6948865), zoom: 7),
                  onMapCreated: (e) {
                    clog("OnMapCreated: $e");
                  },
                ),
              ) */
            ],
          ) /* OpenStreetMapSearchAndPick(
              center: LatLong(27.82563, -26.6948865),
              buttonColor: Colors.orange,
              buttonText: 'Set Current Location',
              onPicked: (pickedData) {
                clog(pickedData.latLong.latitude);
                clog(pickedData.latLong.longitude);
                clog(pickedData.address);
              }) */
          ),
    );
  }
}
