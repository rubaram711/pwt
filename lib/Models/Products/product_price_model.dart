class ProductPriceModel {

  final int? id;
  final String term;
  final String amount;
  final String currency;
  final String? period;
  final int? minTermMonths;

  ProductPriceModel({
    this.id,
    required this.term,
    required this.amount,
    required this.currency,
    this.period,
    this.minTermMonths,
  });

  factory ProductPriceModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return ProductPriceModel(

      id: json['id'],

      term: json['term'] ?? '',

      amount: json['amount'] ?? '',

      currency: json['currency'] ?? '',

      period: json['period'],

      minTermMonths: json['min_term_months'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'amount': amount,
      'currency': currency,
      'period': period,
      'min_term_months': minTermMonths,
    };
  }
}