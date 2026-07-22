// PWT domain models. Ported 1:1 from the prototype's mock-data shapes
// (see proto/shared.jsx). Plain immutable data classes — swap the static
// mock lists in mock_data.dart for API calls when the backend lands.

import 'package:flutter/widgets.dart';

enum AccountKind { individual, business }

/// rent | buy | quote
enum Plan { rent, buy, quote }

extension PlanX on Plan {
  String get id => switch (this) {
        Plan.rent => 'rent',
        Plan.buy => 'buy',
        Plan.quote => 'quote',
      };
  static Plan fromId(String id) => switch (id) {
        'buy' => Plan.buy,
        'quote' => Plan.quote,
        _ => Plan.rent,
      };
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.cat,
    required this.img,
    required this.tint,
    this.price,
    this.buyPrice,
    this.quoteOnly = false,
    required this.blurb,
  });

  final String id;
  final String name;
  final String cat;
  final String img; // original asset path → pwtImage()
  final Color tint;
  final int? price; // monthly rent
  final int? buyPrice;
  final bool quoteOnly;
  final String blurb;
}

class ProductDetail {
  const ProductDetail({
    required this.rating,
    required this.reviews,
    this.badge,
    required this.sparkling,
    required this.specs,
  });

  final double rating;
  final int reviews;
  final String? badge;
  final bool sparkling;
  final List<List<String>> specs; // [['Daily output','90 L/day'], ...]
}

class Review {
  const Review({
    required this.initials,
    required this.name,
    required this.date,
    required this.stars,
    required this.text,
  });
  final String initials;
  final String name;
  final String date;
  final int stars;
  final String text;
}

class MaintenanceWindow {
  const MaintenanceWindow({required this.date, required this.window});
  final String date;
  final String window;
}

class Device {
  const Device({
    required this.id,
    required this.product,
    required this.name,
    required this.img,
    required this.tint,
    required this.plan,
    this.imageUrl,
    this.rent,
    this.since,
    this.location,
    this.lastService,
    this.nextService,
    this.maintenanceScheduled,
    this.status,
    this.orderId,
    this.eta,
  });

  final String id;
  final String product;
  final String name;
  final String img;
  final String? imageUrl;
  final Color tint;
  final Plan plan;
  final int? rent;
  final String? since;
  final String? location;
  final String? lastService;
  final String? nextService;
  final MaintenanceWindow? maintenanceScheduled;
  final String? status;
  final String? orderId;
  final String? eta;

  bool get isOrdered => status == 'ordered';
}

/// active | delivered | quote_pending | quote_sent | cancelled | approved
class Order {
  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.plan,
    this.amount,
    required this.status,
    required this.statusLabel,
  });
  final String id;
  final String date;
  final String items;
  final Plan plan;
  final int? amount;
  final String status;
  final String statusLabel;
}

/// scheduled | in_progress | completed
class MaintenanceRequest {
  const MaintenanceRequest({
    required this.id,
    required this.deviceId,
    required this.device,
    required this.issue,
    required this.raised,
    required this.status,
    required this.statusLabel,
    required this.schedule,
    required this.tech,
  });
  final String id;
  final String deviceId;
  final String device;
  final String issue;
  final String raised;
  final String status;
  final String statusLabel;
  final String schedule;
  final String tech;

  bool get isOpen => status == 'scheduled' || status == 'in_progress';
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.kind, // visa | mastercard
    required this.last4,
    required this.exp,
    required this.primary,
    required this.holder,
  });
  final String id;
  final String kind;
  final String last4;
  final String exp;
  final bool primary;
  final String holder;
}

class Company {
  const Company({
    required this.name,
    required this.trn,
    required this.industry,
    required this.address,
    required this.contact,
    required this.email,
  });
  final String name;
  final String trn;
  final String industry;
  final String address;
  final String contact;
  final String email;
}

class AppUser {
  const AppUser({
    required this.name,
    required this.initials,
    required this.phone,
    required this.email,
    required this.kind,
    required this.addressLabel,
    this.company,
  });
  final String name;
  final String initials;
  final String phone;
  final String email;
  final AccountKind kind;
  final String addressLabel;
  final Company? company;
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.line,
    required this.city,
    required this.phone,
    required this.isDefault,
  });
  final String id;
  final String label;
  final String line;
  final String city;
  final String phone;
  final bool isDefault;

  Address copyWith({String? label, String? line, String? city, String? phone, bool? isDefault}) =>
      Address(
        id: id,
        label: label ?? this.label,
        line: line ?? this.line,
        city: city ?? this.city,
        phone: phone ?? this.phone,
        isDefault: isDefault ?? this.isDefault,
      );
}

class Invoice {
  const Invoice({
    required this.id,
    required this.date,
    required this.desc,
    required this.amount,
    required this.status, // paid | due
  });
  final String id;
  final String date;
  final String desc;
  final double amount;
  final String status;
}

/// A line in the cart.
class CartItem {
  const CartItem({required this.productId, required this.plan, required this.qty, this.backendItemId});
  final String productId;
  final Plan plan;
  final int qty;
  final int? backendItemId;

  CartItem copyWith({Plan? plan, int? qty, int? backendItemId}) =>
      CartItem(productId: productId, plan: plan ?? this.plan, qty: qty ?? this.qty, backendItemId: backendItemId ?? this.backendItemId);
}
