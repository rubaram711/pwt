import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import '../core/asset_resolver.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/form_field.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Backend/Auth/register_otp.dart';
import '../../Backend/Auth/verify_register_otp.dart';
import '../../Backend/Auth/register.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Models/Reference/country_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.onBack, required this.onComplete});
  final VoidCallback onBack;
  final ValueChanged<AccountKind> onComplete;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _steps = ['phone', 'otp', 'details'];
  String _step = 'phone';
  AccountKind _mode = AccountKind.individual;

  // phone step
  final _phone = TextEditingController();
  String _country = '+971';
  String _countryIso = 'AE';
  bool _phoneLibReady = false;
  List<CountryModel> _countries = [];

  // otp step
  String _otp = '';

  // details — individual
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  // details — business
  final _company = TextEditingController();
  final _bizName = TextEditingController();
  final _bizEmail = TextEditingController();
  final _bizPassword = TextEditingController();

  // password visibility
  bool _showPw = false;
  bool _showBizPw = false;

  // shared
  bool _agreed = true;
  bool _loading = false;
  String? _error;

  bool get _isEmailTakenError =>
      _error != null && _error!.toLowerCase().contains('already registered');

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

  @override
  void dispose() {
    for (final c in [_phone, _name, _email, _password, _company, _bizName, _bizEmail, _bizPassword]) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadCountryCodes() {
    getCountries().then((res) {
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _countries = res.data!.where((c) => (c.phoneCode ?? '').isNotEmpty).toList();
          final match = _countries.firstWhere((c) => c.phoneCode == _country, orElse: () => CountryModel());
          if (match.code != null) _countryIso = match.code!.toUpperCase();
        });
      }
    });
  }

  void _back() {
    if (_step == 'otp') {
      setState(() { _step = 'phone'; _error = null; });
    } else if (_step == 'details') {
      setState(() { _step = 'otp'; _error = null; });
    } else {
      widget.onBack();
    }
  }

  String get _fullPhone => '$_country${_phone.text}';
  String get _accountType => _mode == AccountKind.business ? 'company' : 'individual';

  bool get _detailsValid => _mode == AccountKind.individual
      ? (_name.text.isNotEmpty && _email.text.isNotEmpty && _password.text.isNotEmpty && _agreed)
      : (_company.text.isNotEmpty && _bizName.text.isNotEmpty && _bizEmail.text.isNotEmpty && _bizPassword.text.isNotEmpty && _agreed);

  // ── Step 1: send OTP ──────────────────────────────────────────
  Future<void> _sendCode() async {
    await _ensurePhoneLib();
    try {
      if (_phoneLibReady) await parse(_phone.text.trim(), region: _countryIso);
    } catch (_) {
      setState(() => _error = 'Please enter a valid mobile number for the selected country.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    final res = await requestRegisterOtp(_fullPhone, _accountType);
    if (!mounted) return;
    if (res.success) {
      setState(() { _loading = false; _step = 'otp'; _otp = ''; });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to send code. Please try again.'; });
    }
  }

  // ── Step 2: verify OTP ───────────────────────────────────────
  Future<void> _verifyOtp() async {
    setState(() { _loading = true; _error = null; });
    final res = await verifyRegisterOtp(_fullPhone, _otp, _accountType);
    if (!mounted) return;
    if (res.success && res.data != null) {
      web.AppState.instance.accessToken = res.data!.accessToken;
      setState(() { _loading = false; _step = 'details'; });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Invalid code. Please try again.'; });
    }
  }

  // ── Step 3: register ─────────────────────────────────────────
  Future<void> _completeSignup() async {
    final isIndividual = _mode == AccountKind.individual;
    final email = isIndividual ? _email.text.trim() : _bizEmail.text.trim();
    if (!EmailValidator.validate(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    final locale = context.read<AppState>().lang;
    setState(() { _loading = true; _error = null; });
    final res = await register(
      isIndividual ? _name.text.trim() : _bizName.text.trim(),
      isIndividual ? _email.text.trim() : _bizEmail.text.trim(),
      isIndividual ? _password.text : _bizPassword.text,
      isIndividual ? _password.text : _bizPassword.text,
      locale,
      _accountType,
      companyName: isIndividual ? null : _company.text.trim(),
    );
    if (!mounted) return;
    if (res.success && res.data != null) {
      final pw = isIndividual ? _password.text : _bizPassword.text;
      await web.AppState.instance.signIn(
        res.data!.user,
        res.data!.token.accessToken,
        password: pw,
        accountType: _accountType,
      );
      widget.onComplete(_mode);
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Registration failed. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final prettyPhone = '$_country ${_phone.text}';
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
            child: Column(
              children: [
                // top bar
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(onPressed: _back, icon: const Icon(PwtIcons.back, size: 24), color: PwtColors.textPri),
                      Expanded(child: Text(s['signUp']!, textAlign: TextAlign.center, style: PwtType.subtitle().copyWith(fontSize: 16))),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // progress
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
                Expanded(child: _stepBody(s, prettyPhone, app.isArabic)),
                // error
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                    child: Column(
                      children: [
                        Text(_error!, textAlign: TextAlign.center, style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 13)),
                        if (_isEmailTakenError) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => context.read<AppState>().goToLoginWithCredentials(
                                  email: _mode == AccountKind.individual ? _email.text.trim() : _bizEmail.text.trim(),
                                  password: _mode == AccountKind.individual ? _password.text : _bizPassword.text,
                                  mode: _mode,
                                ),
                            child: Text(
                              app.isArabic ? 'تسجيل الدخول بدلاً من ذلك' : 'Log in instead',
                              style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w700).copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                // sticky CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 14),
                  child: _cta(s),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cta(Map<String, String> s) {
    switch (_step) {
      case 'phone':
        return PwtButton(
          label: _loading ? '…' : s['sendCode']!,
          full: true,
          trailing: _loading ? null : PwtIcons.arrow,
          disabled: _loading || _phone.text.replaceAll(RegExp(r'\D'), '').length < 8,
          onPressed: _sendCode,
        );
      case 'otp':
        return PwtButton(
          label: _loading ? '…' : s['verify']!,
          full: true,
          trailing: _loading ? null : PwtIcons.arrow,
          disabled: _loading || _otp.length < 6,
          onPressed: _verifyOtp,
        );
      default:
        return PwtButton(
          label: _loading ? '…' : s['signUp']!,
          full: true,
          trailing: _loading ? null : PwtIcons.arrow,
          disabled: _loading || !_detailsValid,
          onPressed: _completeSignup,
        );
    }
  }

  Widget _stepBody(Map<String, String> s, String prettyPhone, bool isArabic) {
    switch (_step) {
      case 'phone':
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          children: [
            Text(s['enterMobile']!, style: PwtType.headline().copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text(s['enterMobileSub']!, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5, height: 1.5)),
            const SizedBox(height: 18),
            ModeTabs(mode: _mode, onChanged: (m) => setState(() => _mode = m), individualLabel: s['individual']!, businessLabel: s['business']!),
            const SizedBox(height: 22),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: PwtColors.surface,
                      border: Border.all(color: PwtColors.hairline, width: 1.5),
                      borderRadius: BorderRadius.circular(PwtRadius.md),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _country,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: PwtColors.textTer),
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: PwtColors.textPri),
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
                  Expanded(
                    child: PwtField(
                      label: s['mobileNumber']!,
                      controller: _phone,
                      leading: PwtIcons.phone,
                      forceLtr: true,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: GestureDetector(
                onTap: () => context.read<AppState>().go(AppRoute.login),
                child: Text.rich(
                  TextSpan(
                    style: PwtType.label(color: PwtColors.textSec),
                    children: [
                      TextSpan(text: isArabic ? 'لديك حساب بالفعل؟ ' : 'Already have an account? '),
                      TextSpan(text: isArabic ? 'تسجيل الدخول' : 'Log in', style: const TextStyle(color: PwtColors.brand, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case 'otp':
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          children: [
            Text(s['verifyNumber']!, style: PwtType.headline().copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5, height: 1.5),
                children: [
                  TextSpan(text: '${s['otpSentTo']} '),
                  TextSpan(text: prettyPhone, style: const TextStyle(color: PwtColors.textPri, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() { _step = 'phone'; _error = null; }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(s['changeNumber']!, style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 13)),
              ),
            ),
            const SizedBox(height: 18),
            OtpInput(onComplete: (otp) => setState(() => _otp = otp)),
            const OtpResend(),
          ],
        );

      default:
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          children: [
            Text(s['finishSignup']!, style: PwtType.headline().copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text(s['finishSignupSub']!, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5, height: 1.5)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: PwtColors.brandTint, border: Border.all(color: PwtColors.brandBorder), borderRadius: BorderRadius.circular(PwtRadius.md)),
              child: Row(
                children: [
                  const Icon(PwtIcons.check, size: 16, color: PwtColors.success),
                  const SizedBox(width: 10),
                  Directionality(textDirection: TextDirection.ltr, child: Text(prettyPhone, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13.5))),
                  const Spacer(),
                  GestureDetector(onTap: () => setState(() { _step = 'phone'; _error = null; }), child: Text(s['changeNumber']!, style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 12.5))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_mode == AccountKind.individual) ...[
              PwtField(label: s['fullName']!, controller: _name, leading: PwtIcons.user, onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              PwtField(label: s['email']!, controller: _email, leading: PwtIcons.message, forceLtr: true, onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              PwtField(
                label: s['password']!,
                controller: _password,
                leading: PwtIcons.shield,
                obscure: !_showPw,
                forceLtr: true,
                onChanged: (_) => setState(() {}),
                trailing: GestureDetector(
                  onTap: () => setState(() => _showPw = !_showPw),
                  child: Icon(_showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: PwtColors.textTer),
                ),
              ),
            ] else ...[
              PwtField(label: s['companyName']!, controller: _company, leading: PwtIcons.building, onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              PwtField(label: s['fullName']!, controller: _bizName, leading: PwtIcons.user, onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              PwtField(label: s['email']!, controller: _bizEmail, leading: PwtIcons.message, forceLtr: true, onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              PwtField(
                label: s['password']!,
                controller: _bizPassword,
                leading: PwtIcons.shield,
                obscure: !_showBizPw,
                forceLtr: true,
                onChanged: (_) => setState(() {}),
                trailing: GestureDetector(
                  onTap: () => setState(() => _showBizPw = !_showBizPw),
                  child: Icon(_showBizPw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: PwtColors.textTer),
                ),
              ),
            ],
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: _agreed ? PwtColors.brand : PwtColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _agreed ? PwtColors.brand : PwtColors.hairline2, width: 1.5),
                    ),
                    child: _agreed ? const Icon(PwtIcons.check, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s['terms']!, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 12.5, height: 1.45))),
                ],
              ),
            ),
          ],
        );
    }
  }
}

String _flagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}

// ─── 6-digit OTP ───
class OtpInput extends StatefulWidget {
  const OtpInput({super.key, required this.onComplete});
  final ValueChanged<String> onComplete;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  static const _len = 6;
  final _controllers = List.generate(_len, (_) => TextEditingController());
  final _focusNodes = List.generate(_len, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(int i, String v) {
    if (v.isNotEmpty && i < _len - 1) _focusNodes[i + 1].requestFocus();
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      final otp = _controllers.map((c) => c.text).join();
      Future.delayed(const Duration(milliseconds: 180), () => widget.onComplete(otp));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < _len; i++)
            SizedBox(
              width: 48,
              height: 58,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: PwtType.title().copyWith(fontSize: 24, fontWeight: FontWeight.w700),
                onChanged: (v) => _onChanged(i, v),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: PwtColors.surface,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _controllers[i].text.isNotEmpty ? PwtColors.brand : PwtColors.hairline2, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: PwtColors.brand, width: 1.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OtpResend extends StatefulWidget {
  const OtpResend({super.key});
  @override
  State<OtpResend> createState() => _OtpResendState();
}

class _OtpResendState extends State<OtpResend> {
  int _secs = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _secs = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secs <= 0) {
        t.cancel();
      } else {
        setState(() => _secs--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Center(
        child: Text.rich(
          TextSpan(
            style: PwtType.label(color: PwtColors.textSec),
            children: [
              TextSpan(text: '${s['didntGetCode']} '),
              if (_secs > 0)
                TextSpan(text: '${s['resendIn']} ${_secs}s', style: const TextStyle(color: PwtColors.textTer, fontWeight: FontWeight.w600))
              else
                TextSpan(
                  text: s['resendCode'],
                  style: const TextStyle(color: PwtColors.brand, fontWeight: FontWeight.w700),
                  recognizer: (TapGestureRecognizer()..onTap = () => setState(_start)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Onboarding carousel ───
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.mode, required this.onDone});
  final AccountKind mode;
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final cards = widget.mode == AccountKind.business
        ? [
            (id: 'PW90', title: s['onbBrowseTitle']!, sub: s['onbBrowseSub']!),
            (id: 'S4', title: s['onbBizQuoteTitle']!, sub: s['onbBizQuoteSub']!),
            (id: 'PW50', title: s['onbBizFleetTitle']!, sub: s['onbBizFleetSub']!),
          ]
        : [
            (id: 'PW90', title: s['onbBrowseTitle']!, sub: s['onbBrowseSub']!),
            (id: 'S4', title: s['onbRentBuyTitle']!, sub: s['onbRentBuySub']!),
            (id: 'PW90CT', title: s['onbServiceTitle']!, sub: s['onbServiceSub']!),
          ];
    final card = cards[_idx];
    final product = MockData.productById(card.id)!;
    final isLast = _idx == cards.length - 1;

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
                  colors: [PwtColors.brand.withValues(alpha: 0.16), PwtColors.brand.withValues(alpha: 0)],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                  child: Row(
                    children: [
                      Image.asset('assets/new_logo.png', width: 26, height: 26),
                      const SizedBox(width: 8),
                      Text('PWT', style: PwtType.subtitle().copyWith(fontSize: 15)),
                      const Spacer(),
                      GestureDetector(onTap: widget.onDone, child: Text(s['skip']!, style: PwtType.label(color: PwtColors.textSec, weight: FontWeight.w600).copyWith(fontSize: 13.5))),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [product.tint.withValues(alpha: 0.19), product.tint.withValues(alpha: 0)], stops: const [0, 0.65]),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 480),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(anim), child: child)),
                        child: Image(key: ValueKey(card.id), image: pwtImage(product.img), height: 300, fit: BoxFit.contain),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: Column(
                          children: [
                            Text(card.title, textAlign: TextAlign.center, style: PwtType.headline(arabic: app.isArabic).copyWith(fontSize: 24, height: 1.2)),
                            const SizedBox(height: 10),
                            Text(card.sub, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec, arabic: app.isArabic).copyWith(fontSize: 13.5, height: 1.55)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < cards.length; i++)
                            GestureDetector(
                              onTap: () => setState(() => _idx = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _idx ? 22 : 6,
                                height: 6,
                                decoration: BoxDecoration(color: i == _idx ? PwtColors.brand : PwtColors.hairline2, borderRadius: BorderRadius.circular(999)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      PwtButton(
                        label: isLast ? s['done']! : s['next']!,
                        full: true,
                        trailing: isLast ? null : PwtIcons.arrow,
                        onPressed: () => isLast ? widget.onDone() : setState(() => _idx++),
                      ),
                    ],
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
