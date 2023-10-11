// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/map.dart';
import 'package:frust/widgets/common.dart';
import 'package:get/get.dart';

import '../../widgets/common2.dart';
import '../../widgets/form_view.dart';
import '../order/index.dart';

class DashAccountPage extends StatefulWidget {
  final String id;
  const DashAccountPage({super.key, required this.id});

  @override
  State<DashAccountPage> createState() => _DashAccountPageState();
}

class _DashAccountPageState extends State<DashAccountPage> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _getAccount();
  }

  _editFields({required Map<String, dynamic> data, String? field}) async {
    try {
      final res = await apiDio().post(
          "/user/edit${field != null ? "?field=$field" : ""}",
          data: {...data, "userId": _user!["_id"]});
      _setUser(res.data["user"]);
    } catch (e) {
      if (e.runtimeType == DioException) {
        handleDioException(
            context: context,
            exception: e as DioException,
            msg: "Request failed!");
      } else {
        showToast("Request failed!", isErr: true).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: childAppbar(title: _user != null ? _user!['first_name'] : null),
        body: RefreshIndicator(
          onRefresh: () async {
            await _getAccount();
          },
          child: LayoutBuilder(builder: (ctx, constraints) {
            return _user == null
                ? Container(
                    padding: defaultPadding,
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    color: cardBGLight,
                    alignment: Alignment.center,
                    child: Text(
                      "Loading...",
                      style: Styles.h2(),
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      padding: defaultPadding,
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text("Account", style: Styles.h1),
                          Visibility(
                            visible: true,
                            child: Column(children: [
                              TuCard(
                                  my: 5,
                                  width: double.infinity,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        tuTableRow(
                                            Text(
                                              "Personal details",
                                              style: Styles.h2(),
                                            ),
                                            IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  final FormViewCtrl ctrl =
                                                      Get.find();
                                                  ctrl.setForm({
                                                    "first_name":
                                                        _user!['first_name'],
                                                    "last_name":
                                                        _user!['last_name'],
                                                  });
                                                  final form = ctrl.form;
                                                  TuFuncs.showBottomSheet(
                                                      context: context,
                                                      widget: FormView(
                                                          title:
                                                              "Edit personal details",
                                                          fields: [
                                                            TuFormField(
                                                              label:
                                                                  "First name:",
                                                              hint: "e.g. John",
                                                              radius: 5,
                                                              hasBorder: false,
                                                              isRequired: true,
                                                              value: form[
                                                                  "first_name"],
                                                              onChanged: (val) {
                                                                formViewCtrl
                                                                    .setFormField(
                                                                        "first_name",
                                                                        val);
                                                              },
                                                            ),
                                                            TuFormField(
                                                              label:
                                                                  "Last name:",
                                                              hint: "e.g. Doe",
                                                              radius: 5,
                                                              hasBorder: false,
                                                              isRequired: true,
                                                              value: form[
                                                                  "last_name"],
                                                              onChanged: (val) {
                                                                formViewCtrl
                                                                    .setFormField(
                                                                        "last_name",
                                                                        val);
                                                              },
                                                            ),
                                                          ],
                                                          onSubmit: () async {
                                                            await _editFields(
                                                              data: {
                                                                'value': form
                                                              },
                                                            );
                                                            Navigator.pop(
                                                                context);
                                                          }));
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                )),
                                            my: 0),
                                        Column(
                                          //id=personal-details
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            tuTableRow(
                                              Text(
                                                "First name:",
                                                style: Styles.h3(),
                                              ),
                                              Text(
                                                "${_user!['first_name']}",
                                                style: Styles.h3(isLight: true),
                                              ),
                                            ),
                                            tuTableRow(
                                              Text(
                                                "Last name:",
                                                style: Styles.h3(),
                                              ),
                                              Text(
                                                "${_user!['last_name']}",
                                                style: Styles.h3(isLight: true),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ])),
                              TuCard(
                                  my: 5,
                                  width: double.infinity,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        tuTableRow(
                                            Text(
                                              "Contact details",
                                              style: Styles.h2(),
                                            ),
                                            IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                )),
                                            my: 0),
                                        Column(
                                          //id=contact-details
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            tuTableRow(
                                              Text(
                                                "Email:",
                                                style: Styles.h3(),
                                              ),
                                              Text(
                                                "${_user!['email']}",
                                                style: Styles.h3(isLight: true),
                                              ),
                                            ),
                                            tuTableRow(
                                              Text(
                                                "Phone:",
                                                style: Styles.h3(),
                                              ),
                                              Text(
                                                "${_user!['phone']}",
                                                style: Styles.h3(isLight: true),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ])),
                              TuCard(
                                  my: 5,
                                  width: double.infinity,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        tuTableRow(
                                            Text(
                                              "Residential Address",
                                              style: Styles.h2(),
                                            ),
                                            IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  formViewCtrl.setForm(
                                                      _user!['address'] ?? {});
                                                  addEditAddress(
                                                      title: "Edit address");
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                )),
                                            my: 0),
                                        Builder(builder: (context) {
                                          final address = _user!["address"];
                                          return address == null
                                              ? Center(
                                                  child: SizedBox(
                                                  width: double.infinity,
                                                  height: 70,
                                                  child: InkWell(
                                                    onTap: () {
                                                      addEditAddress();
                                                    },
                                                    child: const Card(
                                                        elevation: .5,
                                                        child: Icon(
                                                          Icons.add,
                                                          color: Colors.black87,
                                                          // size: 50,
                                                        )),
                                                  ),
                                                ))
                                              : Text(
                                                  "${address['location']['name']}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                );
                                        })
                                      ])),
                              TuCard(
                                  my: 5,
                                  width: double.infinity,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Permissions",
                                          style: Styles.h2(),
                                        ),
                                        mY(5),
                                        Builder(builder: (context) {
                                          final perms = _user!['permissions'];
                                          return TuDropdownButton(
                                            label: "Permissions",
                                            value: perms,
                                            borderColor: const Color.fromRGBO(
                                                33, 33, 33, .2),
                                            onChanged: (val) async {
                                              try {
                                                await _editFields(data: {
                                                  'value': {'permissions': val}
                                                });
                                                showToast("Done!")
                                                    .show(context);
                                                /* _setUser(
                                                          res.data['user']); */
                                              } catch (e) {
                                                errorHandler(
                                                    e: e,
                                                    context: context,
                                                    msg:
                                                        "Error modifying user permissions");
                                              }
                                            },
                                            items: [
                                              SelectItem("Read only", 0),
                                              SelectItem("Read/Write", 1),
                                              SelectItem(
                                                  "Read/Write/Delete", 2),
                                            ],
                                          ); /* Wrap(
                                          children: [
                                            TuLabeledCheckbox(
                                                label: "Read only",
                                                value: read || delete || write,
                                                onChanged: (val) {}),
                                            TuLabeledCheckbox(
                                                label: "Read/write",
                                                value: write || delete,
                                                onChanged: (val) {}),
                                            TuLabeledCheckbox(
                                                label: "Read/write/delete",
                                                value: delete,
                                                onChanged: (val) {}),
                                          ],
                                        ); */
                                        })
                                      ])),
                            ]),
                          )
                        ],
                      ),
                    ),
                  );
          }),
        ));
  }

  final FormViewCtrl formViewCtrl = Get.find();
  addEditAddress({String? title}) async {
    TuFuncs.showBottomSheet(
        context: context,
        widget: MapPage(onSubmit: (val) async {
          if (val.isEmpty) return;
          _editFields(data: {
            "value": {"location": val}
          }, field: "address");
        }));
  }

  _setUser(Map<String, dynamic>? val) {
    setState(() {
      _user = val;
    });
  }

  _getAccount() async {
    try {
      final res = await dio.get('$apiURL/users?id=${widget.id}');
      _setUser(res.data['users'][0]);
    } catch (e) {
      errorHandler(e: e, context: context);
    }
  }
}
