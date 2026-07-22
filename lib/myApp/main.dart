// PWT customer app — entry point. Loads embedded fonts, sets up state, and
// routes between the top-level destinations (mirrors the prototype's <App>).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/embedded_fonts.dart';
import 'core/theme.dart';
import 'state/app_state.dart';
import 'state/cart_state.dart';
import 'screens/business_screens.dart';
import 'screens/individual_screens.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register any embedded base64 fonts (no-op until the slots are filled).
  await loadEmbeddedFonts();
  runApp(const PwtApp());
}

class PwtApp extends StatelessWidget {
  const PwtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        // A single cart instance shared across the active session. Only one
        // role (individual/business) is active at a time, mirroring the
        // prototype's per-role carts.
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: Consumer<AppState>(
        builder: (context, app, _) {
          return MaterialApp(
            title: 'PWT',
            debugShowCheckedModeBanner: false,
            theme: buildPwtTheme(arabic: app.isArabic),
            // RTL/LTR is driven by the chosen language. (Add
            // flutter_localizations + GlobalMaterialLocalizations for full
            // Arabic Material strings when wiring real i18n.)
            builder: (context, child) => Directionality(
              textDirection: app.dir,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const _RootRouter(),
          );
        },
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final Widget screen = switch (app.route) {
      AppRoute.welcome => WelcomeScreen(
          key: const ValueKey('welcome'),
          onContinue: () => app.go(AppRoute.login),
          onSignUp: () => app.go(AppRoute.signup),
        ),
      AppRoute.login => LoginScreen(
          key: const ValueKey('login'),
          onLogin: app.login,
          onBack: () => app.go(AppRoute.welcome),
        ),
      AppRoute.signup => SignupScreen(
          key: const ValueKey('signup'),
          onBack: () => app.go(AppRoute.welcome),
          onComplete: app.signup,
        ),
      AppRoute.onboarding => OnboardingScreen(
          key: const ValueKey('onboarding'),
          mode: app.signupMode,
          onDone: app.finishOnboarding,
        ),
      AppRoute.individual => IndividualShell(
          key: const ValueKey('individual'),
          onLogout: app.logout,
          isNew: app.isNew,
        ),
      AppRoute.business => BusinessShell(
          key: const ValueKey('business'),
          onLogout: app.logout,
          isNew: app.isNew,
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: screen,
    );
  }
}
