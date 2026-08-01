// Non-web stub for the embedded Stripe Card Element widget. Selected
// automatically by stripe_card_field.dart's conditional export whenever
// dart.library.html is NOT available (Android/iOS). Exists purely so a
// non-web compile target that (whether directly or through a
// misconfigured entry point) reaches this import never fails with
// "dart:html/dart:js/dart:ui_web unsupported" — this file compiles
// cleanly on every platform. It only throws if actually built or used,
// since the real widget relies on browser-only platform views.
import 'package:flutter/material.dart';

import '../utils/stripe_web.dart';

class StripeCardFields extends StatefulWidget {
  const StripeCardFields({super.key, required this.publishableKey, this.onChange});
  final String publishableKey;
  final void Function(bool complete, String? error)? onChange;

  @override
  State<StripeCardFields> createState() => StripeCardFieldsState();
}

class StripeCardFieldsState extends State<StripeCardFields> {
  /// Confirms the PaymentIntent identified by [clientSecret] using the card
  /// details currently entered in this field.
  Future<StripeCardResult> confirmPayment(String clientSecret) {
    throw UnsupportedError('StripeCardFields is only available on Flutter Web.');
  }

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError('StripeCardFields is only available on Flutter Web.');
  }
}
