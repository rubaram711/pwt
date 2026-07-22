import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../../Backend/Auth/login_api.dart';

/// Brand side-panel shared by Login + Register.
class AuthShell extends StatelessWidget {
  final String headline;
  final String sub;
  final List<String> bullets;
  final Widget form;
  const AuthShell({super.key, required this.headline, required this.sub, required this.bullets, required this.form});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 880;
    return Scaffold(
      backgroundColor: AppColors.soft,
      body: SafeArea(
        child: Row(children: [
          if (wide)
            Expanded(
              child: Container(
                color: AppColors.blue700,
                padding: const EdgeInsets.all(48),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(
                    'assets/images/full_logo_2.png',
                    height: 90,
                    errorBuilder: (_, __, ___) => const Text('PWT', style: TextStyle(color: AppColors.blue700, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 40),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(AppRadius.pill)), child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.water_drop, size: 14, color: Colors.white), SizedBox(width: 6), Text('Pure Water. Pure Life.', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))])),
                  const SizedBox(height: 20),
                  Text(headline, style: AppText.headline(34).copyWith(color: Colors.white)),
                  const SizedBox(height: 14),
                  Text(sub, style: AppText.bodyLg.copyWith(color: Colors.white.withOpacity(.9), height: 1.6)),
                  const SizedBox(height: 26),
                  ...bullets.map((b) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
                        Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), shape: BoxShape.circle), child: const Icon(Icons.check, size: 15, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(b, style: AppText.body.copyWith(color: Colors.white))),
                      ]))),
                ]),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: form),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _acct = 0; // 0 individual, 1 company
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _emailError;
  final _email = TextEditingController();
  final _password = TextEditingController();

  Future<void> _signIn() async {
    final email = _email.text.trim();
    if (!EmailValidator.validate(email)) {
      setState(() => _emailError = 'Please enter a valid email address.');
      return;
    }

    setState(() { _loading = true; _error = null; _emailError = null; });

    final result = await login(
      _email.text.trim(),
      _password.text,
      _acct == 0 ? 'individual' : 'company',
    );

    if (!mounted) return;

    if (result.success && result.data != null) {
      AppState.instance.currentPassword = _password.text;
      await AppState.instance.signIn(result.data!.user, result.data!.token.accessToken);
      if (!mounted) return;

      final args = ModalRoute.of(context)?.settings.arguments;
      final returnRoute = args is Map ? args['returnRoute'] as String? : null;
      final returnArguments = args is Map ? args['returnArguments'] : null;

      if (returnRoute != null) {
        Navigator.of(context).pushNamedAndRemoveUntil(returnRoute, (r) => false, arguments: returnArguments);
      } else {
        final isCompany = result.data!.user.isCompany;
        Navigator.of(context).pushNamedAndRemoveUntil(
          isCompany ? '/companyDashboard' : '/dashboard',
          (r) => false,
        );
      }
    } else {
      setState(() {
        _loading = false;
        _error = result.message ?? result.error ?? 'Login failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final returnRoute = args is Map ? args['returnRoute'] as String? : null;
    final returnArguments = args is Map ? args['returnArguments'] : null;

    return AuthShell(
      headline: 'Welcome back to cleaner water.',
      sub: 'Manage your orders, rentals, maintenance visits and filter reminders — all in one place.',
      bullets: const ['Track every order & delivery', 'Manage rentals & invoices', 'Book maintenance in seconds'],
      form: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextButton.icon(
            onPressed: () => returnRoute != null
                ? Navigator.of(context).pushNamedAndRemoveUntil(returnRoute, (r) => false, arguments: returnArguments)
                : Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(returnRoute != null ? 'Back' : 'Back to home'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
          ),
          const SizedBox(height: 12),
          Text('Sign in to your account', style: AppText.h2),
          const SizedBox(height: 6),
          Text('Enter your details below to access your PWT dashboard.', style: AppText.body.copyWith(color: AppColors.ink500)),
          const SizedBox(height: 20),
          Segmented(options: const ['Personal', 'Business'], icons: const [Icons.person_outline, Icons.apartment], index: _acct, onChanged: (i) => setState(() => _acct = i)),
          const SizedBox(height: 18),
          Text('Email address', style: AppText.label),
          const SizedBox(height: 7),
          TextField(
            controller: _email,
            decoration: InputDecoration(hintText: 'you@email.com', errorText: _emailError),
            onChanged: (_) => setState(() => _emailError = null),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Text('Password', style: AppText.label),
            const Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/forgotPassword', arguments: _email.text.trim()),
                child: Text('Forgot password?', style: AppText.muted.copyWith(color: AppColors.blue700)),
              ),
            ),
          ]),
          const SizedBox(height: 7),
          TextField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: 'Your password',
              suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18), onPressed: () => setState(() => _obscure = !_obscure)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECACA))),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: AppText.body.copyWith(color: const Color(0xFFDC2626), fontSize: 13))),
              ]),
            ),
          ],
          const SizedBox(height: 22),
          PwtButton(_loading ? 'Signing in…' : 'Sign In', fullWidth: true, onPressed: _loading ? null : _signIn),
          const SizedBox(height: 18),
          Center(child: Wrap(children: [
            Text("Don't have an account? ", style: AppText.body.copyWith(color: AppColors.ink500)),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/register', arguments: returnRoute != null ? {'returnRoute': returnRoute, 'returnArguments': returnArguments} : null),
              child: Text('Create one', style: AppText.label.copyWith(color: AppColors.blue700)),
            ),
          ])),
        ]),
      ),
    );
  }
}
