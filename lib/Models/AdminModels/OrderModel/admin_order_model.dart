class AdminOrderModel {

  final int? id;

  final String? publicId;

  final String? status;

  final AdminOrderCustomerModel? customer;

  final String? totalAmount;

  final String? currency;

  final String? placedAt;

  final String? paymentMethod;

  final String? paymentStatus;

  AdminOrderModel({
    this.id,
    this.publicId,
    this.status,
    this.customer,
    this.totalAmount,
    this.currency,
    this.placedAt,
    this.paymentMethod,
    this.paymentStatus,
  });

  factory AdminOrderModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminOrderModel(

      id: json['id'],

      publicId: json['public_id'],

      status: json['status'],

      customer: json['customer'] != null
          ? AdminOrderCustomerModel.fromJson(
        json['customer'],
      )
          : null,

      totalAmount: json['total_amount'],

      currency: json['currency'],

      placedAt: json['placed_at'],

      paymentMethod: json['payment_method'],

      paymentStatus: json['payment_status'],
    );
  }
}


class AdminOrderCustomerModel {

  final int? id;

  final String? name;

  final String? email;

  AdminOrderCustomerModel({
    this.id,
    this.name,
    this.email,
  });

  factory AdminOrderCustomerModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminOrderCustomerModel(

      id: json['id'],

      name: json['name'],

      email: json['email'],
    );
  }
}