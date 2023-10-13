// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lebzcafe/controllers/store_ctrl.dart';
import 'package:lebzcafe/main.dart';
import 'package:lebzcafe/utils/constants2.dart';
import 'package:lebzcafe/utils/functions.dart';
import 'package:lebzcafe/utils/styles.dart';
import 'package:lebzcafe/views/order/index.dart';
import 'package:lebzcafe/views/product/reviews.dart';
import 'package:lebzcafe/widgets/add_product_form.dart';
import 'package:lebzcafe/widgets/common2.dart';
import 'package:lebzcafe/widgets/common3.dart';
import 'package:lebzcafe/widgets/form_view.dart';
import 'package:lebzcafe/widgets/product_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/app_ctrl.dart';
import '../utils/colors.dart';
import '/utils/constants.dart';
import '/widgets/common.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final AppCtrl _appCtrl = Get.find();
  final FormViewCtrl _formViewCtrl = Get.find();
  final StoreCtrl _storeCtrl = Get.find();
  Map<String, dynamic>? _product;
  List? _related = [];
  _setRelated(List? val) {
    setState(() {
      _related = val;
    });
  }

  late Map<dynamic, dynamic> _args;
  int _currImgIndex = 0;
  _setCurrImgIndex(int val) {
    setState(() {
      _currImgIndex = val;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _args = ModalRoute.of(context)!.settings.arguments! as Map;
      });
      _init();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _init() async {
    await _setupProduct();
    await _getRelated();
  }

  _setupProduct() async {
    setState(() {
      _product = null;
    });

    var product =
        await _getProduct("${_args["pid"]}"); //storeStore.currProduct;
    setState(() {
      _product = product;
    });
  }

  Future<Map<String, dynamic>?> _getProduct(String? pid) async {
    if (pid == null) return null;
    clog(pid);
    //if (_product != null) return _product;
    try {
      final url = "$apiURL/products?pid=$pid";
      final res = await dio.get(url);
      final List<dynamic> data = res.data['data'];
      return data.isNotEmpty ? data[0] : null;
    } catch (e) {
      errorHandler(e: e, context: context, msg: "Failed to fetch product");
      return null;
    }
  }

  _getRelated() async {
    if (_product == null) return;
    try {
      _setRelated(null);
      final res =
          await apiDio().get("/products?q=related&pid=${_product!['pid']}");
      _setRelated(res.data['data']);
    } catch (error) {
      clog(error);
      _setRelated([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      appBar: AppBar(
        title: _product == null ? null : Text("${_product!["name"]}"),
        actions: [
          CartBtn(),
          Obx(() => !_appCtrl.isAdmin.value
              ? none()
              : PopupMenuButton(
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        onTap: _onPopupEditTap,
                        child: const Text("Edit"),
                      ),
                      const PopupMenuItem(child: Text("Delete")),
                    ];
                  }))
        ],
      ),
      onRefresh: () async {
        await _setupProduct();
      },
      bottomSheet: Material(
        elevation: 8,
        color: Colors.white,
        shadowColor: Colors.black,
        child: Container(
          width: screenSize(context).width,
          padding: defaultPadding,
          child: _product == null
              ? none()
              : Builder(builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            backgroundColor: TuColors.medium,
                            labelPadding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: -2),
                            label: Text(
                              _product!['quantity'] > 0
                                  ? "${_product!['quantity']} In stock"
                                  : "out of stock",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                          Text(
                            "R${roundDouble(_product!["price"].toDouble(), 2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      mY(8),
                      Obx(() {
                        bool inCart = _storeCtrl.cart.isNotEmpty &&
                            _storeCtrl.cart["products"]
                                .where((el) =>
                                    el["product"]["_id"] == _product!["_id"])
                                .isNotEmpty;

                        return TuButton(
                            width: double.infinity,
                            onPressed: _product!['quantity'] < 1
                                ? null
                                : addRemoveCart,
                            bgColor:
                                inCart ? TuColors.danger : TuColors.success,
                            // radius: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  inCart
                                      ? Icons.remove_shopping_cart
                                      : Icons.add_shopping_cart,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                mX(2),
                                Text(
                                    inCart ? 'REMOVE FROM CART' : 'ADD TO CART',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                              ],
                            ));
                      }),
                    ],
                  );
                }),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: screenSize(context).height - appBarH,
        child: _product == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Loading...",
                      style: Styles.h1,
                    ),
                    mY(5),
                    TuButton(
                        text: "Refresh",
                        onPressed: () async {
                          final res = await _getProduct(_args['pid']);
                          setState(() {
                            _product = res;
                          });
                        })
                  ],
                ),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      //padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          //id=img-wrap
                                          color: appBGLight,
                                          width: constraints.maxWidth,
                                          margin: EdgeInsets.only(top: 6),
                                          height:
                                              constraints.maxWidth - 20 - 40,
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 5, top: 5),

                                          child: _product!['images'].isNotEmpty
                                              ? Image.network(_product![
                                                      'images'][_currImgIndex][
                                                  'url']) //"https://loremflickr.com/g/320/240/tea?random=${Random().nextInt(100)}")
                                              : const Icon(
                                                  Icons.coffee_outlined,
                                                  size: 50,
                                                  color: Colors.black54,
                                                ),
                                        ),
                                        Visibility(
                                          visible:
                                              _product!['images'].isNotEmpty,
                                          child: Positioned(
                                              bottom: 0,
                                              left: 0,
                                              width: constraints.maxWidth,
                                              child: Container(
                                                height: 60,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 2),
                                                color: Colors.black54,
                                                child: Row(
                                                    children:
                                                        (_product!['images']
                                                                as List)
                                                            .asMap()
                                                            .entries
                                                            .map((e) {
                                                  return imgCard(
                                                    onTap: () {
                                                      _setCurrImgIndex(e.key);
                                                    },
                                                    mode: 'add',
                                                    context: context,
                                                    canRemove: false,
                                                    index: e.key,
                                                    child: Image.network(
                                                        e.value['url']),
                                                  );
                                                }).toList()),
                                              )),
                                        )
                                      ],
                                    ),
                                    Container(
                                      color: cardBGLight,
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${_product!['name']}",
                                                  style: Styles.h3(),
                                                ),
                                                mY(5),
                                                Container(
                                                  color: Colors.transparent,
                                                  width: double.infinity,
                                                  child: Text(
                                                    "${_product!['description']}",
                                                    softWrap: true,

                                                    //style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    mY(6),
                                    Container(
                                      color: cardBGLight,
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.star,
                                                  size: 20,
                                                  color: Colors
                                                      .amber //Color.fromARGB(108, 255, 255, 0),
                                                  ),
                                              Text(
                                                " ${_product!['rating'] ?? 0}",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              )
                                            ],
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                pushTo(
                                                    context,
                                                    ProductReviewsPage(
                                                        id: "${_product!['pid']}"));
                                              },
                                              child: Text(
                                                '${_product!['reviews'].length} REVIEW(S)',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ))
                                        ],
                                      ),
                                    ),
                                    mY(6),
                                    Container(
                                      color: cardBGLight,
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10.0),
                                      child: tuColumn(children: [
                                        Text(
                                          'EXTRA INFORMATION',
                                          style: Styles.h4(),
                                        ),
                                        mY(10),
                                        tuTableRow(
                                            const Text(
                                              'Weight',
                                            ),
                                            Text('${_product!['weight']} KG'))
                                      ]),
                                    ),
                                    mY(6),
                                    Container(
                                        color: cardBGLight,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10.0),
                                        child: tuColumn(children: [
                                          Text(
                                            'You may also like',
                                            style: Styles.h4(),
                                          ),
                                          mY(10),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: _related == null
                                                ? none()
                                                : Row(
                                                    children: _related!
                                                        .map((e) => ProductCard(
                                                            product: e))
                                                        .toList()),
                                          )
                                        ]))
                                  ]);
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _rateProduct(val) async {
    try {
      if (_appCtrl.user.isEmpty)
        // ignore: curly_braces_in_flow_control_structures
        return showToast("Please login to rate products", isErr: true)
            .show(context);
      final rating = {"value": val};
      final res = await rateProduct(_product!['pid'], rating);
      final err = res[0];
      final succ = res[1];

      if (err != null) {
        showToast(err, isErr: true).show(context);
      } else {
        showToast(succ, isErr: false).show(context);
      }
    } catch (e) {
      clog(e);
    }
  }

  addRemoveCart() async {
    if (_appCtrl.user.isEmpty) {
      return showToast("Login to add to cart", isErr: true).show(context);
    }
    bool inCart = _storeCtrl.cart.isNotEmpty &&
        _storeCtrl.cart["products"]
            .where((el) => el["product"]["_id"] == _product!["_id"])
            .isNotEmpty;

    clog(!inCart ? "Adding to cart..." : "Removing from cart...");

    var act = inCart ? "remove" : "add";
    try {
      final res = await apiDio().post("/user/cart?action=$act",
          data: {"user": _appCtrl.user["email"], "product": _product!["_id"]});
      _storeCtrl.setcart(res.data["cart"]);
      // t.dismiss();
    } catch (e) {
      clog(e);
      if (e.runtimeType == DioException) {
        handleDioException(
            context: context,
            exception: e as DioException,
            msg: "Error adding/removing item to cart");
      } else {
        showToast("Something went wrong!", isErr: true).show(context);
      }
    }
  }

  _onPopupEditTap() async {
    //  _formViewCtrl.clear();
    Map<String, dynamic> prod = {};
    for (var key in _product!.keys) {
      prod[key] = _product![key];
    }
    _formViewCtrl.setForm(prod);

    TuFuncs.showBottomSheet(
        context: context,
        widget: const AddProductForm(
          title: "Edit product",
          mode: "edit",
          btnTxt: "Edit product",
        ));
    /*  editProductForm(
            context: context, formViewCtrl: _formViewCtrl, product: _product!)); */
  }
}
