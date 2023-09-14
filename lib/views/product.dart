// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frust/controllers/store_ctrl.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/widgets/add_product_form.dart';
import 'package:frust/widgets/common2.dart';
import 'package:frust/widgets/form_view.dart';
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
    _setupProduct();
  }

  void _setupProduct() async {
    var product =
        await _getProduct("${_args["pid"]}"); //storeStore.currProduct;
    setState(() {
      _product = product;
    });
  }

  Future<Map<String, dynamic>?> _getProduct(String? pid) async {
    if (pid == null) return null;
    if (_product != null) return _product;
    try {
      final url = "$apiURL/products?pid=$pid";
      final res = await dio.get(url);
      final List<dynamic> data = res.data['data'];
      return data.isNotEmpty ? data[0] : null;
    } catch (e) {
      if (e.runtimeType == DioException) {
        e as DioException;
        clog(e.response);
      }
      clog(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: childAppbar(
        title: _product == null ? "" : "${_product!["name"]}",
      ),
      /*  actions: [
          PopupMenuItem(
              onTap: () {
                if (_args["pid"] != null) {
                  _setupProduct();
                }
                //
              },
              child: const Text("Refresh"))
        ],
        onRefresh: () async {
          clog("Refreshing...");
        }, */
      body: SizedBox(
        width: double.infinity,
        height: screenSize(context).height,
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
                          mY(20),
                          SizedBox(
                            width: screenSize(context).width,
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Container(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            //id=img-wrap
                                            width: constraints.maxWidth,
                                            height:
                                                constraints.maxWidth - 20 - 40,
                                            margin: const EdgeInsets.only(
                                                left: 5, right: 5, top: 5),

                                            child: _product!['images']
                                                    .isNotEmpty
                                                ? Image.network(_product![
                                                        'images'][_currImgIndex]
                                                    [
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                      Padding(
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
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w800),
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
                                                  mY(10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          "${_product!['quantity']} "),
                                                      const Text(
                                                        "in stock",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.star,
                                                          size: 20,
                                                          color: Colors
                                                              .amber //Color.fromARGB(108, 255, 255, 0),
                                                          ),
                                                      Text(
                                                        " ${isNumeric(_product!['rating']) ? _product!['rating'].roundToDouble() : 0}",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Obx(() => !_appCtrl.isAdmin.value
                                                ? none()
                                                : SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: PopupMenuButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemBuilder: (context) {
                                                          return [
                                                            PopupMenuItem(
                                                              onTap:
                                                                  _onPopupEditTap,
                                                              child: const Text(
                                                                  "Edit"),
                                                            ),
                                                            const PopupMenuItem(
                                                                child: Text(
                                                                    "Delete")),
                                                          ];
                                                        }),
                                                  ))
                                          ],
                                        ),
                                      ),
                                    ]),
                              );
                            }),
                          ),
                          mY(8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: TuButton(
                                    text: "Back to store",
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/', (route) => false);
                                    })),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomSheet: Container(
        color: cardBGLight,
        width: screenSize(context).width,
        height: 90,
        padding: defaultPadding2,
        child: _product == null
            ? none()
            : Builder(builder: (context) {
                var ratings = _product!["ratings"] as List<dynamic>;
                var rating = ratings.firstWhereOrNull(
                    (it) => it["customer"] == _appCtrl.user['_id']);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Rate product:"),
                        RatingBar.builder(
                          initialRating:
                              rating != null ? rating["value"].toDouble() : 0,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 18,
                          itemPadding: const EdgeInsets.all(0.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: _rateProduct,
                        )
                      ],
                    ),
                    mY(5),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "R${roundDouble(_product!["price"].toDouble(), 2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                              onPressed: _product!['quantity'] < 1
                                  ? null
                                  : addRemoveCart,
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size.fromHeight(35),
                                  backgroundColor: Colors.red),
                              child: Obx(() {
                                bool inCart = _storeCtrl.cart.isNotEmpty &&
                                    _storeCtrl.cart["products"]
                                        .where((el) =>
                                            el["product"]["_id"] ==
                                            _product!["_id"])
                                        .isNotEmpty;
                                return Row(
                                  children: [
                                    Icon(inCart
                                        ? Icons.remove_shopping_cart
                                        : Icons.add_shopping_cart),
                                    Text(inCart
                                        ? "Remove from cart"
                                        : "Add to cart"),
                                  ],
                                );
                              }))
                        ]),
                  ],
                );
              }),
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
      showToast(
              !inCart ? "Product added to cart!" : "Product removed from cart!")
          .show(context);
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
    //_formViewCtrl.clear();
    _formViewCtrl.setForm({
      "name": _product!['name'],
      "description": _product!['description'],
      "price": _product!['price'],
      "quantity": _product!['quantity'],
      "images": _product!["images"],
      "pid": _product!["pid"]
    });

    pushTo(
        context,
        const AddProductForm(
          title: "Edit product",
          mode: "edit",
          btnTxt: "Edit product",
        ));
    /*  editProductForm(
            context: context, formViewCtrl: _formViewCtrl, product: _product!)); */
  }
}
