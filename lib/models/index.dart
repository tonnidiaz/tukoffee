class Product {
  late int id;
  late double price;
  late String name;
  int quantity = 1;
  late String decription;
  List<double>? ratings;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> p = {
      "id": id,
      "price": price,
      "name": name,
      "quantity": quantity,
      "ratings": ratings,
      "dedecription": decription,
    };

    return p;
  }

  /*  void print() {
    var p = Product();
    Type t = Product;

  } */
}
