class AdminOrderNoteModel {

  final int? orderId;

  final String? note;

  final bool? isInternal;

  final String? createdAt;

  AdminOrderNoteModel({
    this.orderId,
    this.note,
    this.isInternal,
    this.createdAt,
  });

  factory AdminOrderNoteModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminOrderNoteModel(

      orderId: json['order_id'],

      note: json['note'],

      isInternal: json['is_internal'],

      createdAt: json['created_at'],
    );
  }
}