// Thin dart:js interop wrapper around Stripe.js (loaded via <script> in
// web/index.html). flutter_stripe has no real Flutter-Web implementation,
// so on web we talk to Stripe.js directly and mount its Card Elements into
// HtmlElementViews — this is the web equivalent of the native PaymentSheet.
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

class StripeCardResult {
  StripeCardResult({required this.success, this.errorMessage, this.paymentIntentStatus});
  final bool success;
  final String? errorMessage;
  final String? paymentIntentStatus;
}

const _kElementStyle = {
  'style': {
    'base': {
      'fontSize': '14.5px',
      'color': '#0B1220',
      'fontFamily': 'Arial, sans-serif',
      '::placeholder': {'color': '#9CA3AF'},
    },
    'invalid': {'color': '#DC2626'},
  },
};

class StripeJs {
  StripeJs._(this._stripe);
  final js.JsObject _stripe;

  static StripeJs? _instance;

  static StripeJs init(String publishableKey) {
    final existing = _instance;
    if (existing != null) return existing;
    final ctor = js.context['Stripe'];
    if (ctor == null) {
      throw StateError('Stripe.js did not load — check the <script src="https://js.stripe.com/v3/"> tag in web/index.html.');
    }
    final stripe = js.JsObject(ctor as js.JsFunction, [publishableKey]);
    final created = StripeJs._(stripe);
    _instance = created;
    return created;
  }

  /// [type] is normally 'card'. A *fresh* Elements group is created per
  /// call — Stripe only allows one Element of a given type per group, and
  /// this method (unlike a cached/shared group) may legitimately be called
  /// again whenever the card field remounts (hot reload, revisiting
  /// checkout, etc.), so reusing a group here would throw
  /// "Can only create one Element of type card."
  js.JsObject createElement(String type) {
    final elements = _stripe.callMethod('elements', []) as js.JsObject;
    final options = js.JsObject.jsify(_kElementStyle);
    return elements.callMethod('create', [type, options]) as js.JsObject;
  }

  void mount(js.JsObject element, html.Element container) {
    element.callMethod('mount', [container]);
  }

  void unmount(js.JsObject element) {
    try {
      element.callMethod('unmount', []);
    } catch (_) {}
  }

  void onChange(js.JsObject element, void Function(bool complete, String? errorMessage) cb) {
    element.callMethod('on', [
      'change',
      js.allowInterop((dynamic event) {
        final e = event as js.JsObject;
        final complete = e['complete'] == true;
        final error = e['error'];
        String? msg;
        if (error != null) msg = (error as js.JsObject)['message'] as String?;
        cb(complete, msg);
      }),
    ]);
  }

  /// Confirms [clientSecret] using the given card Element.
  Future<StripeCardResult> confirmCardPayment(String clientSecret, js.JsObject card) {
    final completer = Completer<StripeCardResult>();
    final options = js.JsObject.jsify({
      'payment_method': {'card': card},
    });
    final promise = _stripe.callMethod('confirmCardPayment', [clientSecret, options]) as js.JsObject;
    promise.callMethod('then', [
      js.allowInterop((dynamic result) {
        final r = result as js.JsObject;
        final error = r['error'];
        if (error != null) {
          final msg = (error as js.JsObject)['message'] as String?;
          completer.complete(StripeCardResult(success: false, errorMessage: msg ?? 'Payment failed. Please try again.'));
          return;
        }
        final paymentIntent = r['paymentIntent'] as js.JsObject?;
        final status = paymentIntent?['status'] as String?;
        completer.complete(StripeCardResult(
          success: status == 'succeeded',
          paymentIntentStatus: status,
          errorMessage: status == 'succeeded' ? null : 'Payment status: ${status ?? 'unknown'}',
        ));
      }),
    ]);
    promise.callMethod('catch', [
      js.allowInterop((dynamic _) {
        completer.complete(StripeCardResult(success: false, errorMessage: 'Payment failed. Please try again.'));
      }),
    ]);
    return completer.future;
  }
}
