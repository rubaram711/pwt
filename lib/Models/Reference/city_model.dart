class CityModel {
  final int? id;
  final String? code;
  final String? name;
  final bool? isActive;

  CityModel({this.id, this.code, this.name, this.isActive});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      isActive: json['is_active'],
    );
  }
}
