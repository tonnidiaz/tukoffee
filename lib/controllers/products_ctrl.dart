import 'package:get/get.dart';

import '../utils/constants.dart';

class ProductsCtrl extends GetxController {
  final RxList<dynamic> selectedProducts = [].obs;
  void set_selectedProducts(List<dynamic> val) {
    selectedProducts.value = val;
  }

  final RxBool productsFetched = false.obs;
  void setProductsFetched(bool val) {
    productsFetched.value = val;
  }

  RxList<dynamic> products = [].obs;
  void set_products(List<dynamic> val) {
    products.value = val;
    _sortProducts();
  }

  RxList<dynamic> sortedProducts = [].obs;
  void setSortedProducts(List<dynamic> val) {
    sortedProducts.value = val;
  }

  RxMap<String, dynamic> newProduct = <String, dynamic>{"quantity": 1}.obs;
  void set_newProduct(Map<String, dynamic> val) {
    newProduct.value = val;
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

    sortedProducts.value = products;
    sortedProducts.sort(sorter);
  }
}
