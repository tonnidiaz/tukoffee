import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';

import '../../../utils/functions.dart';
import '../../main.dart';

class TuMultiselect extends StatefulWidget {
  final List<int> selected;
  final Function(List<int>) onOk;
  final List<TuMultiselectDialogItem> items;
  final String dialogTitle;
  const TuMultiselect(
      {super.key,
      this.dialogTitle = "",
      this.selected = const [],
      required this.onOk,
      this.items = const []});

  @override
  State<TuMultiselect> createState() => _TuMultiselectState();
}

class _TuMultiselectState extends State<TuMultiselect> {
  List<int> _selected = [];
  _setSelected(List<int> val) {
    setState(() {
      _selected = val;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setSelected(widget.selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TuFormField(
      label: "Stores:",
      readOnly: true,
      value: "(${_selected.length}) selected",
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => TuMultiselectDialog(
                  title: widget.dialogTitle,
                  items: widget.items,
                  selected: _selected,
                  onOk: widget.onOk,
                  setSelected: (val) {
                    _setSelected(val);
                  },
                ));
      },
    );
  }
}

class TuMultiselectDialogItem {
  final String label;
  final dynamic it;
  final Widget? subtitle;
  const TuMultiselectDialogItem(
      {required this.label, required this.it, this.subtitle});
}

class TuMultiselectDialog extends StatefulWidget {
  final List<int> selected;
  final List<TuMultiselectDialogItem> items;
  final Function(List<int> val) setSelected;
  final Function(List<int> val) onOk;
  final String title;
  const TuMultiselectDialog(
      {super.key,
      this.title = "",
      required this.items,
      required this.selected,
      required this.onOk,
      required this.setSelected});

  @override
  State<TuMultiselectDialog> createState() => _TuMultiselectDialogState();
}

class _TuMultiselectDialogState extends State<TuMultiselectDialog> {
  List<int> _selected = [];
  _setSelected(List<int> val) {
    setState(() {
      _selected = val;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setSelected(widget.selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: defaultPadding2,
      contentPadding: defaultPadding,
      title: Text(widget.title),
      content: Container(
        // padding: defaultPadding,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              var item = widget.items[index];
              clog(item.subtitle);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: TuListTile(
                    leading: TuLabeledCheckbox(
                      value: _selected.contains(index),
                      onChanged: (val) {
                        var newSelected = val == true
                            ? [..._selected, index]
                            : _selected
                                .where((element) => element != index)
                                .toList();
                        _setSelected(newSelected);
                        widget.setSelected(newSelected);
                      },
                    ),
                    title: Text(
                      item.label,
                      style: Styles.subtitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: item.subtitle),
              );
            }),
      ),
      actions: [
        TextButton(
            onPressed: () {
              // Reset selected
              widget.setSelected(widget.selected);
              Navigator.pop(context);
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              widget.onOk(_selected);
            },
            child: const Text("OK")),
      ],
    );
  }
}
