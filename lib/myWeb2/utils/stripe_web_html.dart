// Thin dart:js interop wrapper around Stripe.js (loaded via <script> in
// web/index.html). flutter_stripe has no real Flutter-Web implementation,
// so on web we talk to Stripe.js directly and mount its Card Elements into
// HtmlElementViews — this is the web equivalent of the native PaymentSheet.
//
// This is the real, web-only implementation. It is only ever compiled when
// dart.library.html is available — see stripe_web.dart's conditional
// export, which is what every other file in the project should import.
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

class StripeCardResult {
  StripeCardResult({required this.success, this.errorMessage, this.paymentIntentStatus});
  final bool success;
  final String? errorMessage;
  final String? paymentIntentStatus;
}

/// Result of tokenizing a card into a Stripe PaymentMethod (pm_xxxxx) via
/// `stripe.createPaymentMethod` — no charge happens here, this only turns
/// the card the user typed into Stripe's Card Element into a reusable
/// token. [rawJson] is Stripe's own JSON response, kept as-is for
/// inspection/logging.
class StripePaymentMethodResult {
  StripePaymentMethodResult({
    required this.success,
    this.errorMessage,
    this.paymentMethodId,
    this.brand,
    this.last4,
    this.expMonth,
    this.expYear,
    this.rawJson,
  });
  final bool success;
  final String? errorMessage;
  final String? paymentMethodId;
  final String? brand;
  final String? last4;
  final String? expMonth;
  final String? expYear;
  final String? rawJson;
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

  /// Waits for the global `Stripe` constructor from the <script
  /// src="https://js.stripe.com/v3/"> tag in web/index.html to become
  /// available. That script loads in parallel with the Flutter engine, so
  /// on a slow network the very first frame can render — and try to mount
  /// the card field — before it's ready. Polling here (instead of assuming
  /// it's already loaded) avoids a spurious "Stripe.js did not load" error
  /// and an unmounted, unclickable card field.
  static Future<void> waitUntilLoaded({Duration timeout = const Duration(seconds: 10)}) async {
    final deadline = DateTime.now().add(timeout);
    while (js.context['Stripe'] == null) {
      if (DateTime.now().isAfter(deadline)) {
        throw StateError('Stripe.js did not load — check the <script src="https://js.stripe.com/v3/"> tag in web/index.html.');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

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

  /// Confirms [clientSecret] using the given card Element — tokenizes and
  /// charges the entered card in one step.
  Future<StripeCardResult> confirmCardPayment(String clientSecret, js.JsObject card) {
    return _confirmCardPayment(clientSecret, {
      'payment_method': {'card': card},
    });
  }

  /// Confirms [clientSecret] using an already-tokenized PaymentMethod
  /// (`pm_xxxxx`) — for a card tokenized up front via [createPaymentMethod]
  /// (and already handed to the backend), so nothing is re-tokenized here.
  Future<StripeCardResult> confirmCardPaymentWithMethodId(String clientSecret, String paymentMethodId) {
    return _confirmCardPayment(clientSecret, {'payment_method': paymentMethodId});
  }

  Future<StripeCardResult> _confirmCardPayment(String clientSecret, Map<String, dynamic> optionsMap) {
    final completer = Completer<StripeCardResult>();
    final options = js.JsObject.jsify(optionsMap);
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

  /// Tokenizes the given card Element into a Stripe PaymentMethod
  /// (`pm_xxxxx`) via `stripe.createPaymentMethod` — nothing is charged
  /// here. The full 16-digit number/CVV/expiry never leave Stripe's own
  /// iframe; this only asks Stripe for the reusable token + safe-to-store
  /// display metadata (brand/last4/expiry) for that card.
  Future<StripePaymentMethodResult> createPaymentMethod(js.JsObject card, {String? cardholderName}) {
    final completer = Completer<StripePaymentMethodResult>();
    final options = js.JsObject.jsify({
      'type': 'card',
      'card': card,
      if (cardholderName != null && cardholderName.isNotEmpty)
        'billing_details': {'name': cardholderName},
    });
    final promise = _stripe.callMethod('createPaymentMethod', [options]) as js.JsObject;
    promise.callMethod('then', [
      js.allowInterop((dynamic result) {
        final r = result as js.JsObject;
        final error = r['error'];
        if (error != null) {
          final msg = (error as js.JsObject)['message'] as String?;
          completer.complete(StripePaymentMethodResult(success: false, errorMessage: msg ?? 'Could not save this card. Please try again.'));
          return;
        }
        final pm = r['paymentMethod'] as js.JsObject;
        final cardInfo = pm['card'] as js.JsObject?;
        final json = js.context['JSON'] as js.JsObject;
        completer.complete(StripePaymentMethodResult(
          success: true,
          paymentMethodId: pm['id'] as String?,
          brand: cardInfo?['brand'] as String?,
          last4: cardInfo?['last4'] as String?,
          expMonth: cardInfo?['exp_month']?.toString(),
          expYear: cardInfo?['exp_year']?.toString(),
          rawJson: json.callMethod('stringify', [pm, null, 2]) as String,
        ));
      }),
    ]);
    promise.callMethod('catch', [
      js.allowInterop((dynamic _) {
        completer.complete(StripePaymentMethodResult(success: false, errorMessage: 'Could not save this card. Please try again.'));
      }),
    ]);
    return completer.future;
  }
}
