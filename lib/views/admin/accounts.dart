// ignore_for_file: use_build_context_synchronously

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/views/account/profile.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:lebzcafe/widgets/common3.dart";
import "package:lebzcafe/widgets/prompt_modal.dart";
import "package:get/get.dart";
import "package:tu/tu.dart";
import "../../controllers/app_ctrl.dart";
import "../../controllers/appbar.dart";

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
                    .map((element) => element["_id"])
                    .toList();
                final res =
                    await apiDio().post("/users/delete", data: {"ids": ids});
                _ctrl.setAccounts(_ctrl.accounts.value!
                    .where((it) => !ids.contains(it["_id"]))
                    .toList());
                clog(res.data);
                showToast("Accounts deleted successfully!").show(context);
              } catch (e) {
                if (e.runtimeType == DioException) {
                  e as DioException;
                  handleDioException(context: context, exception: e);
                } else {
                  clog(e);
                  showToast("Error deleting accounts!", isErr: true)
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
    if (_appCtrl.user["permissions"] == 2) {
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
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: CustomScrollView(
              slivers: [
                TuSliver(child: mY(topMargin)),
                TuSliver(
                  child: Obx(
                    () => TuFormField(
                      hint: "Name or email",
                      fill: colors.surface,
                      hasBorder: false,
                      radius: 100,
                      prefixIcon: TuIcon(Icons.search),
                      value: _ctrl.query.value,
                      onChanged: (val) {
                        _ctrl.setQuery(val);

                        _ctrl.setFilteredAccounts(
                            _ctrl.accounts.value!.where((p0) {
                          var firstLastName =
                              "${p0["first_name"]} ${p0["last_name"]}";

                          var filter = "${p0["email"]}".contains(
                                  RegExp(val, caseSensitive: false)) ||
                              firstLastName.contains(
                                  RegExp(val, caseSensitive: false)) ||
                              "${p0["first_name"]}"
                                  .contains(RegExp(val, caseSensitive: false));
                          return filter;
                        }).toList());
                      },
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Obx(() {
                    return _ctrl.accounts.value == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              mY(topMargin),
                              AccountsSection(
                                  ctrl: _ctrl,
                                  title: "Staff",
                                  accounts: [
                                    ..._ctrl.filteredAccounts
                                        .where((it) =>
                                            it["permissions"] ==
                                                UserPermissions.write.index ||
                                            it["permissions"] ==
                                                UserPermissions.delete.index)
                                        .toList(),
                                  ]),
                              mY(5),
                              AccountsSection(
                                ctrl: _ctrl,
                                title: "Customers",
                                accounts: _ctrl.filteredAccounts
                                    .where((it) =>
                                        it["permissions"] ==
                                        UserPermissions.read.index)
                                    .toList(),
                              ),
                            ],
                          );
                  }),
                )
              ],
            ),
          )),
    );
  }

  _getAccounts() async {
    try {
      _ctrl.setAccounts(null);
      final res = await apiDio().get("/users");
      _ctrl.setAccounts(res.data["users"]);
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
        .where((it) => it["_id"] == account["_id"])
        .isNotEmpty;
    !selected
        ? _appBarCtrl.setSelected([..._appBarCtrl.selected, product])
        : _appBarCtrl.setSelected(_appBarCtrl.selected
            .where((el) => el["_id"] != product["_id"])
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return TuCard(
      my: 2.5,
      onTap: () {
        if (_appBarCtrl.selected.isEmpty) {
          pushTo(ProfilePage(id: "${account["_id"]}"));
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
                        .where((it) => it["_id"] == account["_id"])
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
                  child: svgIcon(name: "br-user", color: colors.text2),
                ),
              ],
            ),
            title: Text(
              "${account["first_name"]} ${account["last_name"]}",
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: styles.title(),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${account["email"]}",
                  style: const TextStyle(fontSize: 14),
                )
              ],
            ),
            trailing: SizedBox(
              width: 25,
              child: Obx(() {
                int perms = _appCtrl.user["permissions"];
                bool isAdmin = perms == 2;
                return PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: colors.text2),
                    splashRadius: 23,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                            enabled: isAdmin,
                            onTap: () async {
                              clog("TU FUNCS DLG");
                              Tu.dialog(
                                PromptDialog(
                                  title: "Delete account",
                                  okTxt: "Yes",
                                  msg:
                                      "Do you want to permenently delete this account?",
                                  onOk: () async {
                                    try {
                                      final res = await apiDio()
                                          .post("/users/delete", data: {
                                        "ids": [account["_id"]]
                                      });
                                      var accs = ctrl.accounts.value!;
                                      ctrl.setAccounts(accs
                                          .where((it) =>
                                              it["_id"] != account["_id"])
                                          .toList());
                                      clog(res.data);
                                      gpop();
                                      showToast("Account deleted successfully!")
                                          .show(context);
                                    } catch (e) {
                                      clog(e);
                                      gpop();
                                      errorHandler(
                                          e: e, msg: "Error deleting account");
                                    }
                                  },
                                ),
                              );
                            },
                            child: const Text("Delete"))
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
      radius: 5,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.title,
          style: styles.h3(isLight: true),
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
                      style: styles.h3(isLight: true),
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
