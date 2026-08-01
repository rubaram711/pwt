// Platform shim. On Flutter Web this exports the real embedded Stripe Card
// Element widget (dart:html/dart:js/dart:ui_web). On every other platform
// (Android/iOS) it exports a stub with the same public API
// (StripeCardFields, StripeCardFieldsState) that throws UnsupportedError
// if actually built. This guarantees the real, browser-only implementation
// is never compiled outside a web build target — see
// stripe_card_field_html.dart / stripe_card_field_stub.dart.
export 'stripe_card_field_stub.dart' if (dart.library.html) 'stripe_card_field_html.dart';
