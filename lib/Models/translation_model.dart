class TranslationModel {

  final String? en;

  final String? ar;

  TranslationModel({
    this.en,
    this.ar,
  });

  factory TranslationModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return TranslationModel();
    }

    return TranslationModel(

      en: json['en'],

      ar: json['ar'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'en': en,

      'ar': ar,
    };
  }
}