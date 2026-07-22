class AdminProductPriceModel {

  final int? id;

  final String? term;

  final String? amount;

  final String? currency;

  final String? period;

  final int? minTermMonths;

  final bool? isActive;

  AdminProductPriceModel({
    this.id,
    this.term,
    this.amount,
    this.currency,
    this.period,
    this.minTermMonths,
    this.isActive,
  });

  factory AdminProductPriceModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminProductPriceModel(

      id: json['id'],

      term: json['term'],

      amount:
      json['amount']?.toString(),

      currency:
      json['currency'],

      period:
      json['period'],

      minTermMonths:
      json['min_term_months'],

      isActive:
      json['is_active'],
    );
  }
}