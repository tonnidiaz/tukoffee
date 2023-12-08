import "dart:isolate";

import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";

import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/functions2.dart";
import "package:lebzcafe/views/map.dart";
import "package:lebzcafe/widgets/prompt_modal.dart";
import "package:tu/tu.dart";

import "../utils/constants.dart";
import "../views/order/index.dart";
import "common2.dart";

class SearchResSheet extends StatelessWidget {
  final List<dynamic> features;
  final Function(Map<String, dynamic>) onAfterSelectLocation;
  const SearchResSheet(
      {super.key,
      required this.onAfterSelectLocation,
      this.features = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: defaultPadding2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Search results", style: styles.h3()),
          mY(5),
          const Text("Select your delivery location"),
          mY(5),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features.map((it) {
                    final props = it["properties"];
                    var addr = {
                      "street": props["street"],
                      "suburb": props["suburb"],
                      "postcode": props["postcode"],
                      "city": props["city"],
                      "state": props["state"],
                      "country": props["country"]
                    };

                    var title = [
                      props["street"],
                      props["suburb"],
                      props["postcode"]
                    ].where((element) => element != null).join(", ");
                    var subtitle = [props["city"], props["state"]]
                        .where((element) => element != null)
                        .join(", ");
                    return locationCard(
                        title: title,
                        subtitle: subtitle,
                        onTap: () {
                          // temp save address
                          //setdeliveryAddress(addr);
                          onAfterSelectLocation(addr);
                        });
                  }).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget locationCard(
    {Function()? onTap, String title = "", String subtitle = ""}) {
  return InkWell(
    onTap: onTap,
    child: Card(
      elevation: .5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          const Icon(
            Icons.location_on,
            color: Colors.black54,
          ),
          mX(5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ]),
      ),
    ),
  );
}

class TuInkwell extends StatefulWidget {
  final Function()? onTap;
  final Widget? child;
  const TuInkwell({super.key, this.onTap, this.child});

  @override
  State<TuInkwell> createState() => _TuInkwellState();
}

class _TuInkwellState extends State<TuInkwell> {
  bool _loading = false;
  _setLoading(bool val) {
    setState(() {
      _loading = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _loading
          ? null
          : () async {
              _setLoading(true);
              if (widget.onTap != null) {
                await widget.onTap!();
              }
              _setLoading(false);
            },
      child: widget.child,
    );
  }
}

class StoreCard extends StatelessWidget {
  final BuildContext context;
  final Map<String, dynamic> store;
  const StoreCard(this.context, {super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final formCtrl = MainApp.formCtrl;
    final appCtrl = MainApp.appCtrl;
    final storeCtrl = MainApp.storeCtrl;

    bool isOpen() {
      final now = DateTime.now().toLocal(),
          timeSuffix = now.weekday == 6 || now.weekday == 7 ? "_weekend" : "";

      final openTime = toRealTime(store["open_time$timeSuffix"])
              .split(":")
              .map((it) => int.parse(it))
              .toList(),
          closeTime = toRealTime(store["close_time$timeSuffix"])
              .split(":")
              .map((it) => int.parse(it))
              .toList();
      final int h = now.hour, m = now.minute;

      var mIsOpen = false;

      if (h > openTime[0] && h <= closeTime[0]) {
        mIsOpen = true;
      } else if (h == openTime[0] && m >= openTime[1] && h <= closeTime[0]) {
        mIsOpen =
            h < closeTime[0] ? true : (h == closeTime[0] && m <= closeTime[1]);
      } else {
        mIsOpen = false;
      }
      return mIsOpen;
    }

    return Obx(
      () => Slidable(
        endActionPane: appCtrl.user.isEmpty ||
                appCtrl.user["permissions"] == UserPermissions.read.index
            ? null
            : ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    // An action can be bigger than the others.
                    flex: 1,
                    onPressed: (c) async {
                      TuFuncs.dialog(
                          context,
                          PromptDialog(
                            title: "Delete store location",
                            msg: "Continue to delete store?",
                            onOk: () async {
                              try {
                                showProgressSheet();
                                final res = await apiDio().post("/stores/del",
                                    queryParameters: {"id": store["_id"]});
                                storeCtrl.setStores(res.data["stores"]);
                                gpop();

                                /// Navigator.pop(context);
                                if (c.mounted) {
                                  showToast("Store deleted successfully")
                                      .show(c)
                                      .then((value) {
                                    gpop();
                                  });
                                }
                              } catch (e) {
                                gpop();
                                if (c.mounted) {
                                  errorHandler(
                                    e: e,
                                  );
                                }
                              }
                            },
                          ));
                    },
                    backgroundColor: Colors.black12,
                    foregroundColor: colors.onBackground,
                    icon: Icons.delete_outline,
                  ),
                ],
              ),
        child: TuCard(
            borderSize: 0,
            radius: 0,
            onTap: () {
              //formCtrl.clear();
              formCtrl.setForm({"address": store['address']});
              pushTo(const MapPage(
                canEdit: false,
              ));
            },
            child: TuListTile(
                leading: Icon(
                  Icons.storefront,
                  color: colors.text2,
                  size: 30,
                ),
                title: Text(
                  "${store["address"]?["place_name"]}",
                  softWrap: true,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14),
                ),
                subtitle: tuColumn(
                  children: [
                    isOpen()
                        ? tuTableRow(
                            const Text(
                              "OPEN",
                              softWrap: false,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            Text(
                              "Closes at ${store["close_time"]}",
                              softWrap: false,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          )
                        : tuTableRow(
                            const Text(
                              "CLOSED",
                              softWrap: false,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            Text(
                              "Opens at ${store["open_time"]}",
                              softWrap: false,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ),
                    mY(5),
                    devider()
                  ],
                ))),
      ),
    );
  }
}

Icon TuIcon(IconData icon) {
  return Icon(icon, size: 25);
}

Widget placeholderText(
    {double width = 50, double height = 14, Color? color, double my = 0}) {
  return Container(
    height: height,
    width: width,
    margin: EdgeInsets.symmetric(vertical: my),
    decoration: BoxDecoration(
        color: color ?? Colors.black12, borderRadius: BorderRadius.circular(5)),
  );
}
