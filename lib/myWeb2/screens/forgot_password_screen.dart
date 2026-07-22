import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'login_screen.dart' show AuthShell;
import '../../Backend/Auth/forget_password.dart';
import '../../Backend/Auth/verify_reset_otp.dart';
import '../../Backend/Auth/reset_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1; // 1 email, 2 verify, 3 new password
  bool _done = false;

  final _emailCtrl = TextEditingController();
  final _otp = List.generate(6, (_) => TextEditingController());
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;
  String _resetToken = '';
  bool _obscure = true, _obscure2 = true, _showMatchErr = false;
  bool _argsLoaded = false;

  String get _email => _emailCtrl.text.trim();
  String get _otpCode => _otp.map((c) => c.text).join();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) {
      _emailCtrl.text = arg;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otp) c.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await forgotPassword(_email);
    if (!mounted) return;
    if (result.success) {
      setState(() { _loading = false; _step = 2; });
    } else {
      setState(() {
        _loading = false;
        _error = result.message ?? result.error ?? 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() { _loading = true; _error = null; });
    final result = await verifyResetOtp(email: _email, otp: _otpCode);
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() { _loading = false; _resetToken = result.data!.devToken; _step = 3; });
    } else {
      setState(() {
        _loading = false;
        _error = result.message ?? result.error ?? 'Invalid code. Please try again.';
      });
    }
  }

  Future<void> _submitPassword() async {
    final v = _password.text;
    if (v.length < 8 || _score(v) < 2) {
      setState(() {});
      return;
    }
    if (_confirm.text != v) {
      setState(() => _showMatchErr = true);
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await resetPassword(
      email: _email,
      token: _resetToken,
      password: v,
      passwordConfirmation: _confirm.text,
    );
    if (!mounted) return;
    if (result.success) {
      setState(() { _loading = false; _done = true; });
    } else {
      setState(() {
        _loading = false;
        _error = result.message ?? result.error ?? 'Failed to reset password. Please try again.';
      });
    }
  }

  // ---- password strength ----
  ({bool len, bool upper, bool digit, bool sym}) _checks(String v) => (
        len: v.length >= 8,
        upper: RegExp(r'[a-z]').hasMatch(v) && RegExp(r'[A-Z]').hasMatch(v),
        digit: RegExp(r'\d').hasMatch(v),
        sym: RegExp(r'[^A-Za-z0-9]').hasMatch(v),
      );

  int _score(String v) {
    final c = _checks(v);
    return (c.len ? 1 : 0) + (c.upper ? 1 : 0) + (c.digit ? 1 : 0) + (c.sym ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      headline: _step == 1
          ? "Let's get you back in."
          : _step == 2
              ? 'Check your inbox.'
              : 'Choose a strong new password.',
      sub: _step == 1
          ? "Enter your account email and we'll send you a verification code."
          : _step == 2
              ? "We sent a 6-digit code to your email — enter it below."
              : "Pick something you'll remember but others won't guess.",
      bullets: _step == 3
          ? const ['At least 8 characters', 'Mix letters, numbers & symbols', 'Avoid reusing old passwords']
          : const ['Secure one-time code', 'Code sent to your email', 'Back in under a minute'],
      form: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadow.card,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextButton.icon(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(_step == 1 ? 'Back to sign in' : 'Back'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
          ),
          const SizedBox(height: 12),
          _progress(),
          const SizedBox(height: 20),
          if (_done)
            _doneState()
          else if (_step == 1)
            _emailStep()
          else if (_step == 2)
            _verifyStep()
          else
            _passwordStep(),
          if (!_done) ...[
            const SizedBox(height: 16),
            Center(child: Wrap(children: [
              Text('Remembered it? ', style: AppText.body.copyWith(color: AppColors.ink500)),
              GestureDetector(
                onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: Text('Back to sign in', style: AppText.label.copyWith(color: AppColors.blue700)),
              ),
            ])),
          ],
        ]),
      ),
    );
  }

  void _back() {
    if (_step == 1) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      setState(() { _step -= 1; _error = null; });
    }
  }

  Widget _progress() {
    final labels = ['Email', 'Verify', 'New password'];
    final cur = _done ? 4 : _step;
    return Row(children: List.generate(3, (i) {
      final n = i + 1;
      final done = n < cur;
      final active = n == cur;
      return Expanded(child: Row(children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done || active ? AppColors.blue700 : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: done || active ? AppColors.blue700 : AppColors.line, width: 1.5),
          ),
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Center(child: Text('$n', style: AppText.muted.copyWith(color: active ? Colors.white : AppColors.ink400, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 7),
        Flexible(child: Text(labels[i], style: AppText.muted.copyWith(color: active || done ? AppColors.ink900 : AppColors.ink400, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (i < 2) Expanded(child: Container(height: 1.5, margin: const EdgeInsets.symmetric(horizontal: 8), color: done ? AppColors.blue700 : AppColors.line)),
      ]));
    }));
  }

  // ── step 1: email input ──────────────────────────────────────────────────
  Widget _emailStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Forgot your password?', style: AppText.h2),
      const SizedBox(height: 6),
      Text("Enter the email linked to your account and we'll send a reset code.", style: AppText.body.copyWith(color: AppColors.ink500)),
      const SizedBox(height: 22),
      Text('Email address', style: AppText.label),
      const SizedBox(height: 7),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(hintText: 'you@email.com'),
      ),
      if (_error != null) ...[const SizedBox(height: 14), _errorBox(_error!)],
      const SizedBox(height: 22),
      PwtButton(_loading ? 'Sending…' : 'Send verification code', fullWidth: true, onPressed: _loading ? null : _sendCode),
    ]);
  }

  // ── step 2: OTP ──────────────────────────────────────────────────────────
  Widget _verifyStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Enter your code', style: AppText.h2),
      const SizedBox(height: 6),
      Text.rich(TextSpan(
        style: AppText.body.copyWith(color: AppColors.ink500),
        children: [
          const TextSpan(text: 'Enter the 6-digit code we sent to '),
          TextSpan(text: _email, style: const TextStyle(color: AppColors.ink900, fontWeight: FontWeight.w600)),
          const TextSpan(text: '.'),
        ],
      )),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) => SizedBox(
          width: 46,
          child: TextField(
            controller: _otp[i],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            style: AppText.h3,
            decoration: const InputDecoration(counterText: ''),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
              setState(() {});
            },
          ),
        )),
      ),
      if (_error != null) ...[const SizedBox(height: 14), _errorBox(_error!)],
      const SizedBox(height: 18),
      PwtButton(_loading ? 'Verifying…' : 'Verify & continue', fullWidth: true, onPressed: (_loading || _otpCode.length < 6) ? null : _verifyOtp),
      const SizedBox(height: 14),
      Center(child: Wrap(children: [
        Text("Didn't receive it? ", style: AppText.body.copyWith(color: AppColors.ink500)),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _loading ? null : _sendCode,
            child: Text('Resend code', style: AppText.label.copyWith(color: AppColors.blue700)),
          ),
        ),
      ])),
    ]);
  }

  // ── step 3: new password ─────────────────────────────────────────────────
  Widget _passwordStep() {
    final v = _password.text;
    final c = _checks(v);
    final score = _score(v);
    const strengthLabels = ['', 'Weak password', 'Weak password', 'Fair password', 'Good password', 'Strong password'];
    final barColors = [const Color(0xFFE5484D), const Color(0xFFF59E0B), const Color(0xFF3B82F6), const Color(0xFF10B981)];
    Color labelColor() {
      switch (score) {
        case 1: return const Color(0xFFE5484D);
        case 2: return const Color(0xFFD97706);
        case 3: return const Color(0xFF2563EB);
        case 4: return const Color(0xFF0F9D6A);
        default: return AppColors.ink400;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Set a new password', style: AppText.h2),
      const SizedBox(height: 6),
      Text('Create a new password for your PWT account. Make it strong and unique.', style: AppText.body.copyWith(color: AppColors.ink500)),
      const SizedBox(height: 18),
      Text('New password', style: AppText.label),
      const SizedBox(height: 7),
      TextField(
        controller: _password,
        obscureText: _obscure,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'At least 8 characters',
          suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18), onPressed: () => setState(() => _obscure = !_obscure)),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: List.generate(4, (i) => Expanded(child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            decoration: BoxDecoration(color: v.isNotEmpty && i < score ? barColors[score - 1] : const Color(0xFFE7ECF4), borderRadius: BorderRadius.circular(3)),
          )))),
      const SizedBox(height: 8),
      Text(
        v.isEmpty ? 'Use 8+ characters with a mix of letters, numbers & symbols.' : strengthLabels[score],
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: v.isEmpty ? AppColors.ink400 : labelColor()),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 16, runSpacing: 9, children: [
        _req('8+ characters', c.len),
        _req('Upper & lowercase', c.upper),
        _req('A number', c.digit),
        _req('A symbol', c.sym),
      ]),
      const SizedBox(height: 20),
      Text('Confirm new password', style: AppText.label),
      const SizedBox(height: 7),
      TextField(
        controller: _confirm,
        obscureText: _obscure2,
        onChanged: (_) { if (_showMatchErr) setState(() => _showMatchErr = _confirm.text != _password.text); },
        decoration: InputDecoration(
          hintText: 'Re-enter your password',
          suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18), onPressed: () => setState(() => _obscure2 = !_obscure2)),
        ),
      ),
      if (_showMatchErr) ...[
        const SizedBox(height: 8),
        const Text("Passwords don't match.", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFE5484D))),
      ],
      if (_error != null) ...[const SizedBox(height: 14), _errorBox(_error!)],
      const SizedBox(height: 22),
      PwtButton(_loading ? 'Updating…' : 'Update password', fullWidth: true, onPressed: _loading ? null : _submitPassword),
    ]);
  }

  Widget _req(String label, bool met) {
    return SizedBox(
      width: 150,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(shape: BoxShape.circle, color: met ? const Color(0xFF10B981) : Colors.white, border: Border.all(color: met ? const Color(0xFF10B981) : const Color(0xFFCDD6E6), width: 1.5)),
          child: met ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: TextStyle(fontSize: 12.5, color: met ? AppColors.ink700 : AppColors.ink500), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _errorBox(String msg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: AppText.body.copyWith(color: const Color(0xFFDC2626), fontSize: 13))),
        ]),
      );

  // ── success ──────────────────────────────────────────────────────────────
  Widget _doneState() {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 6),
      Container(
        width: 84, height: 84,
        decoration: const BoxDecoration(color: Color(0xFFE7F7EF), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle_outline, size: 40, color: Color(0xFF10B981)),
      ),
      const SizedBox(height: 24),
      Text('Password updated', style: AppText.h2, textAlign: TextAlign.center),
      const SizedBox(height: 10),
      Text(
        'Your password has been changed successfully. You can now sign in with your new password.',
        textAlign: TextAlign.center,
        style: AppText.body.copyWith(color: AppColors.ink500, height: 1.5),
      ),
      const SizedBox(height: 28),
      PwtButton('Back to sign in', fullWidth: true, onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false)),
    ]);
  }
}
