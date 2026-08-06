///test
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'test/core/embedded_fonts.dart';
// import 'test/core/theme.dart';
// import 'test/state/app_state.dart';
// import 'test/state/cart_state.dart';
// import 'test/screens/business_screens.dart';
// import 'test/screens/individual_screens.dart';
// import 'test/screens/login_screen.dart';
// import 'test/screens/signup_screen.dart';
// import 'test/screens/welcome_screen.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Register any embedded base64 fonts (no-op until the slots are filled).
//   await loadEmbeddedFonts();
//   runApp(const PwtApp());
// }
//
// class PwtApp extends StatelessWidget {
//   const PwtApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AppState()),
//         // A single cart instance shared across the active session. Only one
//         // role (individual/business) is active at a time, mirroring the
//         // prototype's per-role carts.
//         ChangeNotifierProvider(create: (_) => CartState()),
//       ],
//       child: Consumer<AppState>(
//         builder: (context, app, _) {
//           return MaterialApp(
//             title: 'PWT',
//             debugShowCheckedModeBanner: false,
//             theme: buildPwtTheme(arabic: app.isArabic),
//             // RTL/LTR is driven by the chosen language. (Add
//             // flutter_localizations + GlobalMaterialLocalizations for full
//             // Arabic Material strings when wiring real i18n.)
//             builder: (context, child) => Directionality(
//               textDirection: app.dir,
//               child: child ?? const SizedBox.shrink(),
//             ),
//             home: const _RootRouter(),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _RootRouter extends StatelessWidget {
//   const _RootRouter();
//
//   @override
//   Widget build(BuildContext context) {
//     final app = context.watch<AppState>();
//
//     final Widget screen = switch (app.route) {
//       AppRoute.welcome => WelcomeScreen(
//         key: const ValueKey('welcome'),
//         onContinue: () => app.go(AppRoute.login),
//         onSignUp: () => app.go(AppRoute.signup),
//       ),
//       AppRoute.login => LoginScreen(
//         key: const ValueKey('login'),
//         onLogin: app.login,
//         onBack: () => app.go(AppRoute.welcome),
//       ),
//       AppRoute.signup => SignupScreen(
//         key: const ValueKey('signup'),
//         onBack: () => app.go(AppRoute.welcome),
//         onComplete: app.signup,
//       ),
//       AppRoute.onboarding => OnboardingScreen(
//         key: const ValueKey('onboarding'),
//         mode: app.signupMode,
//         onDone: app.finishOnboarding,
//       ),
//       AppRoute.individual => IndividualShell(
//         key: const ValueKey('individual'),
//         onLogout: app.logout,
//         isNew: app.isNew,
//         forceEmpty: app.forceEmpty,
//       ),
//       AppRoute.business => BusinessShell(
//         key: const ValueKey('business'),
//         onLogout: app.logout,
//         isNew: app.isNew,
//         forceEmpty: app.forceEmpty,
//       ),
//     };
//
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 280),
//       switchInCurve: Curves.easeOutCubic,
//       transitionBuilder: (child, anim) => FadeTransition(
//         opacity: anim,
//         child: SlideTransition(
//           position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(anim),
//           child: child,
//         ),
//       ),
//       child: screen,
//     );
//   }
// }


///

///mobile
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'const/stripe_config.dart';
import 'myApp/core/embedded_fonts.dart';
import 'myApp/core/theme.dart';
import 'myApp/state/app_state.dart';
import 'myApp/state/cart_state.dart';
import 'myApp/screens/business_screens.dart';
import 'myApp/screens/individual_screens.dart';
import 'myApp/screens/login_screen.dart';
import 'myApp/screens/signup_screen.dart';
import 'myApp/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register any embedded base64 fonts (no-op until the slots are filled).
  await loadEmbeddedFonts();

  Stripe.publishableKey = kStripePublishableKey;
  await Stripe.instance.applySettings();
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
        onGuest: () => app.continueAsGuest(),
      ),
      AppRoute.login => LoginScreen(
        key: const ValueKey('login'),
        onLogin: app.login,
        onBack: () => app.go(app.pendingProduct != null ? AppRoute.individual : AppRoute.welcome),
        initialEmail: app.prefillEmail,
        initialPassword: app.prefillPassword,
        initialMode: app.prefillMode,
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
///

///
//User name	Password	Console sign-in URL
// pwt-admin	Admin#PWTmT#123	https://724553038958.signin.aws.amazon.com/console
///
///web
// import 'package:flutter/material.dart';
// import 'myWeb2/theme/app_theme.dart';
// import 'myWeb2/state/app_state.dart';
//
// import 'myWeb2/screens/home_screen.dart';
// import 'myWeb2/screens/shop_screen.dart';
// import 'myWeb2/screens/product_screen.dart';
// import 'myWeb2/screens/solutions_screen.dart';
// import 'myWeb2/screens/about_support_screen.dart';
// import 'myWeb2/screens/contact_screen.dart';
// import 'myWeb2/screens/cart_screen.dart';
// import 'myWeb2/screens/checkout_screen.dart';
// import 'myWeb2/screens/confirmation_screen.dart';
// import 'myWeb2/screens/login_screen.dart';
// import 'myWeb2/screens/register_screen.dart';
// import 'myWeb2/screens/forgot_password_screen.dart';
// import 'myWeb2/screens/rfq_screen.dart';
// import 'myWeb2/screens/devices_screen.dart';
// import 'myWeb2/screens/individual_orders_screen.dart';
// import 'myWeb2/screens/orders_maintenance_screen.dart';
// import 'myWeb2/screens/invoices_settings_screen.dart';
// import 'myWeb2/screens/profile_screen.dart';
// import 'myWeb2/screens/company_screens.dart';
// import 'myWeb2/screens/company_orders_screen.dart';
// import 'myWeb2/screens/maintenance_company_screen.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await AppState.instance.load();
//   runApp(const PwtApp());
// }
//
// class PwtApp extends StatelessWidget {
//   const PwtApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PWT — Pure Water Technology',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.light(),
//       initialRoute: '/',
//       routes: {
//         // ---- Storefront ----
//         '/': (_) => const HomeScreen(),
//         '/shop': (_) => const ShopScreen(),
//         '/product': (_) => const ProductScreen(),
//         '/solutions': (_) => const SolutionsScreen(),
//         '/about': (_) => const AboutScreen(),
//         '/support': (_) => const SupportScreen(),
//         '/contact': (_) => const ContactScreen(),
//         // ---- Commerce ----
//         '/cart': (_) => const CartScreen(),
//         '/checkout': (_) => const CheckoutScreen(),
//         '/confirmation': (_) => const ConfirmationScreen(),
//         // ---- Auth ----
//         '/login': (_) => const LoginScreen(),
//         '/register': (_) => const RegisterScreen(),
//         '/forgotPassword': (_) => const ForgotPasswordScreen(),
//         // ---- B2B intake ----
//         '/rfq': (_) => const RfqScreen(),
//         '/rfqConfirmation': (_) => const RfqConfirmationScreen(),
//         // ---- Individual dashboard ----
//         '/dashboard': (_) => const DevicesScreen(),
//         '/deviceDetail': (_) => const DeviceDetailScreen(),
//         '/orders': (_) => const OrdersScreen(),
//         '/orderDetail': (_) => const OrderDetailScreen(),
//         '/maintenance': (_) => const MaintenanceScreen(),
//         '/invoices': (_) => const InvoicesScreen(),
//         '/settings': (_) => const SettingsScreen(),
//         '/profile': (_) => const ProfileScreen(),
//         // ---- Company dashboard ----
//         '/companyDashboard': (_) => const CompanyDevicesScreen(),
//         '/companyOrders': (_) => const CompanyOrdersScreen(),
//         '/companyMaintenance': (_) => const CompanyMaintenanceScreen(),
//         '/scheduleMaintenance': (_) => const ScheduleMaintenanceScreen(),
//         '/maintenanceDetails': (_) => const MaintenanceDetailsScreen(),
//       },
//     );
//   }
// }
//



///
//////////////////////////////////////

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
//
// import 'myWeb/app.dart';
// import 'myWeb/state/app_state.dart';
//
//
// /// Browser entry point.
// ///
// /// Mirrors the React build's startup order:
// ///   1. ensureInitialized + load persisted state
// ///   2. seed demo data (idempotent)
// ///   3. mount the SPA shell
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//
//   SystemChrome.setPreferredOrientations(const [
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);
//
//   // Load theme + language + auth + cart from SharedPreferences.
//   await AppState.instance.load();
//   await AppState.instance.initialize();
//
//   runApp(const PwtApp());
// }
