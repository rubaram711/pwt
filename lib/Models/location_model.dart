class BasicLocationModel {
  final String? code;
  final String? name;

  BasicLocationModel({
    this.code,
    this.name,
  });

  factory BasicLocationModel.fromJson(Map<String, dynamic> json) {
    return BasicLocationModel(
      code: json['code'],
      name: json['name'],
    );
  }
}