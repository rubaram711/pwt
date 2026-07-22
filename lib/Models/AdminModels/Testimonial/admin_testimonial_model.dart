import '../../translation_model.dart';

class AdminTestimonialModel {

  final int? id;

  final String? name;

  final String? role;

  final String? company;

  final int? rating;

  final TranslationModel? quote;

  final String? avatarUrl;

  final int? displayOrder;

  final bool? isActive;

  final String? deletedAt;

  AdminTestimonialModel({

    this.id,

    this.name,

    this.role,

    this.company,

    this.rating,

    this.quote,

    this.avatarUrl,

    this.displayOrder,

    this.isActive,

    this.deletedAt,
  });

  factory AdminTestimonialModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminTestimonialModel();
    }

    return AdminTestimonialModel(

      id: json['id'],

      name: json['name'],

      role: json['role'],

      company: json['company'],

      rating: json['rating'],

      quote:
      TranslationModel.fromJson(
        json['quote'],
      ),

      avatarUrl:
      json['avatar_url'],

      displayOrder:
      json['display_order'],

      isActive:
      json['is_active'],

      deletedAt:
      json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'name': name,

      'role': role,

      'company': company,

      'rating': rating,

      'quote': quote?.toJson(),

      'avatar_url': avatarUrl,

      'display_order':
      displayOrder,

      'is_active': isActive,

      'deleted_at': deletedAt,
    };
  }
}