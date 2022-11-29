import 'package:capotcha/modules/Products/model/product_model.dart';

class ProductList {
  // String? name;
  List<Product>? listProduct;

  ProductList({
    // this.name,
    this.listProduct,
  });

  ProductList.fromJson(Map<String, dynamic> json) {
    // name = json['name'].toString();
    if (json['data'] != null) {
      listProduct = <Product>[];
      json['data'].forEach((v) {
        listProduct!.add(new Product.fromJson(v));
      });
    }
    // listProduct = json['product'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['name'] = this.name;
    if (this.listProduct != null) {
      data['data'] = this.listProduct!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
