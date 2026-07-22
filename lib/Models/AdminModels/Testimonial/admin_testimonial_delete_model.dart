class AdminTestimonialDeleteModel {

  final int? id;

  final String? deletedAt;

  AdminTestimonialDeleteModel({

    this.id,

    this.deletedAt,
  });

  factory AdminTestimonialDeleteModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminTestimonialDeleteModel();
    }

    return
      AdminTestimonialDeleteModel(

        id: json['id'],

        deletedAt:
        json['deleted_at'],
      );
  }
}