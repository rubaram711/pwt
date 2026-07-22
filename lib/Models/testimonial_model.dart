class TestimonialModel {

  final int id;

  final String name;

  final String? role;

  final String? company;

  final int rating;

  final String quote;

  final String? avatarUrl;

  final int displayOrder;

  TestimonialModel({

    required this.id,

    required this.name,

    this.role,

    this.company,

    required this.rating,

    required this.quote,

    this.avatarUrl,

    required this.displayOrder,
  });

  factory TestimonialModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return TestimonialModel(

      id: json['id'] ?? 0,

      name: json['name'] ?? '',

      role: json['role'],

      company: json['company'],

      rating: json['rating'] ?? 0,

      quote: json['quote'] ?? '',

      avatarUrl:
      json['avatar_url'],

      displayOrder:
      json['display_order'] ?? 0,
    );
  }
}