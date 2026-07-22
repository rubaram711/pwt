class AdminCapabilitiesModel {

  final Map<String, dynamic> capabilities;

  AdminCapabilitiesModel({
    required this.capabilities,
  });

  factory AdminCapabilitiesModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminCapabilitiesModel(
      capabilities: json,
    );
  }
}