// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/admin/account.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/order_item.dart';
import 'package:frust/widgets/prompt_modal.dart';
import 'package:get/get.dart';

import '../../controllers/app_ctrl.dart';
import '../../controllers/appbar.dart';

class AccountsCtrl extends GetxController {
  Rx<List<dynamic>?> accounts = (null as List<dynamic>?).obs;
  setAccounts(List<dynamic>? val) {
    accounts.value = val;
    setSelectedAccounts([]);
  }

  RxList<dynamic> selectedAccounts = <dynamic>[].obs;
  setSelectedAccounts(List<dynamic> val) {
    selectedAccounts.value = val;
  }
}

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final AccountsCtrl _ctrl = Get.put(AccountsCtrl());
  final AppBarCtrl _appBarCtrl = Get.find();
  final AppCtrl _appCtrl = Get.find();

  /// ****************METHODS******************
  void _deleteAccounts() async {
    showDialog(
        context: context,
        builder: (context) {
          return PromptModal(
            title: "Delete accounts",
            okTxt: "Yes",
            msg: "You sure you want to delete the selected accounts?",
            onOk: () async {
              _appBarCtrl.setSelected([]);
              try {
                final List<dynamic> ids = _appBarCtrl.selected
                    .map((element) => element['_id'])
                    .toList();
                final res =
                    await dio.post("$apiURL/users/delete", data: {'ids': ids});
                _ctrl.setAccounts(_ctrl.accounts.value!
                    .where((it) => !ids.contains(it['_id']))
                    .toList());
                clog(res.data);
                showToast("Accounts deleted successfully!").show(context);
              } catch (e) {
                if (e.runtimeType == DioException) {
                  e as DioException;
                  handleDioException(context: context, exception: e);
                } else {
                  clog(e);
                  showToast('Error deleting accounts!', isErr: true)
                      .show(context);
                }
              }
            },
          );
        });
  }

  /// ****************END METHODS******************
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  _init() async {
    if (_appCtrl.user['permissions'] == 2) {
      _appBarCtrl.setSelectedActions([
        PopupMenuItem(
            onTap: () async {
              _deleteAccounts();
            },
            padding: EdgeInsets.zero,
            child: iconText("Delete", Icons.delete))
      ]);
    }
    await _getAccounts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarCtrl.setSelected([]);
    });
    super.dispose();
  }

  /*  behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ), */
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await _init();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: defaultPadding,
            height: screenSize(context).height -
                statusBarH(context) -
                (appBarH * 2),
            // constraints: BoxConstraints(minHeight: c.maxHeight),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mY(14),
                Text(
                  "Accounts",
                  style: Styles.h1,
                ),
                Obx(() {
                  return _ctrl.accounts.value == null
                      ? Expanded(
                          child: Center(
                            child: Text("Loading...", style: Styles.h3()),
                          ),
                        )
                      : Column(
                          children: [
                            AccountsSection(
                                ctrl: _ctrl,
                                title: "Staff",
                                accounts: [
                                  ..._ctrl.accounts.value!
                                      .where((it) =>
                                          it['permissions'] == 1 ||
                                          it['permissions'] == 2)
                                      .toList(),
                                ]),
                            mY(5),
                            AccountsSection(
                              ctrl: _ctrl,
                              title: "Customers",
                              accounts: _ctrl.accounts.value!
                                  .where((it) => it['permissions'] == 0)
                                  .toList(),
                            ),
                          ],
                        );
                })
              ],
            ),
          ),
        ));
  }

  _getAccounts() async {
    try {
      _ctrl.setAccounts(null);
      final res = await dio.get('$apiURL/users');
      _ctrl.setAccounts(res.data['users']);
    } catch (e) {
      if (e.runtimeType == DioException) {
        e as DioException;
        clog(e.response);
      } else {
        clog(e);
      }
      _ctrl.setAccounts([]);
    }
  }
}

class AccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final AccountsCtrl ctrl;
  AccountCard({super.key, required this.account, required this.ctrl});

  final AppBarCtrl _appBarCtrl = Get.find();
  final AppCtrl _appCtrl = Get.find();
  void _selectItem(Map<String, dynamic> product) {
    var selected = _appBarCtrl.selected
        .where((it) => it['_id'] == account['_id'])
        .isNotEmpty;
    !selected
        ? _appBarCtrl.setSelected([..._appBarCtrl.selected, product])
        : _appBarCtrl.setSelected(_appBarCtrl.selected
            .where((el) => el['_id'] != product['_id'])
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return TuCard(
      my: 2.5,
      onTap: () {
        if (_appBarCtrl.selected.isEmpty) {
          pushTo(context, DashAccountPage(id: "${account['_id']}"));
        } else {
          _selectItem(account);
        }
      },
      onLongPress: () {
        _selectItem(account);
      },
      child: TuListTile(
        leading: Row(
          children: [
            Obx(
              () {
                var selected = _appBarCtrl.selected
                    .where((it) => it['_id'] == account['_id'])
                    .isNotEmpty;
                return _appBarCtrl.selected.isNotEmpty
                    ? SizedBox(
                        //color: Colors.purple,
                        width: 33,
                        child: TuLabeledCheckbox(
                            activeColor: Colors.orange,
                            value: selected,
                            onChanged: (val) {
                              _selectItem(account);
                            }),
                      )
                    : none();
              },
            ),
            const CircleAvatar(
              backgroundColor: Colors.black26,
              foregroundColor: Colors.black,
              child: Icon(Icons.person),
            ),
          ],
        ),
        title: Text(
          "${account['first_name']} ${account['last_name']}",
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: Styles.title(),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(builder: (context) {
              final permissions = account['permissions'];
              var perms = permissions == 0
                  ? "read only"
                  : permissions == 1
                      ? "read/write"
                      : "read/write/delete";
              return tuStatus(perms, fontSize: 12);
            }),
          ],
        ),
        trailing: SizedBox(
          width: 20,
          child: Obx(() {
            int perms = _appCtrl.user['permissions'];
            bool isAdmin = perms == 2;
            return PopupMenuButton(
                splashRadius: 23,
                padding: EdgeInsets.zero,
                itemBuilder: (context) {
                  return !isAdmin
                      ? []
                      : [
                          PopupMenuItem(
                              onTap: () async {
                                //TODO
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return PromptModal(
                                        title: "Delete account",
                                        okTxt: "Yes",
                                        msg:
                                            "You sure you want to delete the account?",
                                        onOk: () async {
                                          try {
                                            final res = await apiDio()
                                                .post("/users/delete", data: {
                                              'ids': [account['_id']]
                                            });
                                            var accs = ctrl.accounts.value!;
                                            ctrl.setAccounts(accs
                                                .where((it) =>
                                                    it['_id'] != account['_id'])
                                                .toList());
                                            clog(res.data);
                                            showToast(
                                                    "Account deleted successfully!")
                                                .show(context);
                                          } catch (e) {
                                            clog(e);
                                            if (e.runtimeType == DioException) {
                                              e as DioException;
                                              handleDioException(
                                                  context: context,
                                                  exception: e,
                                                  msg:
                                                      'Error deleting account!');
                                            } else {
                                              showToast(
                                                      'Error deleting account!',
                                                      isErr: true)
                                                  .show(context);
                                            }
                                          }
                                        },
                                      );
                                    });
                              },
                              child: iconText("Delete", Icons.delete))
                        ];
                });
          }),
        ),
      ),
    );
  }
}

class AccountsSection extends StatefulWidget {
  final List<dynamic> accounts;
  final AccountsCtrl ctrl;
  final String title;
  const AccountsSection({
    super.key,
    required this.ctrl,
    this.title = "",
    this.accounts = const [],
  });

  @override
  State<AccountsSection> createState() => _AccountsSectionState();
}

class _AccountsSectionState extends State<AccountsSection> {
  final AppBarCtrl _appBarCtrl = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: Styles.h2()),
          Obx(() => TuLabeledCheckbox(
              // top-cehckbox
              activeColor: Colors.orange,
              radius: 50,
              value: _appBarCtrl.selected.isNotEmpty &&
                  _appBarCtrl.selected
                          .where((p0) => widget.accounts.contains(p0))
                          .length ==
                      widget.accounts.length,
              onChanged: (val) {
                if (val == true) {
                  // add the accounts to the already existing ones
                  _appBarCtrl.setSelected(
                      [..._appBarCtrl.selected, ...widget.accounts]);
                } else {
                  // All except for the once in the widget.account
                  _appBarCtrl.setSelected(_appBarCtrl.selected
                      .where((it) => !widget.accounts.contains(it))
                      .toList());
                }
              })),
        ],
      ),

      mY(5),

      //id=accounts
      widget.accounts.isEmpty
          ? SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Nothing to show",
                    style: Styles.h3(),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.accounts.map((it) {
                return AccountCard(account: it, ctrl: widget.ctrl);
              }).toList(),
            )
    ]);
  }
}
