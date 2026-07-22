class TokenModel {
  final String accessToken;
  final String tokenType;
  final String expiresAt;
  final List<String> abilities;

  TokenModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
    required this.abilities,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      abilities: List<String>.from(json['abilities'] ?? []),
    );
  }
}