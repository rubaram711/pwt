class ApplyPromoResponseModel {
  String? message;
  num? discount;

  ApplyPromoResponseModel({
    this.message,
    this.discount,
  });

  ApplyPromoResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'discount': discount,
    };
  }
}