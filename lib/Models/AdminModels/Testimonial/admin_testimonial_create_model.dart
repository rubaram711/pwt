class AdminTestimonialCreateModel {

  final int? id;

  final String? name;

  final bool? isActive;

  AdminTestimonialCreateModel({

    this.id,

    this.name,

    this.isActive,
  });

  factory AdminTestimonialCreateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminTestimonialCreateModel();
    }

    return
      AdminTestimonialCreateModel(

        id: json['id'],

        name: json['name'],

        isActive:
        json['is_active'],
      );
  }
}