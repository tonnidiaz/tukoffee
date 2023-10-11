import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/tab_item.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/constants2.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';

class RFPage extends StatefulWidget {
  const RFPage({super.key});

  @override
  State<RFPage> createState() => _RFPageState();
}

class _RFPageState extends State<RFPage> {
  final _storeCtrl = MainApp.storeCtrl;
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
        borderRadius: mFieldRadius,
        borderSide: BorderSide(color: TuColors.fieldBG, width: .2));
    return Scaffold(
        appBar: childAppbar(showCart: false),
        body: Container(
            padding: defaultPadding,
            child: tuColumn(
              min: true,
              children: [
                const Text("Small text"),
                mY(5),
                Text(
                  "Medium text",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                mY(5),
                const Text(
                  "Large text",
                  style: TextStyle(fontSize: 23),
                ),
                mY(5),
                OutlinedButton(onPressed: () {}, child: const Text("Submit")),
                mY(5),
                Container(
                  padding: defaultPadding,
                  color: Colors.white,
                  child: tuColumn(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 10,
                          ),
                          hintText: "Placeholder",
                          labelText: "Label:",
                          hintStyle: const TextStyle(color: Colors.black38),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.877),
                            fontSize: 20,
                          ),
                          fillColor: const Color.fromRGBO(244, 247, 248, 1),
                          isDense: true,
                          filled: true,
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                        ),
                      ),
                      mY(5),
                      TuDropdownButton(
                        onChanged: (val) {},
                        label: "Tu label:",
                        items: List.generate(
                                5, (index) => SelectItem("Item $index", index))
                            .toList(),
                      ),
                      const MButton(),
                      mY(10),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: mFieldBG2, borderRadius: mFieldRadius),
                        child: DropdownButton(
                          dropdownColor: mFieldBG2,
                          focusColor: Colors.red,
                          borderRadius: mFieldRadius,
                          elevation: 12,
                          icon: const Icon(
                            Icons.expand_more_outlined,
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 0),
                          hint: const Text("Label"),
                          underline: none(),
                          onChanged: (val) => {},
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text("Item 1"),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("Item 2"),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text("Item 3"),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )),
        bottomNavigationBar: MBottomBar());
  }
}

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
  final List<TabItem> items = [
    const TabItem(
      icon: Icons.home,
      // title: 'Home',
    ),
    const TabItem(
      icon: Icons.search_sharp,
      title: 'Shop',
    ),
    const TabItem(
      icon: Icons.favorite_border,
      title: 'Wishlist',
    ),
    const TabItem(
      icon: Icons.shopping_cart_outlined,
      title: 'Cart',
    ),
    const TabItem(
      icon: Icons.account_box,
      title: 'profile',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BottomBarInspiredInside(
      items: items,
      backgroundColor: cardBGLight,
      color: Colors.black54,
      colorSelected: Colors.black87,
      indexSelected: _tab,
      onTap: (int index) => setState(() {
        _tab = index;
      }),
      animated: true,
      chipStyle:
          const ChipStyle(convexBridge: true, background: Colors.black12),
      itemStyle: ItemStyle.circle,
    );
  }
}
