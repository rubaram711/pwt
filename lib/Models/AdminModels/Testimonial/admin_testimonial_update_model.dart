class AdminTestimonialUpdateModel {

  final int? id;

  final int? rating;

  final bool? isActive;

  AdminTestimonialUpdateModel({

    this.id,

    this.rating,

    this.isActive,
  });

  factory AdminTestimonialUpdateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminTestimonialUpdateModel();
    }

    return
      AdminTestimonialUpdateModel(

        id: json['id'],

        rating: json['rating'],

        isActive:
        json['is_active'],
      );
  }
}