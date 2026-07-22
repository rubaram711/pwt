// Login — account-mode tabs + email/password. Ported from proto/login.jsx.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/form_field.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Backend/Auth/login_api.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin, required this.onBack});
  final ValueChanged<AccountKind> onLogin;
  final VoidCallback onBack;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AccountKind _mode = AccountKind.individual;
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPw = false;
  bool _loading = false;
  String? _error;

  void _setMode(AccountKind m) => setState(() => _mode = m);

  Future<void> _signIn() async {
    if (!EmailValidator.validate(_email.text.trim())) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final accountType = _mode == AccountKind.business ? 'company' : 'individual';
    final res = await login(_email.text.trim(), _password.text, accountType);
    if (!mounted) return;
    if (res.success && res.data != null) {
      await web.AppState.instance.signIn(
        res.data!.user,
        res.data!.token.accessToken,
        password: _password.text,
        accountType: accountType,
      );
      widget.onLogin(_mode);
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Login failed. Please check your credentials.'; });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final isAr = app.isArabic;

    return Scaffold(
      backgroundColor: PwtColors.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.0,
                  colors: [PwtColors.brand.withValues(alpha: 0.12), PwtColors.brand.withValues(alpha: 0)],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 64, 28, 30),
                  child: Column(
                    children: [
                      Image.asset('assets/new_logo.png', width: 68, height: 68),
                      const SizedBox(height: 14),
                      Text(s['welcomeBack']!, style: PwtType.headline(arabic: isAr).copyWith(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(s['signInToContinue']!, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec, arabic: isAr).copyWith(fontSize: 14)),
                      const SizedBox(height: 28),
                      ModeTabs(
                        mode: _mode,
                        onChanged: _setMode,
                        individualLabel: s['individual']!,
                        businessLabel: s['business']!,
                      ),
                      const SizedBox(height: 22),
                      PwtField(
                        label: s['email']!,
                        controller: _email,
                        leading: PwtIcons.message,
                        forceLtr: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      PwtField(
                        label: isAr ? 'كلمة المرور' : 'Password',
                        controller: _password,
                        leading: PwtIcons.shield,
                        obscure: !_showPw,
                        forceLtr: true,
                        trailing: GestureDetector(
                          onTap: () => setState(() => _showPw = !_showPw),
                          child: Icon(_showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: PwtColors.textTer),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              isAr ? 'نسيت كلمة المرور؟' : 'Forgot password?',
                              style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (_error != null) ...[
                        Text(_error!, textAlign: TextAlign.center, style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 13)),
                        const SizedBox(height: 10),
                      ],
                      PwtButton(label: _loading ? '…' : s['signIn']!, full: true, disabled: _loading, onPressed: _signIn),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () => context.read<AppState>().go(AppRoute.signup),
                        child: Text.rich(
                          TextSpan(
                            style: PwtType.label(color: PwtColors.textSec),
                            children: [
                              TextSpan(text: isAr ? 'ليس لديك حساب؟ ' : "Don't have an account? "),
                              TextSpan(text: isAr ? 'إنشاء حساب' : 'Sign up', style: const TextStyle(color: PwtColors.brand, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: PwtColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: PwtColors.hairline),
                    ),
                    child: IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(PwtIcons.back, size: 22),
                      color: PwtColors.textPri,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
