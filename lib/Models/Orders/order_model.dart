class OrderModel {
  final int id;
  final String publicId;
  final String? displayName;
  final String status;
  final String term;
  final String paymentMethod;
  final String currency;
  final String subtotalAmount;
  final String? discountAmount;
  final String? taxAmount;
  final num? taxRate;
  final String? shippingAmount;
  final String totalAmount;
  final int itemsCount;
  final String? firstProductName;
  final int remainingItemsCount;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final Map<String, dynamic>? deliveryAddress;
  final String? deliveryAddressLine1;
  final String? deliveryDate;
  final String? deliveryTimeSlot;
  final String? installationPreferredTime;
  final OrderPaymentCardModel? paymentCard;
  final OrderPromotionModel? promotion;
  final String? placedAt;
  final String? confirmedAt;
  final String? scheduledForAt;
  final String? deliveredAt;
  final String? installedAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancellationReason;
  final int trackingProgress;
  final String? paymentStatus;
  final bool isCancellable;

  OrderModel({
    required this.id,
    required this.publicId,
    this.displayName,
    required this.status,
    required this.term,
    required this.paymentMethod,
    required this.currency,
    required this.subtotalAmount,
    this.discountAmount,
    this.taxAmount,
    this.taxRate,
    this.shippingAmount,
    required this.totalAmount,
    required this.itemsCount,
    this.firstProductName,
    this.remainingItemsCount = 0,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryAddressLine1,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.installationPreferredTime,
    this.paymentCard,
    this.promotion,
    this.placedAt,
    this.confirmedAt,
    this.scheduledForAt,
    this.deliveredAt,
    this.installedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.trackingProgress = 0,
    this.paymentStatus,
    this.isCancellable = false,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      publicId: json['public_id'],
      displayName: json['display_name']?.toString(),
      status: json['status'],
      term: json['term'],
      paymentMethod: json['payment_method'],
      currency: json['currency'],
      subtotalAmount: json['subtotal_amount']?.toString() ?? '0.00',
      discountAmount: json['discount_amount']?.toString(),
      taxAmount: json['tax_amount']?.toString(),
      taxRate: json['tax_rate'],
      shippingAmount: json['shipping_amount']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      itemsCount: json['items_count'] ?? 0,
      firstProductName: json['first_product_name'],
      remainingItemsCount: json['remaining_items_count'] ?? 0,
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      customerPhone: json['customer_phone'],
      deliveryAddress: json['delivery_address'] != null
          ? Map<String, dynamic>.from(json['delivery_address'])
          : null,
      deliveryAddressLine1: json['delivery_address_line_1'],
      deliveryDate: json['delivery_date'],
      deliveryTimeSlot: json['delivery_time_slot'],
      installationPreferredTime: json['installation_preferred_time'],
      paymentCard: json['payment_card'] != null
          ? OrderPaymentCardModel.fromJson(json['payment_card'])
          : null,
      promotion: json['promotion'] != null
          ? OrderPromotionModel.fromJson(json['promotion'])
          : null,
      placedAt: json['placed_at'],
      confirmedAt: json['confirmed_at'],
      scheduledForAt: json['scheduled_for_at'],
      deliveredAt: json['delivered_at'],
      installedAt: json['installed_at'],
      completedAt: json['completed_at'],
      cancelledAt: json['cancelled_at'],
      cancellationReason: json['cancellation_reason'],
      trackingProgress: json['tracking_progress'] ?? 0,
      paymentStatus: json['payment_status'],
      isCancellable: json['is_cancellable'] ?? false,
    );
  }
}

class OrderItemModel {
  final int productId;
  final String productNameSnapshot;
  final int quantity;
  final String unitPrice;
  final String lineTotal;

  OrderItemModel({
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] ?? 0,
      productNameSnapshot: (json['product_name'] ?? json['product_name_snapshot'])?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      lineTotal: json['line_total']?.toString() ?? '0.00',
    );
  }
}

class OrderPaymentCardModel {
  final String? lastFour;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cvc;

  OrderPaymentCardModel({this.lastFour, this.expiryMonth, this.expiryYear, this.cvc});

  factory OrderPaymentCardModel.fromJson(Map<String, dynamic> json) =>
      OrderPaymentCardModel(
        lastFour: json['last_four'],
        expiryMonth: json['expiry_month'],
        expiryYear: json['expiry_year'],
        cvc: json['cvc'],
      );
}

class OrderPromotionModel {
  final int? id;
  final String? code;
  final String? name;

  OrderPromotionModel({this.id, this.code, this.name});

  factory OrderPromotionModel.fromJson(Map<String, dynamic> json) =>
      OrderPromotionModel(
        id: json['id'],
        code: json['code'],
        name: json['name'],
      );
}

class OrderDetailModel {
  final int id;
  final String publicId;
  final String? displayName;
  final String status;
  final String term;
  final String paymentMethod;
  final String currency;

  final String subtotalAmount;
  final String discountAmount;
  final String taxAmount;
  final num? taxRate;
  final String shippingAmount;
  final String totalAmount;

  final int? itemsCount;
  final List<OrderItemModel> items;
  final String? firstProductName;
  final int remainingItemsCount;

  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;

  final Map<String, dynamic>? deliveryAddress;
  final String? deliveryAddressLine1;
  final String? deliveryCity;
  final String? deliveryPostcode;
  final String? deliveryDate;
  final String? deliveryTimeSlot;
  final String? installationPreferredTime;

  final OrderPaymentCardModel? paymentCard;
  final OrderPromotionModel? promotion;

  final String? placedAt;
  final String? confirmedAt;
  final String? scheduledForAt;
  final String? deliveredAt;
  final String? installedAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancellationReason;

  final int? trackingProgress;
  final String? paymentStatus;
  final bool? isCancellable;

  final List<dynamic>? statusHistory;

  OrderDetailModel({
    required this.id,
    required this.publicId,
    this.displayName,
    required this.status,
    required this.term,
    required this.paymentMethod,
    required this.currency,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.taxAmount,
    this.taxRate,
    required this.shippingAmount,
    required this.totalAmount,
    this.itemsCount,
    this.items = const [],
    this.firstProductName,
    this.remainingItemsCount = 0,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryAddressLine1,
    this.deliveryCity,
    this.deliveryPostcode,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.installationPreferredTime,
    this.paymentCard,
    this.promotion,
    this.placedAt,
    this.confirmedAt,
    this.scheduledForAt,
    this.deliveredAt,
    this.installedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.trackingProgress,
    this.paymentStatus,
    this.isCancellable,
    this.statusHistory,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      status: json['status']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'AED',

      subtotalAmount: json['subtotal_amount']?.toString() ?? '0.00',
      discountAmount: json['discount_amount']?.toString() ?? '0.00',
      taxAmount: json['tax_amount']?.toString() ?? '0.00',
      taxRate: json['tax_rate'],
      shippingAmount: json['shipping_amount']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',

      itemsCount: json['items_count'],
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OrderItemModel.fromJson(e)).toList()
          : [],
      firstProductName: json['first_product_name'],
      remainingItemsCount: json['remaining_items_count'] ?? 0,

      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      customerPhone: json['customer_phone'],

      deliveryAddress: json['delivery_address'] != null
          ? Map<String, dynamic>.from(json['delivery_address'])
          : null,
      deliveryAddressLine1: json['delivery_address_line_1'],
      deliveryCity: json['delivery_city'],
      deliveryPostcode: json['delivery_postcode'],
      deliveryDate: json['delivery_date'],
      deliveryTimeSlot: json['delivery_time_slot'],
      installationPreferredTime: json['installation_preferred_time'],

      paymentCard: json['payment_card'] != null
          ? OrderPaymentCardModel.fromJson(json['payment_card'])
          : null,
      promotion: json['promotion'] != null
          ? OrderPromotionModel.fromJson(json['promotion'])
          : null,

      placedAt: json['placed_at'],
      confirmedAt: json['confirmed_at'],
      scheduledForAt: json['scheduled_for_at'],
      deliveredAt: json['delivered_at'],
      installedAt: json['installed_at'],
      completedAt: json['completed_at'],
      cancelledAt: json['cancelled_at'],
      cancellationReason: json['cancellation_reason'],

      trackingProgress: json['tracking_progress'],
      paymentStatus: json['payment_status'],
      isCancellable: json['is_cancellable'],

      statusHistory: json['status_history'],
    );
  }
}
