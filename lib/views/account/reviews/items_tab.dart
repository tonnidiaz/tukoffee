// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "package:lebzcafe/main.dart";
import "package:lebzcafe/utils/constants.dart";
import "package:lebzcafe/utils/functions.dart";
import "package:lebzcafe/widgets/review_item2.dart";
import "package:get/get.dart";

class ItemsTabCtrl extends GetxController {
  Rxn<List> products = Rxn();
  setProducts(List? val) {
    products.value = val;
  }
}

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  final _appCtrl = MainApp.appCtrl;
  final _ctrl = Get.put(ItemsTabCtrl());

  /* METHODS */
  _getProducts() async {
    try {
      _ctrl.products.value = null;
      final res = await apiDio().get("/products?q=received");
      List prods = [];
      for (var p in res.data) {
        final List itemIds = p["items"].map((it) => it["_id"]).toList();

        // If prods does not contain an item whose id is in itemIds
        if (prods.firstWhereOrNull((it) => itemIds.contains(it["_id"])) ==
            null) {
          prods = prods + p["items"];
        }
      }

      _ctrl.products.value = prods.where((it) => it != null).toList();
    } catch (e) {
      errorHandler(e: e, context: context, msg: "Failed to fetch products");
    }
  }

  _getReview(product) {
    final revs = product["reviews"] as List;
    return revs.firstWhereOrNull((it) => it["user"] == _appCtrl.user["_id"]);
  }

  @override
  void initState() {
    super.initState();
    _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _getProducts();
      },
      child: Container(
        height: screenSize(context).height,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Obx(
            () => Container(
              padding: defaultPadding,
              width: double.infinity,
              height:
                  screenSize(context).height - appBarH - tabH - statusBarH(),
              child: _ctrl.products.value == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    )
                  : _ctrl.products.value!.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "You have not ordered and received any products using this app yet",
                              textAlign: TextAlign.center,
                            )
                          ],
                        )
                      : Column(
                          children: _ctrl.products.value!
                              .map((data) => ReviewItem2(
                                    prod: data,
                                    rev: _getReview(data),
                                    hasStars: true,
                                    hasTap: false,
                                  ))
                              .toList(),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
