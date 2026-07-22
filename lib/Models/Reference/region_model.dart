class RegionModel {

  final int? id;

  final String? code;

  final String? name;

  final String? countryCode;

  final bool? isActive;

  RegionModel({
    this.id,
    this.code,
    this.name,
    this.countryCode,
    this.isActive,
  });

  factory RegionModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return RegionModel();
    }

    return RegionModel(

      id: json['id'],

      code: json['code'],

      name: json['name'],

      countryCode: json['country_code'],

      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'code': code,

      'name': name,

      'country_code': countryCode,

      'is_active': isActive,
    };
  }
}