// App-level state: language, top-level route, signup flow. Mirrors the
// useState wiring in the prototype's <App> component. Uses ChangeNotifier so
// any widget can `context.watch<AppState>()`.

import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../../myWeb2/state/app_state.dart' as web;

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

  String get lang => _lang;
  AppRoute get route => _route;
  AccountKind get signupMode => _signupMode;
  bool get isNew => _isNew;

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

  // ── Flow handlers (1:1 with the prototype) ──

  /// Existing user logs in → straight to their shell.
  void login(AccountKind mode) {
    _isNew = false;
    _route = mode == AccountKind.business ? AppRoute.business : AppRoute.individual;
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
