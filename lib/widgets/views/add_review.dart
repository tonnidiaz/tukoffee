import 'package:frust/widgets/tu/form_field.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frust/main.dart';
import 'package:frust/utils/colors.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/common3.dart';
import 'package:frust/widgets/dialog.dart';
import 'package:get/get.dart';

class AddReviewView extends StatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic>? rev;
  final Function? onOk;
  const AddReviewView({super.key, this.rev, required this.product, this.onOk});

  @override
  State<AddReviewView> createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<AddReviewView> {
  final _formKey = GlobalKey<FormState>();
  final _formCtrl = MainApp.formViewCtrl;

  _submitReview() async {
    final form = _formCtrl.form;

    try {
      if (widget.rev != null) {
        //showLoading({})
        await apiDio().post('/products/review?act=edit',
            data: {'id': widget.rev!['_id'], 'review': form});
        //hideLoader()
        showToast('Review edited successfully!');
        Navigator.pop(context);
        if (widget.onOk != null) {
          widget.onOk!();
        }
      } else {
        await apiDio().post('/products/review?act=add',
            data: {'pid': widget.product['pid'], 'review': form});
        //  hideLoader()
        showToast('Review added successfully!');
        Navigator.pop(context);
        if (widget.onOk != null) {
          widget.onOk!();
        }
      }
    } catch (e) {
      errorHandler(e: e, context: context, msg: 'Failed to add review');
      // hideLoader()
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.rev != null) {
        _formCtrl.setForm({
          "title": widget.rev!['title'],
          "name": widget.rev!['name'],
          "body": widget.rev!['body'],
          "rating": widget.rev!['rating']
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
    return Container(
      margin: EdgeInsets.only(bottom: keyboardPadding(context)),
      color: cardBGLight,
      padding: defaultPadding,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.rev == null ? 'New review' : "Edit review",
                style: Styles.h3(),
              ),
              mY(8),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(
                      () => RatingBar.builder(
                          initialRating:
                              _formCtrl.form['rating']?.toDouble() ?? 0,
                          itemSize: 24,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (val) {
                            _formCtrl.setFormField('rating', val);
                          }),
                    ),
                    mY(8),
                    Obx(
                      () => Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TuFormField(
                                label: 'Your name:',
                                required: true,
                                value: _formCtrl.form['name'],
                                onChanged: (val) {
                                  _formCtrl.setFormField('name', val);
                                },
                                hint: "Enter your name...",
                              ),
                              TuFormField(
                                label: 'Review title:',
                                required: true,
                                value: _formCtrl.form['title'],
                                onChanged: (val) {
                                  _formCtrl.setFormField('title', val);
                                },
                                hint: "Enter title for your review...",
                              ),
                              TuFormField(
                                label: 'Review:',
                                required: true,
                                maxLength: 1000,
                                keyboard: TextInputType.multiline,
                                value: _formCtrl.form['body'],
                                maxLines: 4,
                                onChanged: (val) {
                                  _formCtrl.setFormField('body', val);
                                },
                                hint: "Write your review...",
                              ),
                              mY(8),
                              TuButton(
                                text: "SUBMIT REVIEW",
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
