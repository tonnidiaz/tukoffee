// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import "package:tu/tu.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";
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
        final List userRefundIds = (res1.data['refunds'] as List)
            .map((e) => e['paystackId'])
            .where((e) => e != null)
            .toList();

        final res = await RefundsService.getRefunds();

        _refunds.value = res.data['data']
            .where((element) => userRefundIds.contains(element['id']))
            .toList();
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
                TuFuncs.dialog(
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
              : _refunds.value!.isEmpty
                  ? SliverFillRemaining(
                      child: Center(child: h4("Nothing to show")),
                    )
                  : SliverPadding(
                      padding: defaultPadding,
                      sliver: MultiSliver(children: [
                        mY(topMargin),
                        SliverList.builder(
                            itemCount: _refunds.value!.length,
                            itemBuilder: (context, index) {
                              final refund = _refunds.value![index];
                              return TuCard(
                                radius: 5,
                                padding: 0,
                                child: ListTile(
                                  // tileColor: colors.surface,
                                  title: SelectableText(
                                    "#${refund['id']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  isThreeLine: true,
                                  subtitle: tuColumn(children: [
                                    Chip(
                                      label: Text(
                                        "${refund['status']}",
                                      ),
                                    ),
                                    Text(
                                      formatDate(refund['createdAt']),
                                      style: TextStyle(
                                          color: colors.note,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13),
                                    ),
                                    mY(4),
                                    Text(
                                      refund['customer']['email'],
                                      style: TextStyle(
                                          color: colors.note,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                                  ]),
                                ),
                              );
                            })
                      ]),
                    )
        ]),
      ),
    );
  }
}
