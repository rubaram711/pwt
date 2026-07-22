class LoginOtpResponse {
  final String otpId;
  final String expiresAt;
  final String? devOtp;

  LoginOtpResponse({
    required this.otpId,
    required this.expiresAt,
    this.devOtp,
  });

  factory LoginOtpResponse.fromJson(Map<String, dynamic> json) {
    return LoginOtpResponse(
      otpId: json['otp_id'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      devOtp: json['dev_otp'],
    );
  }
}