class UserCountsModel {

  final int? ordersCount;
  final int? supportTicketsCount;
  final int? machinesCount;

  UserCountsModel({
    this.ordersCount,
    this.supportTicketsCount,
    this.machinesCount,
  });

  factory UserCountsModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return UserCountsModel(

      ordersCount:
      json['orders_count'],

      supportTicketsCount:
      json['support_tickets_count'],

      machinesCount:
      json['machines_count'],
    );
  }
}