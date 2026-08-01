// Platform shim. On Flutter Web this exports the real Stripe.js wrapper
// (dart:html/dart:js). On every other platform (Android/iOS) it exports a
// stub with the same public API (StripeJs, StripeCardResult) that throws
// UnsupportedError if actually used. This guarantees the real,
// browser-only implementation is never compiled outside a web build target
// — see stripe_web_html.dart / stripe_web_stub.dart.
export 'stripe_web_stub.dart' if (dart.library.html) 'stripe_web_html.dart';
