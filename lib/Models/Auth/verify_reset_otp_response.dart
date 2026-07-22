class VerifyResetOtpResponse {
  final String expiresAt;
  final String devToken;

  VerifyResetOtpResponse({
    required this.expiresAt,
    required this.devToken,
  });

  factory VerifyResetOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResetOtpResponse(
      expiresAt: json['expires_at'] ?? '',
      devToken: json['dev_token'] ?? '',
    );
  }
}
