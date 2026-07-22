class SendOtpResponse {
  final String message;
  final String channel;
  final String to;
  final String expiresIn;
  final String expiresAt;
  final DebugCode? debug;

  SendOtpResponse({
    required this.message,
    required this.channel,
    required this.to,
    required this.expiresIn,
    required this.expiresAt,
    this.debug,
  });

  factory SendOtpResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return SendOtpResponse(
      message: json['message'] ?? '',
      channel: json['channel'] ?? '',
      to: json['to'] ?? '',
      expiresIn: json['expires_in'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      debug: json['debug'] != null
          ? DebugCode.fromJson(json['debug'])
          : null,
    );
  }
}

class DebugCode {
  final int value;
  final String channelUsed;

  DebugCode({
    required this.value,
    required this.channelUsed,
  });

  factory DebugCode.fromJson(
      Map<String, dynamic> json,
      ) {
    return DebugCode(
      value: json['otp'] ?? json['code'] ?? 0,
      channelUsed: json['channel_used'] ?? '',
    );
  }
}