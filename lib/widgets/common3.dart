import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/views/map.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import '../utils/styles.dart';
import '../views/order/index.dart';
import 'common.dart';
import 'common2.dart';

Widget searchResSheet(
    {List<dynamic> features = const [],
    required Function(Map<String, dynamic>) onAfterSelectLocation}) {
  return Container(
    padding: defaultPadding2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Search results", style: Styles.h3()),
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
                    "suburb": props['suburb'],
                    "postcode": props["postcode"],
                    "city": props['city'],
                    "state": props["state"],
                    "country": props["country"]
                  };

                  var title = [
                    props["street"],
                    props['suburb'],
                    props['postcode']
                  ].where((element) => element != null).join(", ");
                  var subtitle = [props["city"], props['state']]
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

Widget storeCard(BuildContext context, Map<String, dynamic> store) {
  return TuCard(
      borderSize: 0,
      radius: 0,
      onTap: () {
        //TODO://Open map with location coordinates
        final center = store['location']['center'];
        pushNamed(context, '/map',
            args: MapPageArgs(center: [center[1], center[0]]));
      },
      child: TuListTile(
          leading: const Icon(
            Icons.storefront,
            size: 30,
          ),
          title: Text(
            "Tukoffee ${store['location']['name']}",
            softWrap: false,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: tuTableRow(
            const Text(
              "CLOSED",
              softWrap: false,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Text(
              "Opens at ${store['open_time']}",
              softWrap: false,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          )));
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

Widget tuColumn({List<Widget> children = const [], bool min = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: min ? MainAxisSize.min : MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    children: children,
  );
}

Widget tuRow({List<Widget> children = const [], bool min = false}) {
  return Row(
    mainAxisSize: min ? MainAxisSize.min : MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: children,
  );
}

class InfoItem extends StatelessWidget {
  final Function()? onTap;
  final Widget? child;
  const InfoItem({super.key, this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: .5),
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(10, 10, 10, 0.05), width: 1))),
          child: child),
    );
  }
}
