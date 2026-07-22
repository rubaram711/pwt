import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';

import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/product_screen.dart';
import 'screens/solutions_screen.dart';
import 'screens/about_support_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/rfq_screen.dart';
import 'screens/devices_screen.dart';
import 'screens/individual_orders_screen.dart';
import 'screens/orders_maintenance_screen.dart';
import 'screens/invoices_settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/company_screens.dart';
import 'screens/company_orders_screen.dart';
import 'screens/maintenance_company_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
  runApp(const PwtApp());
}

class PwtApp extends StatelessWidget {
  const PwtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWT — Pure Water Technology',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        // ---- Storefront ----
        '/': (_) => const HomeScreen(),
        '/shop': (_) => const ShopScreen(),
        '/product': (_) => const ProductScreen(),
        '/solutions': (_) => const SolutionsScreen(),
        '/about': (_) => const AboutScreen(),
        '/support': (_) => const SupportScreen(),
        '/contact': (_) => const ContactScreen(),
        // ---- Commerce ----
        '/cart': (_) => const CartScreen(),
        '/checkout': (_) => const CheckoutScreen(),
        '/confirmation': (_) => const ConfirmationScreen(),
        // ---- Auth ----
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        // ---- B2B intake ----
        '/rfq': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          final map = args is Map ? args : null;
          return RfqScreen(
            preselectedProductId:   map?['id']   as int?,
            preselectedProductName: map?['name'] as String?,
            preselectedProductCode: map?['code'] as String?,
          );
        },
        '/rfqConfirmation': (_) => const RfqConfirmationScreen(),
        // ---- Individual dashboard ----
        '/dashboard': (_) => const DevicesScreen(),
        '/orders': (_) => const OrdersScreen(),
        '/orderDetail': (_) => const OrderDetailScreen(),
        '/maintenance': (_) => const MaintenanceScreen(),
        '/invoices': (_) => const InvoicesScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const ProfileScreen(),
        // ---- Company dashboard ----
        '/companyDashboard': (_) => const CompanyDevicesScreen(),
        '/companyOrders': (_) => const CompanyOrdersScreen(),
        '/companyMaintenance': (_) => const CompanyMaintenanceScreen(),
        '/scheduleMaintenance': (_) => const ScheduleMaintenanceScreen(),
        '/maintenanceDetails': (_) => const MaintenanceDetailsScreen(),
      },
    );
  }
}
