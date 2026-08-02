// Non-web stub for the Stripe.js wrapper. Selected automatically by
// stripe_web.dart's conditional export whenever dart.library.html is NOT
// available (Android/iOS). Exists purely so a non-web compile target that
// (whether directly or through a misconfigured entry point) reaches this
// import never fails with "dart:html/dart:js unsupported" — this file
// compiles cleanly on every platform and only throws if actually used,
// since Stripe.js itself only exists in a browser.
class StripeCardResult {
  StripeCardResult({required this.success, this.errorMessage, this.paymentIntentStatus});
  final bool success;
  final String? errorMessage;
  final String? paymentIntentStatus;
}

class StripeJs {
  StripeJs._();

  static Future<void> waitUntilLoaded({Duration timeout = const Duration(seconds: 10)}) {
    throw UnsupportedError('StripeJs is only available on Flutter Web.');
  }

  static StripeJs init(String publishableKey) {
    throw UnsupportedError('StripeJs is only available on Flutter Web.');
  }

  dynamic createElement(String type) {
    throw UnsupportedError('StripeJs is only available on Flutter Web.');
  }

  void mount(dynamic element, dynamic container) {
    throw UnsupportedError('StripeJs is only available on Flutter Web.');
  }

  void unmount(dynamic element) {
    throw UnsupportedError('StripeJs is only available on Flutter Web.');
  }

  void onChange(dynamic element, void Function(bool complete, String? errorMessage) cb) {
    throw UnsupportedError('StripeJs is only available on Flutter Web.');
  }

  Future<StripeCardResult> confirmCardPayment(String clientSecret, dynamic card) {
    throw UnsupportedError('StripeJs is only available on Flutter Web.');
  }
}
