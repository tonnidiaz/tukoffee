// ignore_for_file: use_build_context_synchronously
import "package:lebzcafe/views/auth/login.dart";
import "package:tu/tu.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:lebzcafe/controllers/app_ctrl.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/views/auth/verify_email.dart";
import "package:lebzcafe/views/map.dart";

import "../../utils/constants.dart";
import "../../widgets/form_view.dart";
import "../order/index.dart";

class ProfilePage extends StatefulWidget {
  final String? id;
  const ProfilePage({super.key, this.id});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _account;
  final _appCtrl = MainApp.appCtrl;

  _getAccount() async {
    try {
      setState(() {
        _account = null;
      });
      final res =
          await apiDio().get("/users?id=${widget.id ?? _appCtrl.user["_id"]}");
      setState(() {
        _account = res.data["users"][0];
      });
    } catch (e) {
      clog(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  _init() async {
    if (_appCtrl.user.isEmpty) {
      gpop();
      pushTo(const LoginPage(
        to: "/account/profile",
      ));
      return;
    }
    _getAccount();
  }

  @override
  Widget build(BuildContext context) {
    final AppCtrl appCtrl = Get.find();
    final FormCtrl formCtrl = Get.find();

    addEditAddress({String? title}) async {
      pushTo(
        MapPage(onSubmit: (val) async {
          if (val.isEmpty) return;
          try {
            //showToast("Adding address...").show(context);
            showProgressSheet();
            final res = await apiDio().post("/user/edit?field=address", data: {
              "value": val,
              "userId": _account!["_id"],
            });
            setState(() {
              _account = res.data["user"];
            });
            if (_account!["_id"] == appCtrl.user["_id"]) {
              appCtrl.setUser(_account!);
            }
            Get.back();
            // Navigator.pop(context);
          } catch (e) {
            Get.back();
            clog(e);
            if (e.runtimeType == DioException) {
              handleDioException(
                  context: context,
                  exception: e as DioException,
                  msg: "Error adding addess!");
            } else {
              showToast("Error adding address", isErr: true).show(context);
            }
          }
        }),
      );
    }

    void onEditPermissionsClick() {
      formCtrl.setForm({"permissions": _account!["permissions"]});
      Tu.bottomSheet(Container(
        color: colors.surface,
        padding: defaultPadding,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Permissions",
                style: styles.h3(),
              ),
              mY(7),
              Obx(
                () => Wrap(
                  spacing: 10,
                  children: [
                    TuLabeledCheckbox(
                      onChanged: (val) {},
                      label: "READ",
                      value: formCtrl.form["permissions"] >=
                          UserPermissions.read.index,
                      radius: 100,
                    ),
                    TuLabeledCheckbox(
                      onChanged: (val) {
                        var perms = val == true ? 1 : 0;
                        formCtrl.setFormField("permissions", perms);
                      },
                      label: "WRITE",
                      value: formCtrl.form["permissions"] >=
                          UserPermissions.write.index,
                      radius: 100,
                    ),
                    TuLabeledCheckbox(
                      onChanged: (val) {
                        var perms = val == true
                            ? UserPermissions.delete.index
                            : UserPermissions.write.index;
                        formCtrl.setFormField("permissions", perms);
                      },
                      label: "DELETE",
                      value: formCtrl.form["permissions"] >=
                          UserPermissions.delete.index,
                      radius: 100,
                    ),
                  ],
                ),
              ),
              mY(5),
              TuButton(
                text: "Save changes",
                width: double.infinity,
                bgColor: Colors.black87,
                onPressed: () async {
                  try {
                    final res = await apiDio().post("/user/edit", data: {
                      "userId": _account!["_id"],
                      "value": {
                        "permissions": formCtrl.form["permissions"],
                      },
                    });
                    setState(() {
                      _account = res.data["user"];
                    });
                    if (_account!["_id"] == appCtrl.user["_id"]) {
                      appCtrl.setUser(_account!);
                    }
                    Navigator.pop(context);
                  } catch (error) {
                    errorHandler(e: error, context: context);
                  }
                },
              )
            ]),
      ));
    }

    void onEditDetailsBtnClick() {
      final FormCtrl ctrl = Get.find();
      ctrl.setForm({
        "first_name": _account!["first_name"],
        "last_name": _account!["last_name"],
      });
      final form = ctrl.form;
      Get.bottomSheet(TuBottomSheet(
        child: TuForm(
          builder: (key) => Container(
            //color: colors.surface,
            child: tuColumn(
              min: true,
              children: [
                TuFormField(
                  label: "First name:",
                  hint: "e.g. John",
                  radius: 5,
                  required: true,
                  value: form["first_name"],
                  onChanged: (val) {
                    formCtrl.setFormField("first_name", val);
                  },
                ),
                TuFormField(
                  label: "Last name:",
                  hint: "e.g. Doe",
                  radius: 5,
                  required: true,
                  value: form["last_name"],
                  onChanged: (val) {
                    formCtrl.setFormField("last_name", val);
                  },
                ),
                mY(10),
                TuButton(
                    width: double.infinity,
                    text: "SAVE CHANGES",
                    color: Colors.white,
                    bgColor: Colors.black,
                    onPressed: () async {
                      if (key.currentState == null ||
                          !key.currentState!.validate()) return;
                      try {
                        showProgressSheet();
                        final res = await apiDio().post("/user/edit",
                            data: {"value": form, "userId": _account!["_id"]});
                        setState(() {
                          _account = res.data["user"];
                        });
                        if (_account!["_id"] == appCtrl.user["_id"]) {
                          appCtrl.setUser(_account!);
                        }
                        Get.back();
                        Get.back();
                      } catch (e) {
                        //
                        Get.back();
                        errorHandler(e: e, context: context);
                      }
                    }),
              ],
            ),
          ),
        ),
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(_account == null
              ? "Profile"
              : "${_account!["first_name"]} ${_account!["last_name"]}"),
          actions: [
            Visibility(
              visible: widget.id == null,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  pushNamed("/account/settings");
                },
              ),
            ),
            mX(7)
          ],
        ),
        body: _account == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SizedBox(
                height:
                    screenSize(context).height - appBarH - statusBarH(context),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _getAccount();
                  },
                  child: TuScrollview(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: topMargin, horizontal: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: defaultBorderRadius,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        color: colors.surface,
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              tuTableRow(
                                                  Text(
                                                    "Full name",
                                                    style: styles.h4(
                                                        isLight: true,
                                                        color: colors.text),
                                                  ),
                                                  TextButton(
                                                      onPressed:
                                                          onEditDetailsBtnClick,
                                                      child:
                                                          const Text("Edit")),
                                                  my: 0),
                                              mY(8),
                                              Text(
                                                "${_account!["first_name"]} ${_account!["last_name"]}",
                                                style: TextStyle(
                                                    color: colors.text2),
                                              ),
                                            ])),
                                    mY(2.5),
                                    Container(
                                        color: colors.surface,
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                //id=contact-details
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Email",
                                                    style: styles.h4(
                                                        isLight: true,
                                                        color: colors.text),
                                                  ),
                                                  mY(8),
                                                  SelectableText(
                                                    "${_account!["email"]}",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: colors.text2),
                                                  ),
                                                  Visibility(
                                                      visible: !_account![
                                                          "email_verified"],
                                                      child: tuTableRow(
                                                          const Text(""),
                                                          InkWell(
                                                            onTap: () async {
                                                              try {
                                                                formCtrl
                                                                    .setForm({
                                                                  "email":
                                                                      _account![
                                                                          "email"]
                                                                });
                                                                // Generate OTP for email
                                                                await apiDio().post(
                                                                    "/auth/verify-email",
                                                                    data: {
                                                                      "email": formCtrl
                                                                              .form[
                                                                          "email"],
                                                                    });
                                                                showModalBottomSheet(
                                                                    context:
                                                                        context,
                                                                    builder: (c) =>
                                                                        const VerifyEmailView());
                                                              } catch (e) {
                                                                errorHandler(
                                                                    e: e,
                                                                    context:
                                                                        context,
                                                                    msg:
                                                                        "Failed to make request");
                                                              }
                                                            },
                                                            child: const Text(
                                                              "Verify email",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .orange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                          my: 7)),
                                                  mY(8),
                                                  Text(
                                                    "Phone",
                                                    style: styles.h4(
                                                        isLight: true,
                                                        color: colors.text),
                                                  ),
                                                  mY(8),
                                                  SelectableText(
                                                      "${_account!["phone"]}",
                                                      style: TextStyle(
                                                          color: colors.text2)),
                                                ],
                                              ),
                                            ])),
                                    mY(2.5),
                                    Container(
                                        color: colors.surface,
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              tuTableRow(
                                                  Text(
                                                    "Residential Address",
                                                    style: styles.h4(
                                                        isLight: true,
                                                        color: colors.text),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        if (_account![
                                                                "address"] !=
                                                            null) {
                                                          formCtrl.setForm({
                                                            "address":
                                                                _account![
                                                                    "address"]
                                                          });
                                                        }
                                                        addEditAddress(
                                                            title:
                                                                "Edit address");
                                                      },
                                                      child:
                                                          const Text("Edit")),
                                                  my: 0),
                                              mY(8),
                                              Builder(builder: (context) {
                                                final address =
                                                    _account!["address"];
                                                return address == null
                                                    ? Center(
                                                        child: TuCard(
                                                            onTap: () {
                                                              addEditAddress();
                                                            },
                                                            height: 70,
                                                            child: const Icon(
                                                              Icons.add,
                                                              color: Colors
                                                                  .black87,
                                                              // size: 50,
                                                            )))
                                                    : Column(
                                                        //id=address-details
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "${_account!["address"]["place_name"] ?? ""}",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: colors
                                                                    .text2),
                                                          )
                                                        ],
                                                      );
                                              })
                                            ])),
                                    mY(2.5),
                                    widget.id == null
                                        ? none()
                                        : Container(
                                            color: colors.surface,
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            child: tuColumn(
                                              children: [
                                                tuTableRow(
                                                    Text(
                                                      "Permissions",
                                                      style: styles.h4(
                                                          isLight: true,
                                                          color: colors.text),
                                                    ),
                                                    TextButton(
                                                        onPressed:
                                                            onEditPermissionsClick,
                                                        child:
                                                            const Text("Edit")),
                                                    my: 0),
                                                mY(8),
                                                Wrap(
                                                  spacing: 10,
                                                  children: [
                                                    TuLabeledCheckbox(
                                                      onChanged: (val) {},
                                                      label: "READ",
                                                      value: _account![
                                                              "permissions"] >=
                                                          0,
                                                      radius: 100,
                                                    ),
                                                    TuLabeledCheckbox(
                                                      onChanged: (val) {},
                                                      label: "WRITE",
                                                      value: _account![
                                                              "permissions"] >=
                                                          1,
                                                      radius: 100,
                                                    ),
                                                    TuLabeledCheckbox(
                                                      onChanged: (val) {},
                                                      label: "DELETE",
                                                      value: _account![
                                                              "permissions"] >=
                                                          2,
                                                      radius: 100,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                  ]),
                            )
                          ]),
                    ),
                  ),
                ),
              ));
  }
}
