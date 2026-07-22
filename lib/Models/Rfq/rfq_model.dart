class RfqModel {
  final int id;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? notes;
  final String status;
  final bool processed;
  final String? createdAt;

  RfqModel({
    required this.id,
    this.companyName,
    this.email,
    this.phone,
    this.notes,
    required this.status,
    required this.processed,
    this.createdAt,
  });

  factory RfqModel.fromJson(Map<String, dynamic> json) => RfqModel(
        id: json['id'],
        companyName: json['company_name'],
        email: json['email'],
        phone: json['phone'],
        notes: json['notes'],
        status: json['status'] ?? 'pending',
        processed: json['processed'] ?? false,
        createdAt: json['created_at'],
      );
}
