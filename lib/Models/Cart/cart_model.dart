class CartItemProduct {
  final int id;
  final String? code;
  final String? name;
  final String? imageUrl;

  CartItemProduct({required this.id, this.code, this.name, this.imageUrl});

  factory CartItemProduct.fromJson(Map<String, dynamic> json) => CartItemProduct(
        id: json['id'],
        code: json['code'],
        name: json['name'],
        imageUrl: json['image_url'],
      );
}

class CartItemModel {
  final int id;
  final int productId;
  final String term;
  final int quantity;
  final CartItemProduct? product;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.term,
    required this.quantity,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'],
        productId: json['product_id'],
        term: json['term'] ?? 'buy',
        quantity: json['quantity'] ?? 1,
        product: json['product'] != null ? CartItemProduct.fromJson(json['product']) : null,
      );
}

class CartModel {
  final int id;
  final String currency;
  final List<CartItemModel> items;

  CartModel({required this.id, required this.currency, required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        id: json['id'],
        currency: json['currency'] ?? 'AED',
        items: (json['items'] as List? ?? []).map((e) => CartItemModel.fromJson(e)).toList(),
      );
}

