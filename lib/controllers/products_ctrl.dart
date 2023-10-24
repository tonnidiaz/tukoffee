import "package:lebzcafe/utils/constants2.dart";
import "package:get/get.dart";
import "package:lebzcafe/utils/functions.dart";

import "../utils/constants.dart";

class ProductsCtrl extends GetxController {
  Rxn<List> products = Rxn();
  void setProducts(List? val) {
    products.value = val;
    setSortedProducts(val);
    if (val == null) return;
    _sortProducts();
  }

  Rxn<List> sortedProducts = Rxn<List>();
  void setSortedProducts(List? val) {
    sortedProducts.value = val;
  }

  Rx<SortBy> sortBy = SortBy.name.obs;
  void setSortBy(SortBy val) {
    sortBy.value = val;
    _sortProducts();
  }

  Rx<SortOrder> sortOrder = SortOrder.ascending.obs;
  void setSortOrder(SortOrder val) {
    sortOrder.value = val;
    _sortProducts();
  }

  Rx<ProductStatus> status = ProductStatus.all.obs;
  void setStatus(ProductStatus val) {
    status.value = val;
    // Filter the  products and sort them
    var prods = products.value;
    switch (val) {
      case ProductStatus.all:
        setSortedProducts(prods);
        break;
      case ProductStatus.instock:
        setSortedProducts(prods!.where((it) => it["quantity"] > 0).toList());
        break;
      case ProductStatus.topSelling:
        setSortedProducts(
            prods!.where((it) => it["top_selling"] == true).toList());
        break;
      case ProductStatus.special:
        setSortedProducts(
            prods!.where((it) => it["on_special"] == true).toList());
        break;
      case ProductStatus.sale:
        setSortedProducts(prods!.where((it) => it["on_sale"] == true).toList());
        break;
      case ProductStatus.out:
        setSortedProducts(prods!.where((it) => it["quantity"] == 0).toList());
        break;
      default:
        break;
    }
    _sortProducts();
  }

  void _sortProducts() {
    clog("SORTING");
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
          clog("bY  NAME");
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

    var prods = [...sortedProducts.value!];
    prods.sort(sorter);
    //clog(prods[0]["name"]);
    setSortedProducts(prods);
  }
}
