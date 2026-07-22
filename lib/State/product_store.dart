import 'package:flutter/material.dart';


import '../Backend/Products/get_products.dart';
import '../Models/Products/products_model.dart';

class ProductStore extends ChangeNotifier {

  bool isLoading = false;

  String? error;

  List<ProductModel> products = [];

  Future<void> loadProducts({
    bool refresh = false,
  }) async {

    if (isLoading) return;

    isLoading = true;

    error = null;

    if (refresh) {
      products.clear();
    }

    notifyListeners();

    final response = await getProducts();

    if (response.success) {

      products = response.data?.items ?? [];

    } else {

      error = response.message;
    }

    isLoading = false;

    notifyListeners();
  }
}

//add to app state
//  final ProductStore products = ProductStore();
//
//   Future<void> initialize() async {
//
//     await products.loadProducts();
//
//   }