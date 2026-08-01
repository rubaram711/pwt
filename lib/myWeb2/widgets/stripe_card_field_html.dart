// Embedded Stripe card field for myWeb2 checkout — mounts Stripe.js's Card
// Element into the page via a registered platform view. This is the web
// equivalent of the native PaymentSheet used in myApp.
//
// This is the real, web-only implementation. It is only ever compiled when
// dart.library.html is available — see stripe_card_field.dart's
// conditional export, which is what every other file in the project
// should import.
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../utils/stripe_web.dart';

class StripeCardFields extends StatefulWidget {
  const StripeCardFields({super.key, required this.publishableKey, this.onChange});
  final String publishableKey;
  final void Function(bool complete, String? error)? onChange;

  @override
  State<StripeCardFields> createState() => StripeCardFieldsState();
}

class StripeCardFieldsState extends State<StripeCardFields> {
  late final String _viewType = 'stripe-card-element-${identityHashCode(this)}';
  late final html.DivElement _container = html.DivElement()
    ..style.width = '100%'
    ..style.height = '100%';
  js.JsObject? _card;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) => _container);
    WidgetsBinding.instance.addPostFrameCallback((_) => _mount());
  }

  void _mount() {
    if (!mounted) return;
    final stripe = StripeJs.init(widget.publishableKey);
    final card = stripe.createElement('card');
    stripe.mount(card, _container);
    stripe.onChange(card, (complete, error) {
      widget.onChange?.call(complete, error);
      if (mounted) setState(() => _hasError = error != null);
    });
    _card = card;
  }

  /// Confirms the PaymentIntent identified by [clientSecret] using the card
  /// details currently entered in this field.
  Future<StripeCardResult> confirmPayment(String clientSecret) {
    final card = _card;
    if (card == null) {
      return Future.value(StripeCardResult(success: false, errorMessage: 'Card field not ready yet. Please try again.'));
    }
    return StripeJs.init(widget.publishableKey).confirmCardPayment(clientSecret, card);
  }

  @override
  void dispose() {
    final card = _card;
    if (card != null) StripeJs.init(widget.publishableKey).unmount(card);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _hasError ? AppColors.danger : AppColors.line),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          color: Colors.white,
        ),
        child: SizedBox.expand(child: HtmlElementView(viewType: _viewType)),
      ),
    );
  }
}
