class SocialLinksModel {

  final String? facebook;

  final String? instagram;

  final String? linkedin;

  SocialLinksModel({
    this.facebook,
    this.instagram,
    this.linkedin,
  });

  factory SocialLinksModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return SocialLinksModel();
    }

    return SocialLinksModel(

      facebook: json['facebook'],

      instagram: json['instagram'],

      linkedin: json['linkedin'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'facebook': facebook,

      'instagram': instagram,

      'linkedin': linkedin,
    };
  }
}