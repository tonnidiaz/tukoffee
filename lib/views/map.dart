import "dart:convert";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:geocoding/geocoding.dart";
import "package:geolocator/geolocator.dart";
import "package:get/get.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/dummies.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/tu/common.dart";
import "package:lebzcafe/widgets/tu/searchfield.dart";
import "package:latlong2/latlong.dart";

class MapPageArgs {
  final List center;
  const MapPageArgs({required this.center});
}

class MapPage extends StatefulWidget {
  final Function(Map<String, dynamic> val)? onSubmit;
  final bool canEdit;
  const MapPage({super.key, this.onSubmit, this.canEdit = true});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapPageArgs? _args;
  final _formCtrl = MainApp.formCtrl;

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
    if (_isGeocoding || query.length < 3) return;
    _setIsGeocoding(true);
    try {
      /* clog("setft");
      _setFeatures(dummyFeatures);
      return; */
      const baseURL = "https://api.mapbox.com/geocoding/v5/mapbox.places/";
      final res = await dio.get("$baseURL/$query.json", queryParameters: {
        "proximity": "28.0534776,-26.1974939",
        "access_token": mapboxPublicToken,
        "country": "ZA"
      });
      _setFeatures(res.data["features"]);
    } catch (e) {
      clog(e);
    }
    _setIsGeocoding(false);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //Get.back();
      if (context.mounted) {
        await showToast(
                "Location services are disabled. Please enable the services",
                isErr: true)
            .show(context);
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      //Get.back();
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          await showToast("Location permissions are denied", isErr: true)
              .show(context);
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.back();
      if (context.mounted) {
        await showToast(
                "Location permissions are permanently denied, we cannot request permissions.",
                isErr: true)
            .show(context);
      }
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    showProgressSheet();
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      Get.back();
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _getAddressFromLatLng(position);
      Get.back();
    } catch (e) {
      Get.back();
      if (context.mounted) {
        await showToast("Something went wrong", isErr: true).show(context);
      }
      clog(e);
      Get.back();
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    clog("GETTING...");
    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      clog("${place.administrativeArea}");
      List<String?> placeAsList = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode
      ].where((element) => element != null).toList();
      String placeAsTxt = placeAsList.join(", ");
      _setAddress({
        "place_name": placeAsTxt,
        "center": [position.latitude, position.longitude],
        "city": place.locality,
        "postcode": place.postalCode,
        "state": place.administrativeArea,
        "street": place.street,
        "suburb": place.subLocality
      });
      final cent = LatLng(position.latitude, position.longitude);
      _setCenter(cent);
      _mapController.move(cent, 17.5);
    }).catchError((e) {
      clog(e);
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _args = ModalRoute.of(context)?.settings.arguments as MapPageArgs?;
        if (_args != null) {
          var cent = LatLng(_args!.center.first, _args!.center.last);
          _setCenter(cent);
          _mapController.move(cent, 17.5);
        } else if (_formCtrl.form["address"] != null) {
          Map<String, dynamic> formLoc = _formCtrl.form["address"];
          _setCenter(LatLng(formLoc["center"].first, formLoc["center"].last));
          _mapController.move(_center!, 17.5);
          _setAddress(formLoc);
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
    return Scaffold(
        bottomNavigationBar: TuBottomBar(
          child: Container(
            child: iconText(
                _address["place_name"] ?? "No address", Icons.location_on,
                alignment: MainAxisAlignment.start, iconSize: 23),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: widget.canEdit,
              child: FloatingActionButton.small(
                  heroTag: "My location",
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.my_location),
                  onPressed: () {
                    _getCurrentPosition();
                  }),
            ),
            mY(10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    _mapController.move(_center ?? const LatLng(0, 0), 18.5);
                  },
                  child: Container(
                    padding: defaultPadding2,
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(100)),
                    child: const Text(
                      "Re-center",
                      style:
                          TextStyle(color: Color.fromRGBO(255, 255, 255, .9)),
                    ),
                  ),
                ),
                mX(widget.canEdit ? 10 : 0),
                Visibility(
                  visible: widget.canEdit,
                  child: FloatingActionButton.small(
                    heroTag: "Use location",
                    backgroundColor: Colors.black,
                    child: const Icon(Icons.check),
                    onPressed: () {
                      /// _setCenter(_currCenter);
                      _formCtrl.setFormField("address", _address);
                      gpop();
                      if (widget.onSubmit != null) {
                        widget.onSubmit!(_address);
                      }
                    },
                  ),
                ),
              ],
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
                            "OpenStreetMap contributors",
                            onTap: () {
                              // => launchUrl(Uri.parse("https://openstreetmap.org/copyright")
                            },
                          ),
                        ],
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: "com.example.app",
                      ),
                      MarkerLayer(
                        markers: [
                          /*      Marker(
                            // curr position
                            point: _currCenter ?? const LatLng(0, 0),
                            builder: (context) => Icon(
                              Icons.explore,
                              color: Colors.blue,
                              size: 35,
                            ),
                          ), */
                          Marker(
                            // curr location
                            point: _center ?? const LatLng(0, 0),
                            builder: (context) => Icon(
                              Icons.location_pin,
                              color: TuColors.primary,
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
                                    const BackButton(),
                                    Expanded(
                                      child: TuSearchField(
                                          enabled: widget.canEdit,
                                          hint: "Search location...",
                                          prefix: const Icon(
                                            Icons.location_on,
                                            size: 25,
                                          ),
                                          fill: const Color.fromARGB(
                                              255, 255, 254, 253),
                                          suggestions: _features
                                              .map((it) => TuSuggestion(
                                                  text: "${it["place_name"]}",
                                                  value: it))
                                              .toList(),
                                          onChanged: (val) {
                                            _searchAddress(val);
                                          },
                                          onSuggestionTap: (val) {
                                            try {
                                              var center = val.value["center"];
                                              var latlng =
                                                  LatLng(center[1], center[0]);
                                              _mapController.move(latlng, 18.5);
                                              _setCenter(latlng);

                                              final List context =
                                                  val.value["context"];

                                              var addr = {
                                                "street":
                                                    "${val.value["address"]} ${val.value["text"]}",
                                                "city": context
                                                    .firstWhereOrNull((el) =>
                                                        el["id"].startsWith(
                                                            "place"))["text"],
                                                "state": context
                                                    .firstWhereOrNull((el) =>
                                                        el["id"].startsWith(
                                                            "region"))?["text"],
                                                "postcode": context
                                                        .firstWhereOrNull((el) =>
                                                            el["id"].startsWith(
                                                                "postcode"))?[
                                                    "text"],
                                                "locality": context
                                                        .firstWhereOrNull((el) =>
                                                            el["id"].startsWith(
                                                                "locality"))?[
                                                    "text"],
                                              };
                                              _setAddress({
                                                "place_name":
                                                    val.value["place_name"],
                                                "center": center.reversed
                                                    .toList(), // REVERSING IT TO MAP MODE

                                                ...addr
                                              });
                                            } catch (e) {
                                              clog(e);
                                            }
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
