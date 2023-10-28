// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import "dart:convert";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/utils/functions2.dart";
import "package:lebzcafe/views/order/index.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/dialog.dart";
import "package:sliver_tools/sliver_tools.dart";

import "refunds.service.dart";

class RefundsPage extends HookWidget {
  final bool isAdmin;
  const RefundsPage({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    final _appCtrl = MainApp.appCtrl;

    final _refunds = useState<List?>(null);

    _init() async {
      try {
        _refunds.value = null;
        final res1 = await apiDio()
            .get('/refunds', queryParameters: {'userId': _appCtrl.user['_id']});
        clog(res1.data);
        final res = await RefundsService.getRefunds();

        _refunds.value = res.data['data'];
      } catch (e) {
        _refunds.value = [];
        errorHandler(e: e, msg: "Failed to fetch refunds");
      }
    }

    useEffect(() {
      _init();
      return () {
        clog("Dispose");
      };
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Refunds"),
        actions: [
          IconButton(
              splashRadius: 20,
              onPressed: () {
                TuFuncs.showTDialog(
                    context,
                    const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "A refund is automatically applied for when cancelling an order"),
                        ],
                      ),
                    ));
              },
              icon: const Icon(Icons.info_outline_rounded)),
          mX(10)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _init();
        },
        child: CustomScrollView(slivers: [
          _refunds.value == null
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : MultiSliver(children: [
                  mY(topMargin),
                  SliverList.builder(
                      itemCount: _refunds.value!.length,
                      itemBuilder: (context, index) {
                        final refund = _refunds.value![index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          child: ListTile(
                            tileColor: cardBGLight,
                            title: SelectableText(
                              "#${refund['id']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            isThreeLine: true,
                            subtitle: tuColumn(children: [
                              mY(4),
                              Chip(
                                label: Text(
                                  "${refund['status']}",
                                ),
                              ),
                              mY(5),
                              Text(
                                formatDate(refund['createdAt']),
                                style: TextStyle(
                                    color: TuColors.note,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13),
                              ),
                              mY(4),
                              Text(
                                refund['initiated_by'],
                                style: TextStyle(
                                    color: TuColors.note,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                              ),
                            ]),
                          ),
                        );
                      })
                ])
        ]),
      ),
    );
  }
}
