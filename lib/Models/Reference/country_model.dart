class CountryModel {

  final int? id;

  final String? code;

  final String? name;

  final String? phoneCode;

  final String? currency;

  final num? vatRate;

  final bool? isActive;

  CountryModel({
    this.id,
    this.code,
    this.name,
    this.phoneCode,
    this.currency,
    this.vatRate,
    this.isActive,
  });

  factory CountryModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return CountryModel();
    }

    return CountryModel(

      id: json['id'],

      code: json['code'],

      name: json['name'],

      phoneCode: json['phone_code'],

      currency: json['currency'],

      vatRate: json['vat_rate'],

      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'code': code,

      'name': name,

      'phone_code': phoneCode,

      'currency': currency,

      'vat_rate': vatRate,

      'is_active': isActive,
    };
  }
}