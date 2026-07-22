import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login_screen.dart' show AuthShell;
import '../../Backend/Auth/register_otp.dart';
import '../../Backend/Auth/verify_register_otp.dart';
import '../../Backend/Auth/register.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Models/Reference/country_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _acct = 0; // 0 individual, 1 company
  int _step = 1; // 1 mobile, 2 otp, 3 details
  bool _loading = false;
  String? _error;
  final _phone = TextEditingController();
  final _otp = List.generate(6, (_) => TextEditingController());
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String _country = '+971';
  String _countryIso = 'AE';
  List<CountryModel> _countries = [];
  String? _phoneError;
  String? _emailError;
  bool _phoneLibReady = false;

  @override
  void initState() {
    super.initState();
    _loadCountryCodes();
    _ensurePhoneLib();
  }

  Future<void> _ensurePhoneLib() async {
    if (_phoneLibReady) return;
    try {
      await init().timeout(const Duration(seconds: 5));
      _phoneLibReady = true;
    } catch (_) {
      // The phone-format library loads a script from a third-party CDN; if
      // that's unreachable, skip client-side validation rather than block
      // the form — the backend still validates the number.
    }
  }

  void _loadCountryCodes() {
    getCountries().then((res) {
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() => _countries = res.data!.where((c) => (c.phoneCode ?? '').isNotEmpty).toList());
      }
    });
  }

  bool get isCompany => _acct == 1;
  String get _fullPhone => '$_country${_phone.text.trim()}';
  String get _otpCode => _otp.map((c) => c.text).join();

  // Step 1: send OTP
  Future<void> _sendOtp() async {
    final phone = _phone.text.trim();
    await _ensurePhoneLib();
    try {
      if (_phoneLibReady) await parse(phone, region: _countryIso);
    } catch (_) {
      setState(() => _phoneError = 'Please enter a valid mobile number for the selected country.');
      return;
    }

    setState(() { _loading = true; _error = null; _phoneError = null; });
    final result = await requestRegisterOtp(_fullPhone, isCompany ? 'company' : 'individual');
    if (!mounted) return;
    if (result.success) {
      setState(() { _loading = false; _step = 2; });
    } else {
      setState(() { _loading = false; _error = result.message ?? result.error ?? 'Failed to send code.'; });
    }
  }

  // Step 2: verify OTP → get temp token
  Future<void> _verifyOtp() async {
    setState(() { _loading = true; _error = null; });
    final result = await verifyRegisterOtp(_fullPhone, _otpCode, isCompany ? 'company' : 'individual');
    if (!mounted) return;
    if (result.success && result.data != null) {
      // حفظ مؤقت في الذاكرة فقط — DioService رح يبعثه مع طلب register
      AppState.instance.accessToken = result.data!.accessToken;
      setState(() { _loading = false; _step = 3; });
    } else {
      setState(() { _loading = false; _error = result.message ?? result.error ?? 'Invalid code. Please try again.'; });
    }
  }

  // Step 3: complete registration
  Future<void> _register() async {
    final email = _email.text.trim();
    if (email.isNotEmpty && !EmailValidator.validate(email)) {
      setState(() => _emailError = 'Please enter a valid email address.');
      return;
    }

    setState(() { _loading = true; _error = null; _emailError = null; });
    final name = '${_first.text.trim()} ${_last.text.trim()}'.trim();
    final result = await register(
      name.isEmpty ? 'PWT Member' : name,
      _email.text.trim().isEmpty ? null : _email.text.trim(),
      _password.text,
      _password.text,
      AppState.instance.lang,
      isCompany ? 'company' : 'individual',
      companyName: isCompany ? _company.text.trim() : null,
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
        Navigator.of(context).pushNamedAndRemoveUntil(
          isCompany ? '/companyDashboard' : '/dashboard',
          (r) => false,
        );
      }
    } else {
      setState(() { _loading = false; _error = result.message ?? result.error ?? 'Registration failed. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final returnRoute = args is Map ? args['returnRoute'] as String? : null;
    final returnArguments = args is Map ? args['returnArguments'] : null;

    return AuthShell(
      headline: 'Join thousands drinking better.',
      sub: 'Create your free PWT account to shop systems, set up rentals and keep your filters fresh — all in one dashboard.',
      bullets: const ['Free 7-day trial on rentals', 'Fast delivery & installation', 'Maintenance & filter reminders'],
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
          _progress(),
          const SizedBox(height: 20),
          if (_step == 1) _mobileStep() else if (_step == 2) _otpStep() else _detailsStep(),
          const SizedBox(height: 16),
          Center(child: Wrap(children: [
            Text('Already have an account? ', style: AppText.body.copyWith(color: AppColors.ink500)),
            GestureDetector(
              onTap: () => Navigator.of(context).pushReplacementNamed('/login', arguments: returnRoute != null ? {'returnRoute': returnRoute, 'returnArguments': returnArguments} : null),
              child: Text('Sign in', style: AppText.label.copyWith(color: AppColors.blue700)),
            ),
          ])),
        ]),
      ),
    );
  }

  Widget _progress() {
    final labels = ['Mobile', 'Verify', 'Details'];
    return Row(children: List.generate(3, (i) {
      final n = i + 1;
      final done = n < _step;
      final active = n == _step;
      return Expanded(child: Row(children: [
        Container(width: 26, height: 26, decoration: BoxDecoration(color: done || active ? AppColors.blue700 : Colors.white, shape: BoxShape.circle, border: Border.all(color: done || active ? AppColors.blue700 : AppColors.line, width: 1.5)), child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : Center(child: Text('$n', style: AppText.muted.copyWith(color: active ? Colors.white : AppColors.ink400, fontWeight: FontWeight.w700)))),
        const SizedBox(width: 7),
        Text(labels[i], style: AppText.muted.copyWith(color: active ? AppColors.ink900 : AppColors.ink400, fontWeight: FontWeight.w600)),
        if (i < 2) Expanded(child: Container(height: 1.5, margin: const EdgeInsets.symmetric(horizontal: 8), color: done ? AppColors.blue700 : AppColors.line)),
      ]));
    }));
  }

  Widget _mobileStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Create your account', style: AppText.h2),
      const SizedBox(height: 6),
      Text("Enter your mobile number to get started — we'll text you a verification code.", style: AppText.body.copyWith(color: AppColors.ink500)),
      const SizedBox(height: 18),
      Segmented(options: const ['Personal', 'Business'], icons: const [Icons.person_outline, Icons.apartment], index: _acct, onChanged: (i) => setState(() => _acct = i)),
      const SizedBox(height: 18),
      Text('Mobile number', style: AppText.label),
      const SizedBox(height: 7),
      Row(children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(AppRadius.sm)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _country,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.ink400),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink900),
              items: _countries.isEmpty
                  ? [DropdownMenuItem(value: _country, child: Text(_country))]
                  : _countries.map((c) => DropdownMenuItem(
                      value: c.phoneCode!,
                      child: Text('${_flagFromCode(c.code)} ${c.phoneCode}'),
                    )).toList(),
              onChanged: (v) => setState(() {
                _country = v!;
                final match = _countries.firstWhere((c) => c.phoneCode == v, orElse: () => CountryModel());
                if (match.code != null) _countryIso = match.code!.toUpperCase();
              }),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(hintText: '50 123 4567', errorText: _phoneError),
          onChanged: (_) => setState(() => _phoneError = null),
        )),
      ]),
      if (_error != null) ...[
        const SizedBox(height: 14),
        _errorBox(_error!),
      ],
      const SizedBox(height: 20),
      PwtButton(_loading ? 'Sending…' : 'Send verification code', fullWidth: true, onPressed: _loading ? null : _sendOtp),
    ]);
  }

  Widget _otpStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Verify your number', style: AppText.h2),
      const SizedBox(height: 6),
      Text('Enter the 6-digit code we sent by SMS.', style: AppText.body.copyWith(color: AppColors.ink500)),
      const SizedBox(height: 18),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) => SizedBox(
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
              },
            ),
          ))),
      if (_error != null) ...[
        const SizedBox(height: 14),
        _errorBox(_error!),
      ],
      const SizedBox(height: 18),
      PwtButton(_loading ? 'Verifying…' : 'Verify & continue', fullWidth: true, onPressed: _loading ? null : _verifyOtp),
      const SizedBox(height: 8),
      Center(child: TextButton(onPressed: _loading ? null : () => setState(() { _step = 1; _error = null; }), child: const Text('Change number'))),
    ]);
  }

  Widget _detailsStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Complete your profile', style: AppText.h2),
      const SizedBox(height: 6),
      Text('Almost there — just a few details to finish setting up.', style: AppText.body.copyWith(color: AppColors.ink500)),
      const SizedBox(height: 18),
      if (isCompany) ...[
        Text('Company name', style: AppText.label),
        const SizedBox(height: 7),
        TextField(controller: _company, decoration: const InputDecoration(hintText: 'Acme Hospitality Ltd')),
        const SizedBox(height: 14),
      ],
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('First name', style: AppText.label), const SizedBox(height: 7), TextField(controller: _first, decoration: const InputDecoration(hintText: 'Sarah'))])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Last name', style: AppText.label), const SizedBox(height: 7), TextField(controller: _last, decoration: const InputDecoration(hintText: 'Johnson'))])),
      ]),
      const SizedBox(height: 14),
      Text('Email address', style: AppText.label),
      const SizedBox(height: 7),
      TextField(
        controller: _email,
        decoration: InputDecoration(hintText: 'you@email.com', errorText: _emailError),
        onChanged: (_) => setState(() => _emailError = null),
      ),
      const SizedBox(height: 14),
      Text('Password', style: AppText.label),
      const SizedBox(height: 7),
      TextField(controller: _password, obscureText: _obscure, decoration: InputDecoration(hintText: 'At least 8 characters', suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18), onPressed: () => setState(() => _obscure = !_obscure)))),
      if (_error != null) ...[
        const SizedBox(height: 14),
        _errorBox(_error!),
      ],
      const SizedBox(height: 20),
      PwtButton(_loading ? 'Creating account…' : 'Create Account', fullWidth: true, onPressed: _loading ? null : _register),
    ]);
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECACA))),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: AppText.body.copyWith(color: const Color(0xFFDC2626), fontSize: 13))),
      ]),
    );
  }
}

String _flagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}
