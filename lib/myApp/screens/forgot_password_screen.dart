import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../state/app_state.dart';
import '../widgets/form_field.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';
import 'signup_screen.dart' show OtpInput, OtpResend;
import '../../Backend/Auth/forget_password.dart';
import '../../Backend/Auth/verify_reset_otp.dart';
import '../../Backend/Auth/reset_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _steps = ['email', 'otp', 'password'];
  String _step = 'email';
  bool _done = false;

  final _email = TextEditingController();
  String _otp = '';
  String _resetToken = '';
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _showPw = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // ── Password strength ──
  bool _hasLength(String p) => p.length >= 8;
  bool _hasUpper(String p) => p.contains(RegExp(r'[A-Z]'));
  bool _hasDigit(String p) => p.contains(RegExp(r'[0-9]'));
  bool _hasSymbol(String p) => p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int _strength(String p) =>
      [_hasLength(p), _hasUpper(p), _hasDigit(p), _hasSymbol(p)].where((v) => v).length;

  Color _strengthColor(int s) {
    if (s <= 1) return PwtColors.error;
    if (s == 2) return PwtColors.warning;
    if (s == 3) return PwtColors.brandSoft;
    return PwtColors.success;
  }

  bool get _passwordsValid =>
      _password.text.length >= 8 && _password.text == _confirm.text;

  // ── Step 1: send reset code ──
  Future<void> _sendCode() async {
    print('[ForgotPassword] Step 1: sending code to ${_email.text.trim()}');
    setState(() { _loading = true; _error = null; });
    final res = await forgotPassword(_email.text.trim());
    if (!mounted) return;
    if (res.success) {
      print('[ForgotPassword] Code sent → moving to OTP step');
      setState(() { _loading = false; _step = 'otp'; _otp = ''; });
    } else {
      print('[ForgotPassword] Send code failed: ${res.message}');
      setState(() { _loading = false; _error = res.message ?? 'Failed to send code. Please try again.'; });
    }
  }

  // ── Step 2: verify OTP ──
  Future<void> _verifyOtp() async {
    print('[ForgotPassword] Step 2: verifying OTP=$_otp for ${_email.text.trim()}');
    setState(() { _loading = true; _error = null; });
    final res = await verifyResetOtp(email: _email.text.trim(), otp: _otp);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _resetToken = res.data!.devToken;
      print('[ForgotPassword] OTP verified → token=$_resetToken → moving to password step');
      setState(() { _loading = false; _step = 'password'; });
    } else {
      print('[ForgotPassword] OTP verification failed: ${res.message}');
      setState(() { _loading = false; _error = res.message ?? 'Invalid code. Please try again.'; });
    }
  }

  // ── Step 3: reset password ──
  Future<void> _resetPassword() async {
    print('[ForgotPassword] Step 3: resetting password for ${_email.text.trim()} with token=$_resetToken');
    setState(() { _loading = true; _error = null; });
    final res = await resetPassword(
      email: _email.text.trim(),
      token: _resetToken,
      password: _password.text,
      passwordConfirmation: _confirm.text,
    );
    if (!mounted) return;
    if (res.success) {
      print('[ForgotPassword] Password reset successful → done');
      setState(() { _loading = false; _done = true; });
    } else {
      print('[ForgotPassword] Password reset failed: ${res.message}');
      setState(() { _loading = false; _error = res.message ?? 'Failed to reset password. Please try again.'; });
    }
  }

  void _back() {
    if (_step == 'otp') {
      setState(() { _step = 'email'; _error = null; });
    } else if (_step == 'password') {
      setState(() { _step = 'otp'; _error = null; });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isAr = app.isArabic;
    final activeIndex = _steps.indexOf(_step);

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
            child: _done
                ? _doneBody(isAr)
                : Column(
                    children: [
                      // top bar
                      SizedBox(
                        height: 56,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _back,
                              icon: const Icon(PwtIcons.back, size: 24),
                              color: PwtColors.textPri,
                            ),
                            Expanded(
                              child: Text(
                                isAr ? 'نسيت كلمة المرور' : 'Forgot Password',
                                textAlign: TextAlign.center,
                                style: PwtType.subtitle().copyWith(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      // progress bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                        child: Row(
                          children: [
                            for (int i = 0; i < _steps.length; i++)
                              Expanded(
                                child: Container(
                                  height: 3.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: i <= activeIndex ? PwtColors.brand : PwtColors.hairline2,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(child: _stepBody(isAr)),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 13),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 6, 24, 14),
                        child: _cta(isAr),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _doneBody(bool isAr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PwtColors.successFill,
                shape: BoxShape.circle,
                border: Border.all(color: PwtColors.successBorder),
              ),
              child: const Icon(PwtIcons.check, size: 36, color: PwtColors.success),
            ),
            const SizedBox(height: 22),
            Text(
              isAr ? 'تم إعادة تعيين كلمة المرور' : 'Password Reset!',
              textAlign: TextAlign.center,
              style: PwtType.headline(arabic: isAr).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              isAr
                  ? 'يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.'
                  : 'You can now sign in with your new password.',
              textAlign: TextAlign.center,
              style: PwtType.body(color: PwtColors.textSec, arabic: isAr).copyWith(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            PwtButton(
              label: isAr ? 'العودة إلى تسجيل الدخول' : 'Back to Login',
              full: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cta(bool isAr) {
    switch (_step) {
      case 'email':
        final emailOk = _email.text.trim().contains('@') && _email.text.trim().isNotEmpty;
        return PwtButton(
          label: _loading ? '…' : (isAr ? 'إرسال الرمز' : 'Send Code'),
          full: true,
          trailing: _loading ? null : PwtIcons.arrow,
          disabled: _loading || !emailOk,
          onPressed: _sendCode,
        );
      case 'otp':
        return PwtButton(
          label: _loading ? '…' : (isAr ? 'تحقق' : 'Verify'),
          full: true,
          trailing: _loading ? null : PwtIcons.arrow,
          disabled: _loading || _otp.length < 6,
          onPressed: _verifyOtp,
        );
      default:
        return PwtButton(
          label: _loading ? '…' : (isAr ? 'إعادة تعيين كلمة المرور' : 'Reset Password'),
          full: true,
          trailing: _loading ? null : PwtIcons.arrow,
          disabled: _loading || !_passwordsValid,
          onPressed: _resetPassword,
        );
    }
  }

  Widget _stepBody(bool isAr) {
    switch (_step) {
      case 'email':
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          children: [
            Text(
              isAr ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
              style: PwtType.headline(arabic: isAr).copyWith(fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'سنرسل لك رمز التحقق لإعادة تعيين كلمة المرور.'
                  : "We'll send a verification code to reset your password.",
              style: PwtType.body(color: PwtColors.textSec, arabic: isAr).copyWith(fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 22),
            PwtField(
              label: isAr ? 'البريد الإلكتروني' : 'Email',
              controller: _email,
              leading: PwtIcons.message,
              forceLtr: true,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
          ],
        );

      case 'otp':
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          children: [
            Text(
              isAr ? 'تحقق من بريدك الإلكتروني' : 'Check your email',
              style: PwtType.headline(arabic: isAr).copyWith(fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5, height: 1.5),
                children: [
                  TextSpan(text: isAr ? 'تم إرسال الرمز إلى ' : 'Code sent to '),
                  TextSpan(
                    text: _email.text.trim(),
                    style: const TextStyle(color: PwtColors.textPri, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() { _step = 'email'; _error = null; }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  isAr ? 'تغيير البريد الإلكتروني' : 'Change email',
                  style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 18),
            OtpInput(onComplete: (otp) => setState(() => _otp = otp)),
            const OtpResend(),
          ],
        );

      default: // password
        final pw = _password.text;
        final strength = _strength(pw);
        final strengthColor = _strengthColor(strength);
        final checks = [
          (label: isAr ? '٨ أحرف على الأقل' : '8+ characters', met: _hasLength(pw)),
          (label: isAr ? 'حرف كبير' : 'Uppercase letter', met: _hasUpper(pw)),
          (label: isAr ? 'رقم' : 'Number', met: _hasDigit(pw)),
          (label: isAr ? 'رمز خاص' : 'Special character', met: _hasSymbol(pw)),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          children: [
            Text(
              isAr ? 'كلمة مرور جديدة' : 'New Password',
              style: PwtType.headline(arabic: isAr).copyWith(fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text(
              isAr ? 'اختر كلمة مرور قوية لحسابك.' : 'Choose a strong password for your account.',
              style: PwtType.body(color: PwtColors.textSec, arabic: isAr).copyWith(fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 22),
            PwtField(
              label: isAr ? 'كلمة المرور الجديدة' : 'New Password',
              controller: _password,
              leading: PwtIcons.shield,
              obscure: !_showPw,
              forceLtr: true,
              trailing: GestureDetector(
                onTap: () => setState(() => _showPw = !_showPw),
                child: Icon(
                  _showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: PwtColors.textTer,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (pw.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i < strength ? strengthColor : PwtColors.hairline2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: checks.map((c) => _chip(c.label, c.met)).toList(),
              ),
            ],
            const SizedBox(height: 12),
            PwtField(
              label: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
              controller: _confirm,
              leading: PwtIcons.shield,
              obscure: !_showConfirm,
              forceLtr: true,
              trailing: GestureDetector(
                onTap: () => setState(() => _showConfirm = !_showConfirm),
                child: Icon(
                  _showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: PwtColors.textTer,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_confirm.text.isNotEmpty && _password.text != _confirm.text) ...[
              const SizedBox(height: 6),
              Text(
                isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match',
                style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 12.5),
              ),
            ],
          ],
        );
    }
  }

  Widget _chip(String label, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: met ? PwtColors.successFill : PwtColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: met ? PwtColors.successBorder : PwtColors.hairline2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? PwtIcons.check : Icons.circle_outlined,
            size: 12,
            color: met ? PwtColors.success : PwtColors.textTer,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: PwtType.label(color: met ? PwtColors.success : PwtColors.textTer).copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
