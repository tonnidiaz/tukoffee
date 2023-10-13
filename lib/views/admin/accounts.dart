// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lebzcafe/utils/colors.dart';
import 'package:lebzcafe/utils/constants.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/account/profile.dart';
import 'package:lebzcafe/views/admin/account.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/widgets/common.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/order_item.dart';
import 'package:lebzcafe/widgets/prompt_modal.dart';
import 'package:get/get.dart';
import 'package:lebzcafe/widgets/tu/form_field.dart';

import '../../controllers/app_ctrl.dart';
import '../../controllers/appbar.dart';

class AccountsCtrl extends GetxController {
  Rx<List<dynamic>?> accounts = (null as List<dynamic>?).obs;
  setAccounts(List<dynamic>? val) {
    accounts.value = val;
    setSelectedAccounts([]);
    if (val != null) {
      setFilteredAccounts(val);
    }
  }

  RxList filteredAccounts = [].obs;
  setFilteredAccounts(List val) {
    filteredAccounts.value = val;
    setSelectedAccounts([]);
  }

  RxList<dynamic> selectedAccounts = <dynamic>[].obs;
  setSelectedAccounts(List<dynamic> val) {
    selectedAccounts.value = val;
  }

  RxString query = "".obs;
  setQuery(String val) {
    query.value = val;
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
          return PromptDialog(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            await _init();
          },
          child: SingleChildScrollView(
            child: Container(
              height: screenSize(context).height -
                  statusBarH(context: context) -
                  (appBarH * 2),
              // constraints: BoxConstraints(minHeight: c.maxHeight),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mY(topMargin),
                  Obx(
                    () => Container(
                      color: cardBGLight,
                      padding: defaultPadding,
                      child: TuFormField(
                        hint: "Name or email",
                        prefixIcon: TuIcon(Icons.search),
                        value: _ctrl.query.value,
                        onChanged: (val) {
                          _ctrl.setQuery(val);

                          _ctrl.setFilteredAccounts(
                              _ctrl.accounts.value!.where((p0) {
                            var firstLastName =
                                "${p0['first_name']} ${p0['last_name']}";

                            var filter = "${p0['email']}".contains(
                                    RegExp(val, caseSensitive: false)) ||
                                firstLastName.contains(
                                    RegExp(val, caseSensitive: false)) ||
                                "${p0['first_name']}".contains(
                                    RegExp(val, caseSensitive: false));
                            return filter;
                          }).toList());
                        },
                      ),
                    ),
                  ),
                  Obx(() {
                    return _ctrl.accounts.value == null
                        ? const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Column(
                            children: [
                              mY(topMargin),
                              AccountsSection(
                                  ctrl: _ctrl,
                                  title: "Staff",
                                  accounts: [
                                    ..._ctrl.filteredAccounts
                                        .where((it) =>
                                            it['permissions'] == 1 ||
                                            it['permissions'] == 2)
                                        .toList(),
                                  ]),
                              mY(5),
                              AccountsSection(
                                ctrl: _ctrl,
                                title: "Customers",
                                accounts: _ctrl.filteredAccounts
                                    .where((it) => it['permissions'] == 0)
                                    .toList(),
                              ),
                            ],
                          );
                  })
                ],
              ),
            ),
          )),
    );
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
          pushTo(context, ProfilePage(id: "${account['_id']}"));
        } else {
          _selectItem(account);
        }
      },
      onLongPress: () {
        _selectItem(account);
      },
      child: Column(
        children: [
          TuListTile(
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
                CircleAvatar(
                  backgroundColor: Colors.black12,
                  foregroundColor: TuColors.note,
                  child: const Icon(Icons.person),
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
                Text(
                  "${account['email']}",
                  style: const TextStyle(fontSize: 14),
                )
              ],
            ),
            trailing: SizedBox(
              width: 20,
              child: Obx(() {
                int perms = _appCtrl.user['permissions'];
                bool isAdmin = perms == 2;
                return PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: TuColors.text2),
                    splashRadius: 23,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) {
                      return !isAdmin
                          ? []
                          : [
                              PopupMenuItem(
                                  onTap: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return PromptDialog(
                                            title: "Delete account",
                                            okTxt: "Yes",
                                            msg:
                                                "You sure you want to delete the account?",
                                            onOk: () async {
                                              try {
                                                final res = await apiDio().post(
                                                    "/users/delete",
                                                    data: {
                                                      'ids': [account['_id']]
                                                    });
                                                var accs = ctrl.accounts.value!;
                                                ctrl.setAccounts(accs
                                                    .where((it) =>
                                                        it['_id'] !=
                                                        account['_id'])
                                                    .toList());
                                                clog(res.data);
                                                showToast(
                                                        "Account deleted successfully!")
                                                    .show(context);
                                              } catch (e) {
                                                clog(e);
                                                if (e.runtimeType ==
                                                    DioException) {
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
          mY(7),
          devider()
        ],
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
    return TuCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.title,
          style: Styles.h3(isLight: true),
        ),
        mY(topMargin),

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
      ]),
    );
  }
}
