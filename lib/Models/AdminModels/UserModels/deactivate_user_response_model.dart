class DeactivateUserResponseModel {

  final int? id;

  final bool? isActive;

  final int? tokensRevoked;

  final bool? noOp;

  DeactivateUserResponseModel({
    this.id,
    this.isActive,
    this.tokensRevoked,
    this.noOp,
  });

  factory DeactivateUserResponseModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return DeactivateUserResponseModel(

      id: json['id'],

      isActive:
      json['is_active'],

      tokensRevoked:
      json['tokens_revoked'],

      noOp:
      json['no_op'],
    );
  }
}