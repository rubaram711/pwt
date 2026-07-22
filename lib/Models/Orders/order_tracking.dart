class OrderNextStep {
  final String status;
  final String label;
  final String? estimatedAt;
  final String? actionRequired;

  OrderNextStep({
    required this.status,
    required this.label,
    this.estimatedAt,
    this.actionRequired,
  });

  factory OrderNextStep.fromJson(Map<String, dynamic> json) => OrderNextStep(
    status: json['status']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    estimatedAt: json['estimated_at']?.toString(),
    actionRequired: json['action_required']?.toString(),
  );
}

class OrderMilestone {
  final String status;
  final String label;
  final String? occurredAt;

  OrderMilestone({required this.status, required this.label, this.occurredAt});

  factory OrderMilestone.fromJson(Map<String, dynamic> json) => OrderMilestone(
    status: json['status']?.toString() ?? '',
    label: json['label']?.toString() ?? json['status']?.toString() ?? '',
    occurredAt: json['occurred_at']?.toString(),
  );
}

class OrderTrackingModel {
  final int orderId;
  final String publicId;
  final String? poNumber;
  final String status;
  final int trackingProgress;
  final String? estimatedDeliveryWindow;
  final OrderNextStep? nextStep;
  final List<OrderMilestone> milestones;

  OrderTrackingModel({
    required this.orderId,
    required this.publicId,
    this.poNumber,
    required this.status,
    required this.trackingProgress,
    this.estimatedDeliveryWindow,
    this.nextStep,
    required this.milestones,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      orderId: json['order_id'] ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      poNumber: json['po_number']?.toString(),
      status: json['status']?.toString() ?? '',
      trackingProgress: json['tracking_progress'] ?? 0,
      estimatedDeliveryWindow: json['estimated_delivery_window']?.toString(),
      nextStep: json['next_step'] != null
          ? OrderNextStep.fromJson(json['next_step'] as Map<String, dynamic>)
          : null,
      milestones: json['milestones'] != null
          ? (json['milestones'] as List)
              .map((e) => OrderMilestone.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
