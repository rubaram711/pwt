// App-level state: language, top-level route, signup flow. Mirrors the
// useState wiring in the prototype's <App> component. Uses ChangeNotifier so
// any widget can `context.watch<AppState>()`.

import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Models/Products/products_model.dart';

/// Top-level destinations, matching the prototype's `route` values.
enum AppRoute { welcome, login, signup, onboarding, individual, business }

class AppState extends ChangeNotifier {
  AppState() {
    web.AppState.instance.load().then((_) {
      final u = web.AppState.instance.user;
      if (u != null) {
        _route = u.isCompany ? AppRoute.business : AppRoute.individual;
        notifyListeners();
      }
    });
  }

  String _lang = 'en';
  AppRoute _route = AppRoute.welcome;
  AccountKind _signupMode = AccountKind.individual;
  bool _isNew = false;
  String? _prefillEmail;
  String? _prefillPassword;
  AccountKind? _prefillMode;
  ProductModel? _pendingProduct;

  String get lang => _lang;
  AppRoute get route => _route;
  AccountKind get signupMode => _signupMode;
  bool get isNew => _isNew;
  String? get prefillEmail => _prefillEmail;
  String? get prefillPassword => _prefillPassword;
  AccountKind? get prefillMode => _prefillMode;
  ProductModel? get pendingProduct => _pendingProduct;

  bool get isArabic => _lang == 'ar';
  TextDirection get dir => _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  void setLang(String lang) {
    if (lang == _lang) return;
    _lang = lang;
    notifyListeners();
  }

  void toggleLang() => setLang(_lang == 'en' ? 'ar' : 'en');

  void go(AppRoute route) {
    _route = route;
    notifyListeners();
  }

  /// Signup hit "email already registered" → send the user to login with
  /// what they just typed carried over, so they don't have to retype it.
  void goToLoginWithCredentials({String? email, String? password, AccountKind? mode}) {
    _prefillEmail = email;
    _prefillPassword = password;
    _prefillMode = mode;
    _route = AppRoute.login;
    notifyListeners();
  }

  /// Called by LoginScreen once it has copied the prefill into its own
  /// controllers, so a later unrelated visit to login doesn't reuse it.
  void clearLoginPrefill() {
    _prefillEmail = null;
    _prefillPassword = null;
    _prefillMode = null;
  }

  /// Guest tried to buy/rent/request a quote on a product's detail page —
  /// send them to login, remembering which product to reopen afterwards
  /// (on success or on going back), so they don't lose their place.
  void goToLoginForProduct(ProductModel product) {
    _pendingProduct = product;
    _route = AppRoute.login;
    notifyListeners();
  }

  /// Consumed by the shell that reopens [pendingProduct]'s detail page.
  void clearPendingProduct() {
    _pendingProduct = null;
  }

  // ── Flow handlers (1:1 with the prototype) ──

  /// Existing user logs in → straight to their shell.
  void login(AccountKind mode) {
    _isNew = false;
    _route = mode == AccountKind.business ? AppRoute.business : AppRoute.individual;
    notifyListeners();
  }

  /// "Continue as guest" from the welcome screen — lands in the individual
  /// shell with no account signed in; the shell itself checks
  /// `web.AppState.instance.user` to render the reduced Home+Shop guest nav.
  void continueAsGuest() {
    _isNew = false;
    _route = AppRoute.individual;
    notifyListeners();
  }

  /// Account-type chosen on signup → onboarding carousel.
  void signup(AccountKind mode) {
    _signupMode = mode;
    _route = AppRoute.onboarding;
    notifyListeners();
  }

  /// Onboarding finished → land in the chosen shell flagged as new.
  void finishOnboarding() {
    _isNew = true;
    _route = _signupMode == AccountKind.business ? AppRoute.business : AppRoute.individual;
    notifyListeners();
  }

  void logout() {
    _isNew = false;
    _route = AppRoute.welcome;
    web.AppState.instance.signOut();
    notifyListeners();
  }

  /// Used by the dev "View" switch (prototype Tweaks panel).
  void switchView(AccountKind kind) {
    _isNew = false;
    _route = kind == AccountKind.business ? AppRoute.business : AppRoute.individual;
    notifyListeners();
  }
}
