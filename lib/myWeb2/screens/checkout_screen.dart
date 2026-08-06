import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';
import '../widgets/stripe_card_field.dart';
import '../utils/stripe_web.dart';
import '../../const/stripe_config.dart';
import '../../Backend/Orders/place_order.dart';
import '../../Backend/Payments/initiate_payment.dart';
import '../../Backend/Payments/get_payment_status.dart';
import '../../Models/Payments/payment_model.dart';
import '../../Models/Orders/order_model.dart';
import '../../Backend/Addresses/get_addresses.dart';
import '../../Backend/Users/PaymentCards/get_payment_cards.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Models/address_model.dart';
import '../../Models/payment_card_model.dart';
import '../../Models/Reference/country_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _mode = 'buy';
  int _step = 2; // 2 Info, 3 Delivery/Rental, 4 Payment, 5 Review
  int _slot = 0;
  int _plan = 1; // 24/36/48 -> default 36 (Best Value)
  int _pay = 0; // card/apple/google
  bool _modeInit = false;

  // Contact
  late final _name = TextEditingController();
  late final _email = TextEditingController();
  late final _phone = TextEditingController();
  String _countryCode = '+971';

  // Address
  List<AddressModel> _addresses = [];
  bool _loadingAddresses = true;
  AddressModel? _selectedAddress;
  String? _addressLoadError;

  // Delivery date
  DateTime? _deliveryDate;

  // Country phone codes
  List<CountryModel> _countries = [];

  // Payment cards
  List<PaymentCard> _cards = [];
  bool _loadingCards = false;
  String? _cardsLoadError;
  int? _selectedCardId;
  bool _enterNewCard = false;

  // Embedded Stripe card element (web equivalent of myApp's native
  // PaymentSheet) — kept alive via GlobalKey across step changes so it
  // survives moving from the Payment step to the Review step. See
  // _needsStripeField / _persistentStripeField.
  final _stripeCardKey = GlobalKey<StripeCardFieldsState>();
  bool _stripeCardComplete = false;
  String? _stripeCardError;
  bool _stripeCardTouched = false;
  bool _confirmingCard = false;

  bool _placing = false;
  String? _placeError;
  Map<String, String?> _errors = {};

  // Payment processing (step 6) — used for the saved-card / Apple Pay /
  // Google Pay fallback path only. New-card payments are confirmed inline
  // via Stripe's Card Element and never reach this step.
  PaymentModel? _payment;
  OrderDetailModel? _pendingOrder;
  String? _payError;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  static const _pollMaxAttempts = 30; // 30 × 3 s = 90 s
  StreamSubscription<html.Event>? _visibilitySub;

  @override
  void initState() {
    super.initState();
    final u = AppState.instance.user;
    if (u != null) {
      _name.text = u.name ?? '';
      _email.text = u.email ?? '';
      final code = u.phoneCountryCode ?? '+971';
      final rawPhone = u.phone ?? '';
      _countryCode = code;
      _phone.text = rawPhone.startsWith(code) ? rawPhone.substring(code.length) : rawPhone;
    }
    _loadAddresses();
    _loadCountryCodes();
    // The payment gateway opens in a separate tab; our background poll can
    // exhaust its attempt limit while the user is still completing payment
    // there. Re-check the moment they switch back to this tab so a slow
    // (but successful) payment doesn't get reported as timed out.
    _visibilitySub = html.document.onVisibilityChange.listen((_) {
      if (html.document.visibilityState == 'visible') _onTabVisible();
    });
  }

  void _onTabVisible() {
    if (!mounted || _payment == null) return;
    if (_pollTimer == null || !_pollTimer!.isActive) {
      setState(() => _payError = null);
      _startPolling();
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

  @override
  void dispose() {
    _pollTimer?.cancel();
    _visibilitySub?.cancel();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollAttempts = 0;
    _pollTimer?.cancel();
    _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    if (!mounted || _payment == null) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      _pollTimer?.cancel();
      return;
    }
    _pollAttempts++;
    if (_pollAttempts > _pollMaxAttempts) {
      _pollTimer?.cancel();
      setState(() => _payError = 'Payment is taking longer than expected. Please check your orders or try again.');
      return;
    }

    final res = await getPaymentStatus(_payment!.paymentId);
    if (!mounted) return;

    if (!res.success || res.data == null) return; // retry on next tick

    final status = res.data!;
    if (status.isCaptured) {
      _pollTimer?.cancel();
      await AppState.instance.clearBackendCart();
      if (!mounted) return;
      Navigator.of(context).pushNamed('/confirmation', arguments: _pendingOrder);
    } else if (status.isFailed) {
      _pollTimer?.cancel();
      setState(() => _payError = status.failureReason ?? 'Payment failed. Please try again.');
    }
  }

  Future<void> _loadAddresses() async {
    final res = await getAddresses();
    if (!mounted) return;
    setState(() {
      _loadingAddresses = false;
      if (res.success && res.data != null) {
        _addresses = res.data!;
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.firstWhere(
            (a) => a.isDefault == true,
            orElse: () => _addresses.first,
          );
        }
      } else {
        _addressLoadError = res.message ?? 'Failed to load addresses.';
      }
    });
    if (_selectedAddress != null) await _selectAddress(_selectedAddress!);
  }

  /// Selects `a` as the delivery address and refreshes the VAT rate to match
  /// its country — VAT is computed from whichever address is active here.
  Future<void> _selectAddress(AddressModel a) async {
    setState(() { _selectedAddress = a; _errors.remove('address'); });
    await AppState.instance.setVatRateForAddress(a);
    if (mounted) setState(() {});
  }

  Future<void> _loadCards() async {
    setState(() { _loadingCards = true; _cardsLoadError = null; });
    final res = await getPaymentCards();
    if (!mounted) return;
    setState(() {
      _loadingCards = false;
      if (res.success && res.data != null) {
        _cards = res.data!;
        _cardsLoadError = null;
        if (_cards.isNotEmpty && _selectedCardId == null) {
          final def = _cards.where((c) => c.isDefault).firstOrNull;
          _selectedCardId = def?.id ?? _cards.first.id;
        }
      } else {
        _cardsLoadError = res.message ?? 'Failed to load saved cards.';
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
  String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _addrOneLiner(AddressModel a) =>
      [a.label, a.line1, a.city, a.country?.name].where((v) => v != null && (v?.isNotEmpty ?? false)).join(', ');

  final _plans = const [
    [24, 29, 'Most Popular'],
    [36, 25, 'Best Value'],
    [48, 22, 'Maximum Savings'],
  ];
  final _slots = const ['Morning · 8AM–12PM', 'Afternoon · 12PM–4PM', 'Evening · 4PM–7PM'];


  @override
  Widget build(BuildContext context) {
    if (!_modeInit) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String) {
        _mode = arg;
      } else {
        final cart = AppState.instance.cart;
        if (cart.isNotEmpty && cart.any((l) => l.mode == 'rent')) _mode = 'rent';
      }
      _modeInit = true;
    }
    final wide = MediaQuery.of(context).size.width > 900;
    final content = StoreScaffold(active: '/cart', showFooter: false, slivers: [
      SliverToBoxAdapter(
        child: Band(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _stepper(),
          const SizedBox(height: 24),
          Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: wide ? 3 : 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _panel(),
              // Keeps the mounted Stripe Card Element (and its DOM iframe)
              // alive via GlobalKey while the user moves from the Payment
              // step to the Review step, so it's still there to confirm
              // against when they place the order.
              if (_step != 4 && _needsStripeField)
                Offstage(offstage: true, child: SizedBox(width: 0, height: 0, child: _persistentStripeField())),
            ])),
            SizedBox(width: wide ? 22 : 0, height: wide ? 0 : 22),
            Expanded(flex: wide ? 2 : 0, child: _summary()),
          ]),
        ])),
      ),
    ]);

    if (!_confirmingCard) return content;
    return Stack(children: [
      content,
      Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: 340,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 38),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadow.lg,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.blue50, shape: BoxShape.circle),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.blue700),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                ExcludeSemantics(
                  child: Text(
                    'Confirming Your Payment',
                    textAlign: TextAlign.center,
                    style: AppText.h3.copyWith(fontSize: 18, decoration: TextDecoration.none),
                  ),
                ),
                const SizedBox(height: 10),
                ExcludeSemantics(
                  child: Text(
                    'Please don\'t close or refresh this page while we securely confirm your payment with Stripe.',
                    textAlign: TextAlign.center,
                    style: AppText.muted.copyWith(height: 1.5, decoration: TextDecoration.none),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _stepper() {
    final labels = ['Cart', 'Information', 'Delivery', 'Payment', 'Review'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: List.generate(labels.length, (i) {
        final n = i + 1;
        final done = n < _step;
        final active = n == _step;
        return Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: done ? AppColors.blue700 : active ? AppColors.blue700 : Colors.white, shape: BoxShape.circle, border: Border.all(color: done || active ? AppColors.blue700 : AppColors.line, width: 1.5)),
            child: done ? const Icon(Icons.check, size: 15, color: Colors.white) : Center(child: Text('$n', style: AppText.muted.copyWith(color: active ? Colors.white : AppColors.ink400, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 8),
          Text(labels[i], style: AppText.label.copyWith(color: active ? AppColors.ink900 : AppColors.ink400)),
          if (i < labels.length - 1) Container(width: 28, height: 1.5, margin: const EdgeInsets.symmetric(horizontal: 10), color: done ? AppColors.blue700 : AppColors.line),
        ]);
      })),
    );
  }

  Widget _card({required String title, Widget? action, required Widget child}) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(title, style: AppText.h3), const Spacer(), if (action != null) action]),
          const SizedBox(height: 16),
          child,
        ]),
      );

  Widget _panel() {
    switch (_step) {
      case 3:
        return _deliveryPanel();
      case 4:
        return _paymentPanel();
      case 5:
        return _reviewPanel();
      case 6:
        return _processingPanel();
      default:
        return _infoPanel();
    }
  }

  Widget _processingPanel() {
    if (_payError != null) {
      return _card(
        title: 'Payment Failed',
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 52, color: Color(0xFFDC2626)),
          const SizedBox(height: 16),
          Text(_payError!, style: AppText.body.copyWith(color: const Color(0xFFDC2626)), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PwtButton(
            'Try Again',
            onPressed: () => setState(() {
              _step = 5;
              _payError = null;
              _payment = null;
              _pendingOrder = null;
              _placeError = null;
            }),
          ),
        ]),
      );
    }
    final paymentUrl = _payment?.paymentUrl;
    return _card(
      title: 'Processing Payment',
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(height: 8),
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          paymentUrl != null && paymentUrl.isNotEmpty
              ? 'Complete your payment in the tab we just opened.'
              : 'Please wait while we process your payment…',
          style: AppText.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text('Do not close this page.', style: AppText.muted, textAlign: TextAlign.center),
        if (paymentUrl != null && paymentUrl.isNotEmpty) ...[
          const SizedBox(height: 20),
          TextButton(
            onPressed: _openPaymentUrl,
            child: const Text("Didn't see the payment tab? Open it again"),
          ),
        ],
      ]),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint, String? errorKey}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.label),
          const SizedBox(height: 7),
          TextField(
            controller: c,
            decoration: InputDecoration(
              hintText: hint ?? label,
              errorText: errorKey != null ? _errors[errorKey] : null,
            ),
            onChanged: errorKey != null ? (_) => setState(() => _errors.remove(errorKey)) : null,
          ),
        ]),
      );

  bool _validateStep2() {
    final e = <String, String?>{};
    if (_name.text.trim().isEmpty)  e['name']  = 'Full name is required';
    if (_email.text.trim().isEmpty) e['email'] = 'Email is required';
    if (_phone.text.trim().isEmpty) e['phone'] = 'Phone number is required';
    if (_selectedAddress == null)   e['address'] = 'Please select a delivery address';
    setState(() => _errors = e);
    return e.isEmpty;
  }

  bool _validateStep3() {
    if (_deliveryDate == null) {
      setState(() => _errors = {'deliveryDate': 'Please select a preferred delivery date'});
      return false;
    }
    setState(() => _errors = {});
    return true;
  }

  bool _validateStep4() {
    if (_pay != 0) return true;
    // Saved card selected
    if (_selectedCardId != null && !_enterNewCard) return true;
    // New card: Stripe's Card Element validates itself live via onChange.
    if (!_stripeCardComplete) {
      setState(() => _stripeCardTouched = true);
      return false;
    }
    return true;
  }

  bool get _needsStripeField => _pay == 0 && (_cardsLoadError != null || _cards.isEmpty || _enterNewCard);

  Widget _persistentStripeField() => StripeCardFields(
        key: _stripeCardKey,
        publishableKey: kStripePublishableKey,
        onChange: (complete, error) => setState(() {
          _stripeCardComplete = complete;
          _stripeCardError = error;
        }),
      );

  // ── Step 2: Information ──────────────────────────────────────

  Widget _infoPanel() {
    final loggedIn = AppState.instance.user != null;
    return Column(children: [
      if (!loggedIn)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: AppColors.blue200)),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.blue700),
            const SizedBox(width: 10),
            Expanded(child: Text('Sign in to auto-fill your details.', style: AppText.muted.copyWith(color: AppColors.blue700))),
            TextButton(onPressed: () => Navigator.of(context).pushNamed('/login'), child: const Text('Sign in')),
          ]),
        ),
      _card(title: 'Contact Information', child: Column(children: [
        _field('Full Name', _name, errorKey: 'name'),
        _field('Email Address', _email, errorKey: 'email'),
        _phoneField(),
      ])),
      _card(title: 'Delivery Address', child: _buildAddressSelector()),
      _nav(backLabel: 'Back to Cart', onBack: () => Navigator.of(context).pushNamed('/cart'), nextLabel: 'Continue', onNext: () {
        if (_loadingAddresses) return;
        if (_validateStep2()) setState(() => _step = 3);
      }),
    ]);
  }

  Widget _buildAddressSelector() {
    if (_loadingAddresses) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_addressLoadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          Text(_addressLoadError!, style: AppText.muted.copyWith(color: AppColors.danger)),
          const SizedBox(height: 12),
          PwtButton('Retry', variant: PwtBtn.outline, onPressed: () {
            setState(() { _loadingAddresses = true; _addressLoadError = null; });
            _loadAddresses();
          }),
        ]),
      );
    }
    if (_addresses.isEmpty) {
      return Column(children: [
        Text('No saved addresses found.', style: AppText.muted),
        const SizedBox(height: 10),
        PwtButton('Add an Address', variant: PwtBtn.outline, onPressed: () async {
          await Navigator.of(context).pushNamed('/profile');
          if (!mounted) return;
          setState(() { _loadingAddresses = true; _addressLoadError = null; });
          _loadAddresses();
        }),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ..._addresses.map((a) => _addressTile(a)),
      if (_errors['address'] != null)
        Padding(padding: const EdgeInsets.only(top: 4), child: Text(_errors['address']!, style: AppText.muted.copyWith(color: AppColors.danger))),
    ]);
  }

  Widget _addressTile(AddressModel a) {
    final sel = _selectedAddress?.id == a.id;
    return GestureDetector(
      onTap: () => _selectAddress(a),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? AppColors.blue50 : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: sel ? AppColors.blue600 : AppColors.line, width: sel ? 1.5 : 1),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: sel ? AppColors.blue700 : AppColors.ink300),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if ((a.label ?? '').isNotEmpty) Text(a.label!, style: AppText.label.copyWith(color: sel ? AppColors.blue700 : AppColors.ink900)),
            Text(_addrOneLiner(a), style: AppText.muted.copyWith(height: 1.5)),
          ])),
          if (a.isDefault == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.badgeBlueBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text('Default', style: AppText.muted.copyWith(fontSize: 11, color: AppColors.blue700, fontWeight: FontWeight.w700)),
            ),
        ]),
      ),
    );
  }

  Widget _phoneField() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Phone Number', style: AppText.label),
          const SizedBox(height: 7),
          Row(children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _countryCode,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.ink400),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink900),
                  items: _countries.isEmpty
                      ? [DropdownMenuItem(value: _countryCode, child: Text(_countryCode))]
                      : _countries.map((c) => DropdownMenuItem(
                          value: c.phoneCode!,
                          child: Text('${_checkoutFlagFromCode(c.code)} ${c.phoneCode}'),
                        )).toList(),
                  onChanged: (v) => setState(() => _countryCode = v!),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: '50 123 4567', errorText: _errors['phone']),
                onChanged: (_) => setState(() => _errors.remove('phone')),
              ),
            ),
          ]),
        ]),
      );

  // ── Step 3: Delivery ─────────────────────────────────────────

  Widget _deliveryPanel() {
    final addrLine = _selectedAddress != null ? _addrOneLiner(_selectedAddress!) : '—';
    return Column(children: [
      _card(
        title: 'Delivery Address',
        action: TextButton(onPressed: () => setState(() => _step = 2), child: const Text('Edit')),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if ((_selectedAddress?.label ?? '').isNotEmpty) Text(_selectedAddress!.label!, style: AppText.label),
            Text(addrLine, style: AppText.body.copyWith(height: 1.6)),
          ]),
        ),
      ),
      _card(title: 'Installation Details', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Preferred Delivery Date', style: AppText.label),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _deliveryDate != null ? AppColors.blue50 : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: _errors['deliveryDate'] != null ? AppColors.danger : (_deliveryDate != null ? AppColors.blue600 : AppColors.line),
                width: _deliveryDate != null ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined, size: 17, color: _deliveryDate != null ? AppColors.blue700 : AppColors.ink400),
              const SizedBox(width: 10),
              Expanded(child: Text(_deliveryDate != null ? _fmtDate(_deliveryDate!) : 'Select a preferred date', style: AppText.body.copyWith(color: _deliveryDate != null ? AppColors.ink900 : AppColors.ink400))),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.ink300),
            ]),
          ),
        ),
        if (_errors['deliveryDate'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errors['deliveryDate']!, style: AppText.muted.copyWith(color: AppColors.danger, fontSize: 12)),
          ),
        const SizedBox(height: 18),
        Text('Preferred Time Slot', style: AppText.label),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: List.generate(_slots.length, (i) {
          final on = _slot == i;
          return GestureDetector(
            onTap: () => setState(() => _slot = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: on ? AppColors.blue50 : Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: on ? AppColors.blue600 : AppColors.line, width: on ? 1.5 : 1)),
              child: Text(_slots[i], style: AppText.label.copyWith(color: on ? AppColors.blue700 : AppColors.ink700)),
            ),
          );
        })),
      ])),
      _nav(backLabel: 'Back', onBack: () => setState(() => _step = 2), nextLabel: 'Continue to Payment', onNext: () {
        if (!_validateStep3()) return;
        if (_pay == 0 && _cards.isEmpty && !_loadingCards) _loadCards();
        setState(() => _step = 4);
      }),
    ]);
  }

  Widget _rentPanel() {
    return Column(children: [
      _card(title: 'Choose Your Rental Plan', child: Column(children: List.generate(_plans.length, (i) {
        final on = _plan == i;
        final p = _plans[i];
        return GestureDetector(
          onTap: () => setState(() => _plan = i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: on ? AppColors.blue50 : Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: on ? AppColors.blue600 : AppColors.line, width: on ? 1.5 : 1)),
            child: Row(children: [
              Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: on ? AppColors.blue700 : AppColors.ink300, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${p[0]} Months', style: AppText.h3.copyWith(fontSize: 15)), Text(p[2] as String, style: AppText.muted)])),
              Text('£${p[1]} / mo', style: AppText.price.copyWith(fontSize: 17)),
            ]),
          ),
        );
      }))),
      _card(title: "What's Included", child: Column(children: ['Free installation', 'Regular maintenance', 'Filter replacements', '24/7 customer support', '2 years warranty'].map((t) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [const Icon(Icons.check, size: 18, color: AppColors.blue600), const SizedBox(width: 10), Text(t, style: AppText.body)]))).toList())),
      _nav(backLabel: 'Back', onBack: () => setState(() => _step = 2), nextLabel: 'Continue to Payment', onNext: () {
        if (!_validateStep3()) return;
        if (_pay == 0 && _cards.isEmpty && !_loadingCards) _loadCards();
        setState(() => _step = 4);
      }),
    ]);
  }

  // ── Step 4: Payment ──────────────────────────────────────────

  Widget _paymentPanel() {
    final methods = [
      ['Credit / Debit Card', Icons.credit_card],
      ['Apple Pay', Icons.apple],
      ['Google Pay', Icons.account_balance_wallet_outlined],
    ];
    return Column(children: [
      _card(title: 'Payment Method', child: Column(children: [
        ...List.generate(methods.length, (i) {
          final on = _pay == i;
          return Column(children: [
            GestureDetector(
              onTap: () {
                setState(() { _pay = i; });
                if (i == 0 && _cards.isEmpty && !_loadingCards) _loadCards();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: on ? AppColors.blue50 : Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: on ? AppColors.blue600 : AppColors.line, width: on ? 1.5 : 1)),
                child: Row(children: [
                  Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: on ? AppColors.blue700 : AppColors.ink300, size: 20),
                  const SizedBox(width: 12),
                  Icon(methods[i][1] as IconData, size: 20, color: AppColors.ink700),
                  const SizedBox(width: 10),
                  Text(methods[i][0] as String, style: AppText.label),
                ]),
              ),
            ),
            if (on && i == 0) Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _cardPaymentSection(),
            ),
          ]);
        }),
      ])),
      _nav(backLabel: 'Back', onBack: () => setState(() => _step = 3), nextLabel: 'Continue to Review', onNext: () { if (_validateStep4()) setState(() => _step = 5); }),
    ]);
  }

  Widget _cardPaymentSection() {
    final showNewCardForm = _cardsLoadError != null || _cards.isEmpty || _enterNewCard;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Saved cards
        if (_loadingCards)
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else ...[
          if (_cardsLoadError != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Couldn\'t load your saved cards. Enter a new card below, or retry.', style: AppText.muted.copyWith(color: AppColors.danger)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PwtButton('Retry loading saved cards', variant: PwtBtn.outline, onPressed: _loadCards),
            ),
          ],
          if (!showNewCardForm) ...[
            Text('Saved Cards', style: AppText.label),
            const SizedBox(height: 10),
            ..._cards.map((c) => _cardTile(c)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() { _enterNewCard = true; _selectedCardId = null; }),
              child: Row(children: [
                const Icon(Icons.add, size: 16, color: AppColors.blue700),
                const SizedBox(width: 6),
                Text('Use a different card', style: AppText.label.copyWith(color: AppColors.blue700)),
              ]),
            ),
            const SizedBox(height: 10),
          ] else ...[
            // New card form
            if (_cards.isNotEmpty && _cardsLoadError == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() { _enterNewCard = false; _selectedCardId = _cards.firstWhere((c) => c.isDefault, orElse: () => _cards.first).id; }),
                  child: Row(children: [
                    const Icon(Icons.arrow_back, size: 14, color: AppColors.blue700),
                    const SizedBox(width: 6),
                    Text('Use a saved card', style: AppText.label.copyWith(color: AppColors.blue700)),
                  ]),
                ),
              ),
            Text('Card Details', style: AppText.label),
            const SizedBox(height: 7),
            _persistentStripeField(),
            if (_stripeCardError != null) ...[
              const SizedBox(height: 6),
              Text(_stripeCardError!, style: AppText.muted.copyWith(color: AppColors.danger, fontSize: 12)),
            ] else if (_stripeCardTouched && !_stripeCardComplete) ...[
              const SizedBox(height: 6),
              Text('Enter your card details to continue.', style: AppText.muted.copyWith(color: AppColors.danger, fontSize: 12)),
            ],
          ],
        ],
      ]),
    );
  }

  Widget _cardTile(PaymentCard c) {
    final sel = _selectedCardId == c.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCardId = c.id),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? AppColors.blue50 : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: sel ? AppColors.blue600 : AppColors.line, width: sel ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: sel ? AppColors.blue700 : AppColors.ink300),
          const SizedBox(width: 12),
          const Icon(Icons.credit_card, size: 18, color: AppColors.ink600),
          const SizedBox(width: 8),
          Expanded(child: Text('${c.brand ?? 'Card'} •••• ${c.lastFour ?? ''}', style: AppText.label)),
          if (c.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.badgeBlueBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text('Default', style: AppText.muted.copyWith(fontSize: 11, color: AppColors.blue700, fontWeight: FontWeight.w700)),
            ),
        ]),
      ),
    );
  }

  // ── Step 5: Review ───────────────────────────────────────────

  Widget _reviewPanel() {
    Widget rev(String h, String body, int editStep) => _card(
      title: h,
      action: TextButton(onPressed: () => setState(() => _step = editStep), child: const Text('Edit')),
      child: Align(alignment: Alignment.centerLeft, child: Text(body, style: AppText.body.copyWith(height: 1.6))),
    );

    final addrText = _selectedAddress != null
        ? '${_name.text}\n${_addrOneLiner(_selectedAddress!)}'
        : '—';

    String deliveryText = 'Time: ${_slots[_slot]}';
    if (_deliveryDate != null) deliveryText = 'Date: ${_fmtDate(_deliveryDate!)}\n$deliveryText';

    String paymentText;
    if (_pay == 1) {
      paymentText = 'Apple Pay';
    } else if (_pay == 2) {
      paymentText = 'Google Pay';
    } else if (_selectedCardId != null && !_enterNewCard) {
      final card = _cards.where((c) => c.id == _selectedCardId).firstOrNull;
      paymentText = card != null ? '${card.brand ?? 'Card'} •••• ${card.lastFour ?? ''}' : 'Saved Card';
    } else {
      paymentText = 'Credit / Debit Card';
    }

    return Column(children: [
      rev('Contact', '${_name.text}\n${_email.text}\n$_countryCode ${_phone.text}', 2),
      rev('Delivery Address', addrText, 2),
      rev('Installation', deliveryText, 3),
      rev('Payment Method', paymentText, 4),
      _nav(backLabel: 'Back to Payment', onBack: () => setState(() => _step = 4)),
    ]);
  }

  // ── Shared ───────────────────────────────────────────────────

  Widget _nav({required String backLabel, required VoidCallback onBack, String? nextLabel, VoidCallback? onNext}) {
    return Row(children: [
      TextButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back, size: 16), label: Text(backLabel)),
      const Spacer(),
      if (nextLabel != null) PwtButton(nextLabel, icon: Icons.arrow_forward, onPressed: onNext),
    ]);
  }

  Future<void> _placeOrder() async {
    if (!_validateStep4()) {
      setState(() => _step = 4);
      return;
    }
    setState(() { _placing = true; _placeError = null; });

    final s = AppState.instance;
    final items = s.cart.map((l) => {
      'product_id': l.product.id,
      'quantity': l.qty,
      'term': l.mode,
    }).toList();

    final slotKey = ['morning', 'afternoon', 'evening'][_slot];
    final payMethod = ['card', 'apple_pay', 'google_pay'][_pay];
    final phone = '$_countryCode${_phone.text.trim()}';
    final dateStr = _deliveryDate != null ? _dateStr(_deliveryDate!) : null;

    // A new card is captured entirely by Stripe's embedded Card Element —
    // its real digits never touch our backend. /orders still requires
    // card_number/card_expiry to be present for payment_method=card, so we
    // send inert placeholders here; the actual charge is authorized purely
    // via Stripe's client_secret + confirmCardPayment below, never from
    // these fields.
    final usingSavedCard = _pay == 0 && !_enterNewCard && _selectedCardId != null;
    String? cardNumber;
    String? cardExpiry;
    String? cardCvc;
    if (_pay == 0) {
      if (usingSavedCard) {
        final saved = _cards.where((c) => c.id == _selectedCardId).firstOrNull;
        if (saved != null) {
          cardNumber = saved.cardNumberHash ?? saved.lastFour;
          cardExpiry = '${saved.expiryMonth}/${saved.expiryYear}';
          cardCvc    = saved.cvc;
        }
      } else {
        // Must satisfy the backend's format validation (digits only), but
        // is never actually used to charge anything — Stripe's client_secret
        // confirmation below is what authorizes the real card.
        cardNumber = '4242424242424242';
        cardExpiry = '12/99';
        cardCvc    = '000';
      }
    }

    final result = await placeOrder(
      items: items,
      customerName:      _name.text.trim().isEmpty  ? null : _name.text.trim(),
      customerEmail:     _email.text.trim().isEmpty  ? null : _email.text.trim(),
      customerPhone:     _phone.text.trim().isEmpty  ? null : phone,
      deliveryAddressId: _selectedAddress?.id,
      deliveryDate:      dateStr,
      term:              _mode,
      paymentMethod:     payMethod,
      deliveryTimeSlot:  slotKey,
      cardNumber:        cardNumber,
      cardExpiry:        cardExpiry,
      cardCvc:           cardCvc,
      promoCode:         s.appliedPromoCode,
    );

    if (!mounted) return;

    if (!result.success || result.data == null) {
      setState(() {
        _placing = false;
        _placeError = result.message ?? result.error ?? 'Failed to place order. Please try again.';
      });
      return;
    }

    final order = result.data!;

    final payRes = await initiatePayment(
      orderId: order.id,
      paymentMethod: payMethod,
    );

    if (!mounted) return;
    setState(() => _placing = false);

    if (!payRes.success || payRes.data == null) {
      setState(() => _placeError = payRes.message ?? payRes.error ?? 'Failed to initiate payment. Please try again.');
      return;
    }

    if (payMethod == 'cod') {
      // COD: auto-confirmed by backend, go to confirmation immediately
      await s.clearBackendCart();
      if (!mounted) return;
      Navigator.of(context).pushNamed('/confirmation', arguments: order);
      return;
    }

    final clientSecret = payRes.data!.clientSecret;
    if (_pay == 0 && !usingSavedCard && clientSecret != null && clientSecret.isNotEmpty) {
      // New card: confirm the PaymentIntent right here against the still-
      // mounted Stripe Card Element — no redirect, no polling needed.
      setState(() => _confirmingCard = true);
      final cardState = _stripeCardKey.currentState;
      final cardResult = cardState != null
          ? await cardState.confirmPayment(clientSecret)
          : StripeCardResult(success: false, errorMessage: 'Card details were lost — please re-enter your card and try again.');
      if (!mounted) return;
      setState(() => _confirmingCard = false);
      if (!cardResult.success) {
        setState(() => _placeError = cardResult.errorMessage ?? 'Payment failed. Please try again.');
        return;
      }
      await s.clearBackendCart();
      if (!mounted) return;
      Navigator.of(context).pushNamed('/confirmation', arguments: order);
      return;
    }

    // Saved card / Apple Pay / Google Pay: no client-side confirmation path
    // wired up yet — fall back to the hosted-checkout redirect + poll flow.
    setState(() {
      _payment = payRes.data;
      _pendingOrder = order;
      _payError = null;
      _step = 6;
    });
    _openPaymentUrl();
    _startPolling();
  }

  void _openPaymentUrl() {
    final url = _payment?.paymentUrl;
    if (url != null && url.isNotEmpty) {
      html.window.open(url, '_blank');
    }
  }

  Widget _summary() {
    final s = AppState.instance;
    final onReview = _step == 5;
    final onProcessing = _step == 6;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('Order Summary', style: AppText.h3), const Spacer(), TextButton(onPressed: () => Navigator.of(context).pushNamed('/cart'), child: const Text('Edit Cart'))]),
        const SizedBox(height: 8),
        ...s.cart.map((l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(6),
                  child: l.product.primaryImageUrl != null
                      ? Image.network(l.product.primaryImageUrl!, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 24, color: AppColors.blue200))
                      : const Icon(Icons.water_drop_outlined, size: 24, color: AppColors.blue200),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.product.code ?? '', style: AppText.label), Text('${l.mode == 'rent' ? 'Rent' : 'Buy'} · Qty ${l.qty}', style: AppText.muted)])),
              ]),
            )),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: AppColors.line)),
        _r('Subtotal', moneyText(s.subtotal, AppText.label.copyWith(color: AppColors.ink900))),
        _r('Delivery', Text('FREE', style: AppText.label.copyWith(color: AppColors.green600))),
        _r('Installation', Text('FREE', style: AppText.label.copyWith(color: AppColors.green600))),
        _r('VAT (${_fmtPercent(s.vatRatePercent)}%)', moneyText(s.vat, AppText.label.copyWith(color: AppColors.ink900))),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.line)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: AppText.h3), moneyText(s.total, AppText.h2.copyWith(fontSize: 20), symbolSize: 15)]),
        const SizedBox(height: 16),
        if (onReview) ...[
          PwtButton(
            _placing ? 'Placing Order…' : 'Place Order Securely',
            icon: Icons.lock_outline,
            fullWidth: true,
            onPressed: _placing ? null : _placeOrder,
          ),
          if (_placeError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: const Color(0xFFFECACA))),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 15, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(child: Text(_placeError!, style: AppText.muted.copyWith(color: const Color(0xFFDC2626)))),
              ]),
            ),
          ],
        ] else if (!onProcessing)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Row(children: [const Icon(Icons.lock_outline, size: 15, color: AppColors.ink500), const SizedBox(width: 8), Text('Safe & Secure Checkout', style: AppText.muted)]),
          ),
      ]),
    );
  }

  Widget _r(String k, Widget v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: AppText.body.copyWith(color: AppColors.ink600)), v]),
      );

}

String _fmtPercent(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

String _checkoutFlagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}
