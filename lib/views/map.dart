import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/tu/searchfield.dart';
import 'package:latlong2/latlong.dart';

class MapPageArgs {
  final List center;
  const MapPageArgs({required this.center});
}

class MapPage extends StatefulWidget {
  final Function(Map<String, dynamic> val)? onSubmit;
  const MapPage({super.key, this.onSubmit});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapPageArgs? _args;
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _args = ModalRoute.of(context)?.settings.arguments as MapPageArgs?;
        clog(_args?.center);
        if (_args != null) {
          var cent = LatLng(_args!.center.first, _args!.center.last);
          //_setCurrCenter(LatLng(_args!.center.first, _args!.center.last));
          _setCenter(cent);
          _mapController.move(cent, 17.5);
        }
      });
    });
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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
                heroTag: "My location",
                backgroundColor: Colors.black,
                child: const Icon(Icons.my_location),
                onPressed: () {
                  //TODO: go to user location
                }),
            mY(10),
            FloatingActionButton.small(
              heroTag: "Use location",
              backgroundColor: Colors.black,
              child: const Icon(Icons.check),
              onPressed: () async {
                /// _setCenter(_currCenter);
                if (widget.onSubmit != null) {
                  widget.onSubmit!(_address);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
              height: screenSize(context).height - statusBarH(context: context),
              color: Colors.green,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                        center: const LatLng(51.509364, -0.128928),
                        onPositionChanged: (pos, hasChanged) async {
                          _setCurrCenter(pos.center);
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
                            point: _currCenter ?? const LatLng(0, 0),
                            builder: (context) => const Icon(
                              Icons.location_searching_rounded,
                              color: Color.fromRGBO(10, 10, 10, 01),
                              size: 20,
                            ),
                          ),
                          Marker(
                            // curr location
                            point: _center ?? const LatLng(0, 0),
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
                    margin: defaultPadding,
                    //  color: Color.fromRGBO(255, 255, 255, 1),
                    height: 140,

                    //height: scree,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Container(
                          //height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 5),

                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 254, 253),
                              borderRadius: BorderRadius.circular(7)),
                          width: double.infinity,
                          child: false
                              ? none()
                              : Row(
                                  children: [
                                    BackButton(),
                                    Expanded(
                                      child: TuSearchField(
                                          hint: "Search location...",
                                          prefix: const Icon(
                                            Icons.location_on,
                                            size: 25,
                                          ),
                                          fill: const Color.fromARGB(
                                              255, 255, 254, 253),
                                          suggestions: _features
                                              .map((it) => TuSuggestion(
                                                  text: "${it['place_name']}",
                                                  value: it))
                                              .toList(),
                                          onChanged: (val) {
                                            _searchAddress(val);
                                          },
                                          onSuggestionTap: (val) {
                                            var center = val.value['center'];
                                            var latlng =
                                                LatLng(center[1], center[0]);
                                            _mapController.move(latlng, 18.5);
                                            _setCenter(latlng);
                                            _setAddress({
                                              "name": val.value['place_name'],
                                              "center": center,
                                            });
                                          }),
                                    )
                                  ],
                                ),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }
}
