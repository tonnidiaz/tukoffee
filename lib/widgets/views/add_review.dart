import "package:lebzcafe/utils/constants2.dart";
import "package:lebzcafe/utils/types.dart";

import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/colors.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:tu/tu.dart";

class AddReviewView extends StatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic>? rev;
  final Function? onOk;
  final bool isAdmin;
  const AddReviewView(
      {super.key,
      this.rev,
      required this.product,
      this.onOk,
      this.isAdmin = false});

  @override
  State<AddReviewView> createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<AddReviewView> {
  final _formKey = GlobalKey<FormState>();
  final _formCtrl = MainApp.formCtrl;

  _submitReview() async {
    final form = _formCtrl.form;

    try {
      if (widget.rev != null) {
        //showLoading({})
        showProgressSheet();
        await apiDio().post("/products/review?act=edit",
            data: {"id": widget.rev!["_id"], "review": form});
        //hideLoader()
        gpop();
        if (mounted) {
          await showToast("Review edited successfully!").show(context);
        }
        gpop();
        if (widget.onOk != null) {
          widget.onOk!();
        }
      } else {
        await apiDio().post("/products/review?act=add",
            data: {"pid": widget.product["pid"], "review": form});
        //  hideLoader()
        showToast("Review added successfully!");
        gpop();
        if (widget.onOk != null) {
          widget.onOk!();
        }
      }
    } catch (e) {
      if (mounted) {
        errorHandler(e: e, context: context, msg: "Failed to add review");
      }
      // hideLoader()
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.rev != null) {
        _formCtrl.setForm({
          "title": widget.rev!["title"],
          "name": widget.rev!["name"],
          "body": widget.rev!["body"],
          "rating": widget.rev!["rating"],
          "status": widget.rev!["status"],
        });
      }
    });
  }

  @override
  void dispose() {
    _formCtrl.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TuBottomSheet(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            widget.rev == null ? "New review" : "Edit review",
            style: styles.h3(),
          ),
          mY(8),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(
                  () => RatingBar.builder(
                      initialRating: _formCtrl.form["rating"]?.toDouble() ?? 0,
                      itemSize: 24,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (val) {
                        _formCtrl.setFormField("rating", val);
                      }),
                ),
                mY(8),
                Obx(
                  () => Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TuFormField(
                            label: "Your name:",
                            required: true,
                            value: _formCtrl.form["name"],
                            onChanged: (val) {
                              _formCtrl.setFormField("name", val);
                            },
                            hint: "Enter your name...",
                          ),
                          TuFormField(
                            label: "Review title:",
                            required: true,
                            value: _formCtrl.form["title"],
                            onChanged: (val) {
                              _formCtrl.setFormField("title", val);
                            },
                            hint: "Enter title for your review...",
                          ),
                          TuFormField(
                            label: "Review:",
                            required: true,
                            maxLength: 1000,
                            keyboard: TextInputType.multiline,
                            value: _formCtrl.form["body"],
                            maxLines: 4,
                            onChanged: (val) {
                              _formCtrl.setFormField("body", val);
                            },
                            hint: "Write your review...",
                          ),
                          widget.isAdmin
                              ? TuSelect(
                                  label: "Status:",
                                  bgColor: mFieldBG,
                                  borderColor: mFieldBG2,
                                  value: _formCtrl.form['status'],
                                  items: EReviewStatus.values
                                      .map((e) => SelectItem(
                                          e.name.toUpperCase(), e.name))
                                      .toList(),
                                  onChanged: (val) {
                                    _formCtrl.setFormField('status', val);
                                  },
                                )
                              : none(),
                          mY(8),
                          TuButton(
                            text: widget.rev != null
                                ? "SAVE CHANGES"
                                : "SUBMIT REVIEW",
                            width: double.infinity,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _submitReview();
                              }
                            },
                          )
                        ],
                      )),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
