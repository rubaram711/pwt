import 'admin_order_model.dart';

class AdminOrderDetailsModel {

  final int? id;

  final String? publicId;

  final String? status;

  final List<AdminOrderItemModel> items;

  final AdminOrderCustomerModel? customer;

  final AdminOrderPaymentModel? payment;

  final AdminInstallationModel? installation;

  AdminOrderDetailsModel({
    this.id,
    this.publicId,
    this.status,
    required this.items,
    this.customer,
    this.payment,
    this.installation,
  });

  factory AdminOrderDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminOrderDetailsModel(

      id: json['id'],

      publicId: json['public_id'],

      status: json['status'],

      items: json['items'] != null
          ? List<AdminOrderItemModel>.from(
        json['items'].map(
              (x) => AdminOrderItemModel.fromJson(x),
        ),
      )
          : [],

      customer: json['customer'] != null
          ? AdminOrderCustomerModel.fromJson(
        json['customer'],
      )
          : null,

      payment: json['payment'] != null
          ? AdminOrderPaymentModel.fromJson(
        json['payment'],
      )
          : null,

      installation: json['installation'] != null
          ? AdminInstallationModel.fromJson(
        json['installation'],
      )
          : null,
    );
  }
}


class AdminOrderItemModel {

  final int? productId;

  final int? quantity;

  AdminOrderItemModel({
    this.productId,
    this.quantity,
  });

  factory AdminOrderItemModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminOrderItemModel(

      productId: json['product_id'],

      quantity: json['quantity'],
    );
  }
}


class AdminOrderPaymentModel {

  final int? id;

  final String? status;

  final String? amount;

  AdminOrderPaymentModel({
    this.id,
    this.status,
    this.amount,
  });

  factory AdminOrderPaymentModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminOrderPaymentModel(

      id: json['id'],

      status: json['status'],

      amount: json['amount'],
    );
  }
}


class AdminInstallationModel {

  final String? scheduledForAt;

  final int? technicianUserId;

  AdminInstallationModel({
    this.scheduledForAt,
    this.technicianUserId,
  });

  factory AdminInstallationModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminInstallationModel(

      scheduledForAt:
      json['scheduled_for_at'],

      technicianUserId:
      json['technician_user_id'],
    );
  }
}