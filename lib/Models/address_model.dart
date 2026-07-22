

import 'location_model.dart';

class AddressModel {

  final int? id;
  final String? label;
  final String? recipientName;
  final String? recipientPhone;
  final String? line1;
  final String? line2;
  final String? city;
  final String? postalCode;
  final String? notes;

  final BasicLocationModel? country;
  final BasicLocationModel? region;

  final bool? isDefault;
  final String? createdAt;

  AddressModel({
    this.id,
    this.label,
    this.recipientName,
    this.recipientPhone,
    this.line1,
    this.line2,
    this.city,
    this.postalCode,
    this.notes,
    this.country,
    this.region,
    this.isDefault,
    this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {

    return AddressModel(
      id: json['id'],
      label: json['label'],
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      postalCode: json['postal_code'],
      notes: json['notes'],

      country: json['country'] != null
          ? BasicLocationModel.fromJson(json['country'])
          : null,

      region: json['region'] != null
          ? BasicLocationModel.fromJson(json['region'])
          : null,

      isDefault: json['is_default'],
      createdAt: json['created_at'],
    );
  }
}