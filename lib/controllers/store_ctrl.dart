import 'package:flutter/material.dart';
import 'package:lebzcafe/models/store.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';
import '../utils/constants2.dart';

class StoreCtrl extends GetxController {
  final RxBool productsFetched = false.obs;
  void setProductsFetched(bool val) {
    productsFetched.value = val;
  }

  RxList<dynamic> products = [].obs;
  void setProducts(List<dynamic> val) {
    products.value = val;
    // Temporarily assign sorted products
    setSortedProducts(val);
    _sortProducts();
  }

  RxList<dynamic> sortedProducts = [].obs;
  void setSortedProducts(List<dynamic> val) {
    sortedProducts.value = val;
  }

  var cartFetched = false.obs;
  void setcartFetched(bool val) {
    cartFetched.value = val;
  }

  RxMap<String, dynamic> cart = <String, dynamic>{}.obs;
  void setcart(Map<String, dynamic> val) {
    cart.value = val;
  }

  RxDouble deliveryFee = 0.0.obs;
  void setDeliveryFee(double val) {
    deliveryFee.value = val;
  }

  RxMap<String, dynamic> currProduct = <String, dynamic>{}.obs;
  void setCurrProduct(Map<String, dynamic> val) {
    currProduct.value = val;
  }

  Rx<SortBy> sortBy = SortBy.name.obs;
  void setSortBy(SortBy val) {
    sortBy.value = val;
    _sortProducts();
  }

  Rx<List?> stores = (null as List?).obs;
  void setStores(List? val) {
    stores.value = val;
  }

  Rx<ProductStatus> status = ProductStatus.all.obs;
  void setStatus(ProductStatus val) {
    status.value = val;
    // Filter the  products and sort them
    var prods = products;
    switch (val) {
      case ProductStatus.all:
        setSortedProducts(prods);
        break;
      case ProductStatus.instock:
        setSortedProducts(prods.where((it) => it['quantity'] > 0).toList());
        break;
      case ProductStatus.topSelling:
        setSortedProducts(
            prods.where((it) => it['top_selling'] == true).toList());
        break;
      case ProductStatus.special:
        setSortedProducts(
            prods.where((it) => it['on_special'] == true).toList());
        break;
      case ProductStatus.sale:
        setSortedProducts(prods.where((it) => it['on_sale'] == true).toList());
        break;
      case ProductStatus.out:
        setSortedProducts(prods.where((it) => it['quantity'] == 0).toList());
        break;
      default:
        break;
    }
    _sortProducts();
  }

  Rx<SortOrder> sortOrder = SortOrder.ascending.obs;
  void setSortOrder(SortOrder val) {
    sortOrder.value = val;
    _sortProducts();
  }

  void _sortProducts() {
    int dateInMs(dynamic prod) {
      var date = DateTime.parse(prod["date_created"]);
      return date.millisecondsSinceEpoch;
    }

    int sorter(a, b) {
      int s = 1;
      final sortBy = this.sortBy.value;
      final sortOrder = this.sortOrder.value;
      switch (sortBy) {
        case SortBy.name:
          s = sortOrder == SortOrder.ascending
              ? a["name"].compareTo(b["name"])
              : b["name"].compareTo(a["name"]);
          break;
        case SortBy.price:
          s = sortOrder == SortOrder.ascending
              ? a["price"].compareTo(b["price"])
              : b["price"].compareTo(a["price"]);
          break;
        case SortBy.dateCreated:
          s = sortOrder == SortOrder.ascending
              ? dateInMs(a).compareTo(dateInMs(b))
              : dateInMs(b).compareTo(dateInMs(a));
          break;
        default:
          break;
      }
      return s;
    }

    sortedProducts.sort(sorter);
  }
}
