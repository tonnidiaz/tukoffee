import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/tu/searchfield.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final Function(Map<String, dynamic> val)? onSubmit;
  const MapPage({super.key, this.onSubmit});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double? _zoom;
  _setZoom(double? val) {
    setState(() {
      _zoom = val;
    });
  }

  LatLng? _center = const LatLng(-26.1974939, 28.0534776);
  _setCenter(LatLng? val) {
    setState(() {
      _center = val;
    });
  }

  LatLng? _currCenter = const LatLng(-26.1974939, 28.0534776);
  _setCurrCenter(LatLng? val) {
    setState(() {
      _currCenter = val;
    });
  }

  bool _isGeocoding = false;
  _setIsGeocoding(bool val) {
    setState(() {
      _isGeocoding = val;
    });
  }

  List _features = [];
  _setFeatures(List val) {
    setState(() {
      _features = val;
    });
  }

  Map<String, dynamic> _address = {};
  _setAddress(Map<String, dynamic> val) {
    setState(() {
      _address = val;
    });
  }

  final _mapController = MapController();

  _searchAddress(String query) async {
    if (_isGeocoding) return;
    _setIsGeocoding(true);
    try {
      const baseURL = "https://api.mapbox.com/geocoding/v5/mapbox.places/";
      final res = await dio.get("$baseURL/$query.json", queryParameters: {
        "proximity": "28.0534776,-26.1974939",
        "access_token": mapboxPublicToken
      });
      _setFeatures(res.data['features']);
    } catch (e) {
      clog(e);
    }
    _setIsGeocoding(false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double bottomSheetH = 60;
    return Scaffold(
        bottomSheet: Container(
          padding: defaultPadding,
          height: bottomSheetH,
          color: Colors.transparent,
          child: LayoutBuilder(builder: (context, c) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TuButton(
                  width: (c.maxWidth / 2) - 2.5,
                  text: "Cancel",
                  bgColor: Color.fromRGBO(255, 224, 178, 0),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
                TuButton(
                  width: (c.maxWidth / 2) - 2.5,
                  text: "Use Location",
                  onPressed: () async {
                    /// _setCenter(_currCenter);
                    if (widget.onSubmit != null) {
                      widget.onSubmit!(_address);
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }),
        ),
        body: SafeArea(
          child: Container(
              height: screenSize(context).height - statusBarH(context),
              color: Colors.green,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                        center: const LatLng(51.509364, -0.128928),
                        onPositionChanged: (pos, hasChanged) async {
                          _setCurrCenter(pos.center);
                          _setZoom(pos.zoom);
                          if (pos.zoom != null && pos.zoom! >= 17.5) {
                            // Max zoom
                            _mapController.move(_currCenter!, 17.5);
                          }
                        }
                        //zoom: 13,
                        ),
                    nonRotatedChildren: [
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                            onTap: () {
                              // => launchUrl(Uri.parse('https://openstreetmap.org/copyright')
                            },
                          ),
                        ],
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            // curr position
                            point: _currCenter!,
                            builder: (context) => const Icon(
                              Icons.location_on,
                              color: Color.fromRGBO(42, 42, 42, 01),
                              size: 26,
                            ),
                          ),
                          Marker(
                            // curr location
                            point: _center!,
                            builder: (context) => const Icon(
                              Icons.location_pin,
                              color: Colors.orange,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: defaultPadding2,
                    //  color: Color.fromRGBO(255, 255, 255, 1),
                    height: 140,

                    //height: scree,
                    width: double.infinity,
                    child: Column(
                      children: [
                        TuSearchField(
                            label: "Search location:",
                            prefix: const Icon(
                              Icons.location_on,
                              size: 25,
                            ),
                            fill: const Color.fromARGB(255, 255, 254, 253),
                            suggestions: _features
                                .map((it) => TuSuggestion(
                                    text: "${it['place_name']}", value: it))
                                .toList(),
                            onChanged: (val) {
                              _searchAddress(val);
                            },
                            onSuggestionTap: (val) {
                              var center = val.value['center'];
                              var latlng = LatLng(center[1], center[0]);
                              _mapController.move(latlng, 18.5);
                              _setCenter(latlng);
                              _setAddress({
                                "name": val.value['place_name'],
                                "center": center,
                              });
                            })
                      ],
                    ),
                  )
                ],
              )),
        ));
  }
}
