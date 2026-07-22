class MachineModel {
  final int id;
  final String publicId;
  final String serialNumber;
  final String? displayName;
  final MachineProductModel product;
  final MachineProductPriceModel? productPrice;
  final String? locationLabel;
  final String countryCode;
  final String? installedAt;
  final String? nextMaintenanceDueAt;
  final bool isActive;
  final String term;
  final String status;
  final bool needsMaintenance;
  final bool canRequestMaintenance;
  final MachineListAddress? address;

  MachineModel({
    required this.id,
    required this.publicId,
    required this.serialNumber,
    this.displayName,
    required this.product,
    this.productPrice,
    this.locationLabel,
    required this.countryCode,
    this.installedAt,
    this.nextMaintenanceDueAt,
    required this.isActive,
    required this.term,
    required this.status,
    required this.needsMaintenance,
    required this.canRequestMaintenance,
    this.address,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id: json['id'] ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      serialNumber: json['serial_number']?.toString() ?? '',
      displayName: (json['display_name'] ?? json['location_label'])?.toString(),
      product: MachineProductModel.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
      productPrice: json['product_price'] != null
          ? MachineProductPriceModel.fromJson(json['product_price'] as Map<String, dynamic>)
          : null,
      locationLabel: json['location_label']?.toString(),
      countryCode: json['country_code']?.toString() ?? '',
      installedAt: json['installed_at']?.toString(),
      nextMaintenanceDueAt: json['next_maintenance_due_at']?.toString(),
      isActive: json['is_active'] ?? true,
      term: json['term']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      needsMaintenance: json['needs_maintenance'] ?? false,
      canRequestMaintenance: json['can_request_maintenance'] ?? false,
      address: json['address'] != null
          ? MachineListAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MachineProductModel {
  final int id;
  final String code;
  final String name;
  final String? shortDescription;
  final String? imageUrl;

  MachineProductModel({
    required this.id,
    required this.code,
    required this.name,
    this.shortDescription,
    this.imageUrl,
  });

  factory MachineProductModel.fromJson(Map<String, dynamic> json) => MachineProductModel(
    id: json['id'] ?? 0,
    code: json['code']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    shortDescription: json['short_description']?.toString(),
    imageUrl: json['image_url']?.toString(),
  );
}

class MachineListAddress {
  final String label;
  final String city;

  MachineListAddress({required this.label, required this.city});

  factory MachineListAddress.fromJson(Map<String, dynamic> json) => MachineListAddress(
    label: json['label']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
  );
}

class MachineProductPriceModel {
  final String term;
  final String amount;
  final String currency;

  MachineProductPriceModel({required this.term, required this.amount, required this.currency});

  factory MachineProductPriceModel.fromJson(Map<String, dynamic> json) => MachineProductPriceModel(
    term: json['term']?.toString() ?? '',
    amount: json['amount']?.toString() ?? '0.00',
    currency: json['currency']?.toString() ?? 'AED',
  );
}
