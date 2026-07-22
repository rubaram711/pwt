// Account area: Profile (individual + company), Settings, Invoices, Orders.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/form_field.dart';
import '../widgets/layout.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Backend/Users/update_user.dart';
import '../../Backend/Addresses/get_addresses.dart';
import '../../Backend/Addresses/create_address.dart';
import '../../Backend/Addresses/update_address.dart';
import '../../Backend/Addresses/delete_address.dart';
import '../../Backend/Users/PaymentCards/get_payment_cards.dart';
import '../../Backend/Users/PaymentCards/create_payment_card.dart';
import '../../Backend/Users/PaymentCards/delete_payment_card.dart';
import '../../Backend/Users/PaymentCards/set_default_payment_card.dart';
import '../../Models/address_model.dart';
import '../../Models/payment_card_model.dart';
import '../../Backend/Orders/get_orders.dart';
import '../../Backend/Orders/get_order_details.dart';
import '../../Models/Orders/order_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Backend/Reference/get_cities_for_country.dart';
import '../../Models/Reference/country_model.dart';
import '../../Models/Reference/city_model.dart';

// ═══════════════════════ PROFILE ═══════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user, required this.role});
  final AppUser user;
  final AccountKind role;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<PaymentCard> _cards = [];
  bool _loadingCards = false;
  String? _cardsError;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() { _loadingCards = true; _cardsError = null; });
    final res = await getPaymentCards();
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _cards = res.data!; _loadingCards = false; });
    } else {
      setState(() { _loadingCards = false; _cardsError = res.message ?? 'Failed to load cards.'; });
    }
  }

  Future<void> _deleteCard(PaymentCard c) async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Remove card?',
      body: 'Are you sure you want to remove this card?',
      keepLabel: 'Keep',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !mounted) return;
    final res = await deletePaymentCard(c.id);
    if (!mounted) return;
    if (res.success) { _loadCards(); } else { _toast(res.message ?? 'Failed to delete card.'); }
  }

  Future<void> _setDefaultCard(PaymentCard c) async {
    final res = await setDefaultPaymentCard(c.id);
    if (!mounted) return;
    if (res.success) { _loadCards(); } else { _toast(res.message ?? 'Failed to update card.'); }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: PwtColors.textPri),
  );

  void _addCardSheet(Map<String, String> s) {
    final holderCtrl = TextEditingController();
    final numCtrl    = TextEditingController();
    final monthCtrl  = TextEditingController();
    final yearCtrl   = TextEditingController();
    final cvcCtrl    = TextEditingController();
    bool def = false;
    String? holderErr, numErr, monthErr, yearErr, cvcErr;

    bool validate(void Function(void Function()) set) {
      final digits     = numCtrl.text.replaceAll(RegExp(r'\D'), '');
      final monthVal   = monthCtrl.text.trim();
      final yearVal    = yearCtrl.text.trim();
      final cvcVal     = cvcCtrl.text.trim();

      final hErr = holderCtrl.text.trim().isEmpty ? 'Cardholder name is required' : null;
      final nErr = digits.isEmpty
          ? 'Card number is required'
          : digits.length != 16
              ? 'Enter a valid 16-digit card number'
              : null;
      final mErr = !RegExp(r'^\d{2}$').hasMatch(monthVal) ? 'Must be 2 digits (e.g. 08)' : null;
      final yErr = !RegExp(r'^\d{4}$').hasMatch(yearVal)  ? 'Must be 4 digits (e.g. 2027)' : null;
      final cErr = !RegExp(r'^\d{3,4}$').hasMatch(cvcVal) ? '3–4 digits' : null;

      set(() { holderErr = hErr; numErr = nErr; monthErr = mErr; yearErr = yErr; cvcErr = cErr; });
      return hErr == null && nErr == null && mErr == null && yErr == null && cErr == null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PwtColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(PwtRadius.sheet))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 22, bottom: MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (ctx, set) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: Text(s['addCardDetails'] ?? 'Add Card', style: PwtType.title().copyWith(fontSize: 19))),
                  IconButton(icon: const Icon(PwtIcons.close), onPressed: () => Navigator.pop(ctx), color: PwtColors.textPri),
                ]),
                const SizedBox(height: 12),
                PwtField(label: s['cardholderName']!, controller: holderCtrl, onChanged: (_) => set(() => holderErr = null)),
                if (holderErr != null) _fieldError(holderErr!),
                const SizedBox(height: 10),
                PwtField(
                  label: s['cardNumber']!,
                  controller: numCtrl,
                  forceLtr: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_CardNumberFormatter()],
                  onChanged: (_) => set(() => numErr = null),
                ),
                if (numErr != null) _fieldError(numErr!),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    PwtField(
                      label: 'Month (MM)',
                      controller: monthCtrl,
                      forceLtr: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => set(() => monthErr = null),
                    ),
                    if (monthErr != null) _fieldError(monthErr!),
                  ])),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    PwtField(
                      label: 'Year (YYYY)',
                      controller: yearCtrl,
                      forceLtr: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => set(() => yearErr = null),
                    ),
                    if (yearErr != null) _fieldError(yearErr!),
                  ])),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    PwtField(
                      label: 'CVC',
                      controller: cvcCtrl,
                      forceLtr: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(4)],
                      onChanged: (_) => set(() => cvcErr = null),
                    ),
                    if (cvcErr != null) _fieldError(cvcErr!),
                  ])),
                ]),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => set(() => def = !def),
                  child: Row(children: [
                    _checkbox(def),
                    const SizedBox(width: 10),
                    Text(s['setDefault']!, style: PwtType.label()),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: PwtButton(label: s['cancel']!, variant: PwtButtonVariant.secondary, full: true, onPressed: () => Navigator.pop(ctx))),
                  const SizedBox(width: 10),
                  Expanded(child: PwtButton(
                    label: s['addCardDetails'] ?? 'Add Card',
                    full: true,
                    onPressed: () {
                      if (!validate(set)) return;
                      Navigator.pop(ctx);
                      final digits   = numCtrl.text.replaceAll(RegExp(r'\D'), '');
                      final lastFour = digits.substring(digits.length - 4);
                      final brand    = digits.startsWith('4') ? 'Visa' : digits.startsWith('5') ? 'Mastercard' : 'Card';
                      createPaymentCard(
                        brand: brand,
                        lastFour: lastFour,
                        cardNumberHash: digits,
                        expiryMonth: monthCtrl.text.trim(),
                        expiryYear: yearCtrl.text.trim(),
                        cardholderName: holderCtrl.text.trim(),
                        cvc: cvcCtrl.text.trim(),
                        isDefault: def,
                      ).then((res) {
                        if (!mounted) return;
                        if (res.success) { _loadCards(); } else { _toast(res.message ?? 'Failed to add card.'); }
                      });
                    },
                  )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldError(String msg) => Padding(
    padding: const EdgeInsets.only(top: 5, left: 2),
    child: Text(msg, style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 12)),
  );

  Widget _checkbox(bool checked) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: checked ? PwtColors.brand : PwtColors.surface,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: checked ? PwtColors.brand : PwtColors.hairline2, width: 1.5),
    ),
    child: checked ? const Icon(PwtIcons.check, size: 14, color: Colors.white) : null,
  );

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final u = web.AppState.instance.user;

    return DetailScaffold(
      title: s['profile'],
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // header card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: PwtCard(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [PwtColors.brand, PwtColors.brandDeep])),
                  alignment: Alignment.center,
                  child: Text(u?.initials ?? 'PW', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u?.name ?? '', style: PwtType.subtitle().copyWith(fontSize: 17)),
                  const SizedBox(height: 3),
                  if ((u?.phone ?? '').isNotEmpty)
                    Directionality(textDirection: TextDirection.ltr, child: Text(u!.phone!, style: PwtType.mono(size: 12, color: PwtColors.textTer))),
                  const SizedBox(height: 8),
                  Pill(label: widget.role == AccountKind.business ? s['business']! : s['individual']!),
                ])),
              ]),
            ),
          ),
          // personal / company info + addresses
          if (widget.role == AccountKind.business)
            _CompanyProfile(user: widget.user, onUserUpdated: () => setState(() {}))
          else
            _IndividualProfile(user: widget.user, onUserUpdated: () => setState(() {})),
          // payment details
          Section(
            title: s['paymentDetails']!,
            trailing: GestureDetector(
              onTap: () => _addCardSheet(s),
              child: Text('+ ${s['addCardDetails'] ?? 'Add'}', style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 12.5)),
            ),
            child: _loadingCards
                ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator(strokeWidth: 2)))
                : _cardsError != null
                    ? Text(_cardsError!, style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 13))
                    : _cards.isEmpty
                        ? PwtCard(
                            padding: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(s['noCardsYet']!, style: PwtType.label(weight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(s['noCardsSub']!, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
                              ]),
                            ),
                          )
                        : PwtCard(
                            padding: EdgeInsets.zero,
                            child: Column(children: [
                              for (int i = 0; i < _cards.length; i++)
                                _cardRow(_cards[i], last: i == _cards.length - 1, s: s),
                            ]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _cardRow(PaymentCard c, {required bool last, required Map<String, String> s}) {
    final brandLower  = c.brand.toLowerCase();
    final displayName = brandLower == 'visa' ? 'Visa' : brandLower.contains('master') ? 'Mastercard' : c.brand;
    return ListRow(
      leading: PwtIcons.card,
      title: '$displayName ···· ${c.lastFour}',
      sub: c.isDefault ? s['primary'] ?? 'Primary' : 'Exp ${c.expiryMonth}/${c.expiryYear}',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (!c.isDefault)
          GestureDetector(
            onTap: () => _setDefaultCard(c),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(s['setDefault']!, style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 12)),
            ),
          ),
        GestureDetector(
          onTap: () => _deleteCard(c),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(PwtIcons.trash, size: 18, color: PwtColors.error),
          ),
        ),
      ]),
      last: last,
    );
  }
}

// ─── Individual profile + addresses ───
class _IndividualProfile extends StatefulWidget {
  const _IndividualProfile({required this.user, required this.onUserUpdated});
  final AppUser user;
  final VoidCallback onUserUpdated;

  @override
  State<_IndividualProfile> createState() => _IndividualProfileState();
}

class _IndividualProfileState extends State<_IndividualProfile> {
  bool _edit = false;
  bool _saving = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  String _phoneCc = '+971';
  List<CountryModel> _countries = [];

  List<AddressModel> _addresses = [];
  bool _loadingAddr = false;
  String? _addrError;

  @override
  void initState() {
    super.initState();
    final u = web.AppState.instance.user;
    _nameCtrl  = TextEditingController(text: u?.name ?? widget.user.name);
    _emailCtrl = TextEditingController(text: u?.email ?? widget.user.email);
    final code = u?.phoneCountryCode ?? '+971';
    final rawPhone = u?.phone ?? '';
    _phoneCc = code;
    _phoneCtrl = TextEditingController(
      text: rawPhone.startsWith(code) ? rawPhone.substring(code.length).trim() : rawPhone,
    );
    _loadAddresses();
    _loadCountryCodes();
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() { _loadingAddr = true; _addrError = null; });
    final res = await getAddresses();
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _addresses = res.data!; _loadingAddr = false; });
    } else {
      setState(() { _loadingAddr = false; _addrError = res.message ?? 'Failed to load addresses.'; });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final phoneNum = _phoneCtrl.text.trim();
    print('[IndProfile._save] name="${_nameCtrl.text.trim()}" email="${_emailCtrl.text.trim()}" phone="$phoneNum" cc="$_phoneCc" currentPassword="${web.AppState.instance.currentPassword}"');
    final res = await updateProfile(
      name:             _nameCtrl.text.trim().isEmpty  ? null : _nameCtrl.text.trim(),
      email:            _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone:            phoneNum,
      phoneCountryCode: _phoneCc,
      currentPassword:  web.AppState.instance.currentPassword,
    );
    if (!mounted) return;
    print('[IndProfile._save] res.success=${res.success} res.data=${res.data?.name} / ${res.data?.email} / ${res.data?.phone} res.message=${res.message}');
    setState(() => _saving = false);
    if (res.success && res.data != null) {
      print('[IndProfile._save] updating AppState.user => ${res.data!.name}');
      await web.AppState.instance.persistUser(res.data!);
      print('[IndProfile._save] AppState.user is now => ${web.AppState.instance.user?.name}');
      setState(() => _edit = false);
      widget.onUserUpdated();
      _toast('Profile updated.');
    } else {
      print('[IndProfile._save] NOT updating state: success=${res.success} data=${res.data}');
      _toast(res.message ?? 'Failed to save profile.');
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: PwtColors.textPri),
  );

  void _addressSheet({AddressModel? edit}) {
    final labelCtrl = TextEditingController(text: edit?.label ?? '');
    final line1Ctrl = TextEditingController(text: edit?.line1 ?? '');
    final line2Ctrl = TextEditingController(text: edit?.line2 ?? '');
    final pcCtrl    = TextEditingController(text: edit?.postalCode ?? '');
    bool def = edit?.isDefault ?? false;
    CountryModel? selCountry = edit?.country?.code != null
        ? _countries.where((c) => c.code?.toLowerCase() == edit!.country!.code!.toLowerCase()).firstOrNull
        : null;
    CityModel? selCity;
    List<CityModel> cities = [];
    bool loadingCities = false;
    bool citiesLoaded = false;
    bool saving = false;
    String? sheetError;
    final s = Strings.of(context.read<AppState>().lang);

    Future<void> loadCities(void Function(void Function()) set, CountryModel c) async {
      set(() { cities = []; selCity = null; loadingCities = true; citiesLoaded = false; });
      final res = await getCitiesForCountry(c.code ?? '');
      set(() {
        loadingCities = false;
        citiesLoaded = true;
        cities = res.success ? res.data ?? [] : [];
        if (edit?.city != null) {
          selCity = cities.where((ci) => ci.name?.toLowerCase() == edit!.city!.toLowerCase()).firstOrNull;
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PwtColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(PwtRadius.sheet))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 22, bottom: MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (ctx, set) {
              if (selCountry != null && !citiesLoaded && !loadingCities) {
                loadCities(set, selCountry!);
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(child: Text(edit == null ? s['addAddress']! : s['edit']!, style: PwtType.title().copyWith(fontSize: 19))),
                    IconButton(icon: const Icon(PwtIcons.close), onPressed: saving ? null : () => Navigator.pop(ctx), color: PwtColors.textPri),
                  ]),
                  const SizedBox(height: 12),
                  PwtField(label: 'Label', controller: labelCtrl, onChanged: (_) {}),
                  const SizedBox(height: 10),
                  PwtField(label: 'Address line 1', controller: line1Ctrl, onChanged: (_) {}),
                  const SizedBox(height: 10),
                  PwtField(label: 'Address line 2 (optional)', controller: line2Ctrl, onChanged: (_) {}),
                  const SizedBox(height: 10),
                  // Country dropdown
                  Text('Country', style: PwtType.label()),
                  const SizedBox(height: 7),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CountryModel>(
                        value: selCountry,
                        isExpanded: true,
                        isDense: true,
                        hint: Text('Select country', style: PwtType.body(color: PwtColors.textTer)),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: PwtColors.textTer),
                        items: _countries.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${_accountFlagFromCode(c.code)} ${c.name ?? c.code ?? ''}'),
                        )).toList(),
                        onChanged: (c) {
                          set(() { selCountry = c; selCity = null; cities = []; citiesLoaded = false; });
                          if (c != null) loadCities(set, c);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // City dropdown
                  Text('City', style: PwtType.label()),
                  const SizedBox(height: 7),
                  if (loadingCities)
                    const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  else
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CityModel>(
                          value: selCity,
                          isExpanded: true,
                          isDense: true,
                          hint: Text(selCountry == null ? 'Select a country first' : 'Select city', style: PwtType.body(color: PwtColors.textTer)),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: PwtColors.textTer),
                          items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name ?? ''))).toList(),
                          onChanged: selCountry == null ? null : (c) => set(() => selCity = c),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  PwtField(label: 'Postcode', controller: pcCtrl, onChanged: (_) {}),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => set(() => def = !def),
                    child: Row(children: [
                      _checkbox(def),
                      const SizedBox(width: 10),
                      Text(s['setDefault']!, style: PwtType.label()),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  if (sheetError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(sheetError!, style: PwtType.body(color: PwtColors.error)),
                    ),
                  Row(children: [
                    Expanded(child: PwtButton(label: s['cancel']!, variant: PwtButtonVariant.secondary, full: true, onPressed: saving ? null : () => Navigator.pop(ctx))),
                    const SizedBox(width: 10),
                    Expanded(child: saving
                      ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                      : PwtButton(
                          label: edit == null ? s['addAddress']! : s['saved']!,
                          full: true,
                          onPressed: () async {
                            set(() { saving = true; sheetError = null; });
                            final u = web.AppState.instance.user;
                            final cityName = selCity?.name ?? '';
                            final res = edit != null && edit.id != null
                                ? await updateAddress(
                                    addressId: edit.id!,
                                    label: labelCtrl.text.trim().isEmpty ? null : labelCtrl.text.trim(),
                                    line1: line1Ctrl.text.trim().isEmpty ? null : line1Ctrl.text.trim(),
                                    line2: line2Ctrl.text.trim().isEmpty ? null : line2Ctrl.text.trim(),
                                    city: cityName.isEmpty ? null : cityName,
                                    postalCode: pcCtrl.text.trim().isEmpty ? null : pcCtrl.text.trim(),
                                    countryId: selCountry?.id,
                                    isDefault: def,
                                    recipientName: u?.name,
                                    recipientPhone: u?.phone,
                                  )
                                : await createAddress(
                                    label: labelCtrl.text.trim().isEmpty ? 'Address' : labelCtrl.text.trim(),
                                    line1: line1Ctrl.text.trim(),
                                    line2: line2Ctrl.text.trim().isEmpty ? null : line2Ctrl.text.trim(),
                                    city: cityName.isEmpty ? null : cityName,
                                    postalCode: pcCtrl.text.trim().isEmpty ? null : pcCtrl.text.trim(),
                                    countryId: selCountry?.id,
                                    isDefault: def,
                                    recipientName: u?.name,
                                    recipientPhone: u?.phone,
                                  );
                            if (!ctx.mounted) return;
                            if (res.success) {
                              Navigator.pop(ctx);
                              if (mounted) _loadAddresses();
                            } else {
                              final fieldErrors = res.errors?.values.expand((e) => e).join(' ');
                              set(() {
                                saving = false;
                                sheetError = fieldErrors?.isNotEmpty == true ? fieldErrors : (res.message ?? 'Failed to save address.');
                              });
                            }
                          },
                        ),
                    ),
                  ]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAddress(AddressModel a) async {
    if (a.id == null) return;
    final confirmed = await showConfirmSheet(
      context,
      title: 'Remove address?',
      body: 'Are you sure you want to remove this address?',
      keepLabel: 'Keep',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !mounted) return;
    final res = await deleteAddress(a.id!);
    if (!mounted) return;
    if (res.success) { _loadAddresses(); } else { _toast(res.message ?? 'Failed to remove address.'); }
  }

  Widget _checkbox(bool checked) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: checked ? PwtColors.brand : PwtColors.surface,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: checked ? PwtColors.brand : PwtColors.hairline2, width: 1.5),
    ),
    child: checked ? const Icon(PwtIcons.check, size: 14, color: Colors.white) : null,
  );

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final u = web.AppState.instance.user;
    return Column(children: [
      Section(
        title: s['personal']!,
        trailing: GestureDetector(
          onTap: () {
            if (_edit) {
              _save();
            } else {
              setState(() => _edit = true);
            }
          },
          child: Text(
            _saving ? '…' : (_edit ? 'Save changes' : s['edit']!),
            style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 12.5),
          ),
        ),
        child: _edit
            ? Column(children: [
                PwtField(label: s['fullName']!, controller: _nameCtrl),
                const SizedBox(height: 10),
                PwtField(label: s['email']!, controller: _emailCtrl, forceLtr: true, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                // Phone with country code
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Phone', style: PwtType.label()),
                  const SizedBox(height: 7),
                  Row(children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _phoneCc,
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: PwtColors.textTer),
                          style: PwtType.label().copyWith(fontSize: 14),
                          items: _countries.isEmpty
                              ? [DropdownMenuItem(value: _phoneCc, child: Text(_phoneCc))]
                              : _countries.map((c) => DropdownMenuItem(
                                  value: c.phoneCode!,
                                  child: Text('${_accountFlagFromCode(c.code)} ${c.phoneCode}'),
                                )).toList(),
                          onChanged: (v) => setState(() => _phoneCc = v!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        style: PwtType.body(weight: FontWeight.w500),
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                      ),
                    )),
                  ]),
                ]),
              ])
            : PwtCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  ListRow(leading: PwtIcons.user, title: u?.name ?? widget.user.name, sub: s['fullName']),
                  ListRow(leading: PwtIcons.message, title: u?.email ?? widget.user.email, sub: s['email']),
                  ListRow(leading: PwtIcons.phone, title: u?.phone ?? widget.user.phone, sub: s['phoneNumber'], last: true),
                ]),
              ),
      ),
      Section(
        title: s['savedAddresses']!,
        trailing: GestureDetector(
          onTap: () => _addressSheet(),
          child: Text('+ ${s['addAddress']!}', style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 12.5)),
        ),
        child: _loadingAddr
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator(strokeWidth: 2)))
            : _addrError != null
                ? Text(_addrError!, style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 13))
                : _addresses.isEmpty
                    ? PwtCard(
                        padding: const EdgeInsets.all(16),
                        child: Text('No saved addresses.', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
                      )
                    : Column(children: [
                        for (final a in _addresses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AddressCard(
                              address: a,
                              onEdit: () => _addressSheet(edit: a),
                              onSetDefault: () async {
                                if (a.id == null) return;
                                await updateAddress(addressId: a.id!, isDefault: true);
                                if (mounted) _loadAddresses();
                              },
                              onRemove: () => _deleteAddress(a),
                            ),
                          ),
                      ]),
      ),
    ]);
  }
}

// ─── Address card (uses AddressModel) ───
class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onSetDefault, required this.onEdit, required this.onRemove});
  final AddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  String get _fullLine {
    return [address.line1, address.line2, address.city, address.postalCode]
        .where((s) => s != null && s!.isNotEmpty)
        .cast<String>()
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return Container(
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: PwtColors.hairline),
        borderRadius: BorderRadius.circular(PwtRadius.card),
        boxShadow: PwtShadows.e1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(PwtIcons.pin, size: 16, color: PwtColors.brand),
                const SizedBox(width: 8),
                Text(address.label ?? '', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14.5)),
                const SizedBox(width: 8),
                if (address.isDefault == true) Pill(label: s['defaultAddr']!, color: PwtColors.success),
              ]),
              const SizedBox(height: 6),
              Text(_fullLine, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13, height: 1.5)),
            ]),
          ),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
            child: Row(children: [
              if (address.isDefault != true) _action(s['setDefault']!, null, onSetDefault),
              _action(s['edit']!, PwtIcons.edit, onEdit),
              _action(s['remove']!, PwtIcons.trash, onRemove, danger: true),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _action(String label, IconData? icon, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? PwtColors.error : PwtColors.brand;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: PwtColors.hairline))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
              Text(label, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Company profile ───
class _CompanyProfile extends StatefulWidget {
  const _CompanyProfile({required this.user, required this.onUserUpdated});
  final AppUser user;
  final VoidCallback onUserUpdated;

  @override
  State<_CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<_CompanyProfile> {
  bool _edit = false;
  bool _saving = false;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  String _phoneCc = '+971';
  List<CountryModel> _countries = [];

  List<AddressModel> _addresses = [];
  bool _loadingAddr = false;
  String? _addrError;

  Company get _c => widget.user.company ?? const Company(name: '', trn: '', industry: '', address: '', contact: '', email: '');

  @override
  void initState() {
    super.initState();
    final u = web.AppState.instance.user;
    _companyCtrl = TextEditingController(text: u?.companyName ?? _c.name);
    _nameCtrl    = TextEditingController(text: u?.name ?? _c.contact);
    _emailCtrl   = TextEditingController(text: u?.email ?? _c.email);
    final code = u?.phoneCountryCode ?? '+971';
    final rawPhone = u?.phone ?? '';
    _phoneCc = code;
    _phoneCtrl = TextEditingController(
      text: rawPhone.startsWith(code) ? rawPhone.substring(code.length).trim() : rawPhone,
    );
    _loadAddresses();
    _loadCountryCodes();
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
    _companyCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() { _loadingAddr = true; _addrError = null; });
    final res = await getAddresses();
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _addresses = res.data!; _loadingAddr = false; });
    } else {
      setState(() { _loadingAddr = false; _addrError = res.message ?? 'Failed to load addresses.'; });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final phoneNum = _phoneCtrl.text.trim();
    print('[BizProfile._save] company="${_companyCtrl.text.trim()}" name="${_nameCtrl.text.trim()}" email="${_emailCtrl.text.trim()}" phone="$phoneNum" cc="$_phoneCc" currentPassword="${web.AppState.instance.currentPassword}"');
    final res = await updateProfile(
      name:             _nameCtrl.text.trim().isEmpty    ? null : _nameCtrl.text.trim(),
      email:            _emailCtrl.text.trim().isEmpty   ? null : _emailCtrl.text.trim(),
      companyName:      _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      phone:            phoneNum,
      phoneCountryCode: _phoneCc,
      currentPassword:  web.AppState.instance.currentPassword,
    );
    if (!mounted) return;
    print('[BizProfile._save] res.success=${res.success} res.data=${res.data?.name} / ${res.data?.email} / ${res.data?.companyName} res.message=${res.message}');
    setState(() => _saving = false);
    if (res.success && res.data != null) {
      print('[BizProfile._save] updating AppState.user => ${res.data!.name} / ${res.data!.companyName}');
      await web.AppState.instance.persistUser(res.data!);
      print('[BizProfile._save] AppState.user is now => ${web.AppState.instance.user?.name}');
      setState(() => _edit = false);
      widget.onUserUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.'), behavior: SnackBarBehavior.floating, backgroundColor: PwtColors.textPri),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Failed to save profile.'), behavior: SnackBarBehavior.floating, backgroundColor: PwtColors.error),
      );
    }
  }

  void _addressSheet({AddressModel? edit}) {
    final labelCtrl = TextEditingController(text: edit?.label ?? '');
    final line1Ctrl = TextEditingController(text: edit?.line1 ?? '');
    final line2Ctrl = TextEditingController(text: edit?.line2 ?? '');
    final pcCtrl    = TextEditingController(text: edit?.postalCode ?? '');
    bool def = edit?.isDefault ?? false;
    CountryModel? selCountry = edit?.country?.code != null
        ? _countries.where((c) => c.code?.toLowerCase() == edit!.country!.code!.toLowerCase()).firstOrNull
        : null;
    CityModel? selCity;
    List<CityModel> cities = [];
    bool loadingCities = false;
    bool citiesLoaded = false;
    bool saving = false;
    String? sheetError;
    final s = Strings.of(context.read<AppState>().lang);

    Future<void> loadCities(void Function(void Function()) set, CountryModel c) async {
      set(() { cities = []; selCity = null; loadingCities = true; citiesLoaded = false; });
      final res = await getCitiesForCountry(c.code ?? '');
      set(() {
        loadingCities = false;
        citiesLoaded = true;
        cities = res.success ? res.data ?? [] : [];
        if (edit?.city != null) {
          selCity = cities.where((ci) => ci.name?.toLowerCase() == edit!.city!.toLowerCase()).firstOrNull;
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PwtColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(PwtRadius.sheet))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 22, bottom: MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (ctx, set) {
              if (selCountry != null && !citiesLoaded && !loadingCities) {
                loadCities(set, selCountry!);
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(child: Text(edit == null ? s['addAddress']! : s['edit']!, style: PwtType.title().copyWith(fontSize: 19))),
                    IconButton(icon: const Icon(PwtIcons.close), onPressed: saving ? null : () => Navigator.pop(ctx), color: PwtColors.textPri),
                  ]),
                  const SizedBox(height: 12),
                  PwtField(label: 'Label', controller: labelCtrl, onChanged: (_) {}),
                  const SizedBox(height: 10),
                  PwtField(label: 'Address line 1', controller: line1Ctrl, onChanged: (_) {}),
                  const SizedBox(height: 10),
                  PwtField(label: 'Address line 2 (optional)', controller: line2Ctrl, onChanged: (_) {}),
                  const SizedBox(height: 10),
                  Text('Country', style: PwtType.label()),
                  const SizedBox(height: 7),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CountryModel>(
                        value: selCountry,
                        isExpanded: true,
                        isDense: true,
                        hint: Text('Select country', style: PwtType.body(color: PwtColors.textTer)),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: PwtColors.textTer),
                        items: _countries.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${_accountFlagFromCode(c.code)} ${c.name ?? c.code ?? ''}'),
                        )).toList(),
                        onChanged: (c) {
                          set(() { selCountry = c; selCity = null; cities = []; citiesLoaded = false; });
                          if (c != null) loadCities(set, c);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('City', style: PwtType.label()),
                  const SizedBox(height: 7),
                  if (loadingCities)
                    const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  else
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CityModel>(
                          value: selCity,
                          isExpanded: true,
                          isDense: true,
                          hint: Text(selCountry == null ? 'Select a country first' : 'Select city', style: PwtType.body(color: PwtColors.textTer)),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: PwtColors.textTer),
                          items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name ?? ''))).toList(),
                          onChanged: selCountry == null ? null : (c) => set(() => selCity = c),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  PwtField(label: 'Postcode', controller: pcCtrl, onChanged: (_) {}),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => set(() => def = !def),
                    child: Row(children: [
                      _checkbox(def),
                      const SizedBox(width: 10),
                      Text(s['setDefault']!, style: PwtType.label()),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  if (sheetError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(sheetError!, style: PwtType.body(color: PwtColors.error)),
                    ),
                  Row(children: [
                    Expanded(child: PwtButton(label: s['cancel']!, variant: PwtButtonVariant.secondary, full: true, onPressed: saving ? null : () => Navigator.pop(ctx))),
                    const SizedBox(width: 10),
                    Expanded(child: saving
                      ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                      : PwtButton(
                          label: edit == null ? s['addAddress']! : s['saved']!,
                          full: true,
                          onPressed: () async {
                            set(() { saving = true; sheetError = null; });
                            final u = web.AppState.instance.user;
                            final cityName = selCity?.name ?? '';
                            final res = edit != null && edit.id != null
                                ? await updateAddress(
                                    addressId: edit.id!,
                                    label: labelCtrl.text.trim().isEmpty ? null : labelCtrl.text.trim(),
                                    line1: line1Ctrl.text.trim().isEmpty ? null : line1Ctrl.text.trim(),
                                    line2: line2Ctrl.text.trim().isEmpty ? null : line2Ctrl.text.trim(),
                                    city: cityName.isEmpty ? null : cityName,
                                    postalCode: pcCtrl.text.trim().isEmpty ? null : pcCtrl.text.trim(),
                                    countryId: selCountry?.id,
                                    isDefault: def,
                                    recipientName: u?.name,
                                    recipientPhone: u?.phone,
                                  )
                                : await createAddress(
                                    label: labelCtrl.text.trim().isEmpty ? 'Address' : labelCtrl.text.trim(),
                                    line1: line1Ctrl.text.trim(),
                                    line2: line2Ctrl.text.trim().isEmpty ? null : line2Ctrl.text.trim(),
                                    city: cityName.isEmpty ? null : cityName,
                                    postalCode: pcCtrl.text.trim().isEmpty ? null : pcCtrl.text.trim(),
                                    countryId: selCountry?.id,
                                    isDefault: def,
                                    recipientName: u?.name,
                                    recipientPhone: u?.phone,
                                  );
                            if (!ctx.mounted) return;
                            if (res.success) {
                              Navigator.pop(ctx);
                              if (mounted) _loadAddresses();
                            } else {
                              final fieldErrors = res.errors?.values.expand((e) => e).join(' ');
                              set(() {
                                saving = false;
                                sheetError = fieldErrors?.isNotEmpty == true ? fieldErrors : (res.message ?? 'Failed to save address.');
                              });
                            }
                          },
                        ),
                    ),
                  ]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAddress(AddressModel a) async {
    if (a.id == null) return;
    final confirmed = await showConfirmSheet(
      context,
      title: 'Remove address?',
      body: 'Are you sure you want to remove this address?',
      keepLabel: 'Keep',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !mounted) return;
    final res = await deleteAddress(a.id!);
    if (!mounted) return;
    if (res.success) {
      _loadAddresses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Failed to remove address.'), behavior: SnackBarBehavior.floating, backgroundColor: PwtColors.error),
      );
    }
  }

  Widget _checkbox(bool checked) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: checked ? PwtColors.brand : PwtColors.surface,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: checked ? PwtColors.brand : PwtColors.hairline2, width: 1.5),
    ),
    child: checked ? const Icon(PwtIcons.check, size: 14, color: Colors.white) : null,
  );

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final u = web.AppState.instance.user;
    return Column(children: [
      Section(
        title: s['companyInfo']!,
        trailing: GestureDetector(
          onTap: () {
            if (_edit) { _save(); } else { setState(() => _edit = true); }
          },
          child: Text(
            _saving ? '…' : (_edit ? 'Save changes' : s['edit']!),
            style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 12.5),
          ),
        ),
        child: _edit
            ? Column(children: [
                PwtField(label: s['companyName']!, controller: _companyCtrl),
                const SizedBox(height: 10),
                PwtField(label: s['fullName']!, controller: _nameCtrl),
                const SizedBox(height: 10),
                PwtField(label: s['email']!, controller: _emailCtrl, forceLtr: true, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                // Phone with country code
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Phone', style: PwtType.label()),
                  const SizedBox(height: 7),
                  Row(children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _phoneCc,
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: PwtColors.textTer),
                          style: PwtType.label().copyWith(fontSize: 14),
                          items: _countries.isEmpty
                              ? [DropdownMenuItem(value: _phoneCc, child: Text(_phoneCc))]
                              : _countries.map((c) => DropdownMenuItem(
                                  value: c.phoneCode!,
                                  child: Text('${_accountFlagFromCode(c.code)} ${c.phoneCode}'),
                                )).toList(),
                          onChanged: (v) => setState(() => _phoneCc = v!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline, width: 1.5), borderRadius: BorderRadius.circular(PwtRadius.md)),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        style: PwtType.body(weight: FontWeight.w500),
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                      ),
                    )),
                  ]),
                ]),
              ])
            : PwtCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  ListRow(leading: PwtIcons.building, title: u?.companyName ?? _c.name, sub: s['companyName']),
                  ListRow(leading: PwtIcons.user, title: u?.name ?? _c.contact, sub: 'Primary contact'),
                  ListRow(leading: PwtIcons.message, title: u?.email ?? _c.email, sub: s['email']),
                  ListRow(leading: PwtIcons.phone, title: u?.phone ?? widget.user.phone, sub: s['phoneNumber'], last: true),
                ]),
              ),
      ),
      Section(
        title: s['savedAddresses']!,
        trailing: GestureDetector(
          onTap: () => _addressSheet(),
          child: Text('+ ${s['addAddress']!}', style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 12.5)),
        ),
        child: _loadingAddr
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator(strokeWidth: 2)))
            : _addrError != null
                ? Text(_addrError!, style: PwtType.label(color: PwtColors.error).copyWith(fontSize: 13))
                : _addresses.isEmpty
                    ? PwtCard(
                        padding: const EdgeInsets.all(16),
                        child: Text('No saved addresses.', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
                      )
                    : Column(children: [
                        for (final a in _addresses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AddressCard(
                              address: a,
                              onEdit: () => _addressSheet(edit: a),
                              onSetDefault: () async {
                                if (a.id == null) return;
                                await updateAddress(addressId: a.id!, isDefault: true);
                                if (mounted) _loadAddresses();
                              },
                              onRemove: () => _deleteAddress(a),
                            ),
                          ),
                      ]),
      ),
    ]);
  }
}

// ═══════════════════════ SETTINGS ═══════════════════════
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, bool> _notifs = Map.of(MockData.notifDefaults);
  final _curPw = TextEditingController();
  final _newPw = TextEditingController();
  final _confPw = TextEditingController();
  bool _pwDone = false;

  @override
  void dispose() {
    _curPw.dispose();
    _newPw.dispose();
    _confPw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final rows = [
      (k: 'maintenance', label: s['notifMaintenance']!, sub: s['notifMaintenanceSub']!, icon: PwtIcons.wrench),
      (k: 'billing', label: s['notifBilling']!, sub: s['notifBillingSub']!, icon: PwtIcons.card),
      (k: 'orders', label: s['notifOrders']!, sub: s['notifOrdersSub']!, icon: PwtIcons.orders),
      (k: 'offers', label: s['notifOffers']!, sub: s['notifOffersSub']!, icon: PwtIcons.bolt),
    ];

    return DetailScaffold(
      title: s['settings'],
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Section(
            title: s['notifications']!,
            child: PwtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < rows.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(border: i == rows.length - 1 ? null : const Border(bottom: BorderSide(color: PwtColors.hairline))),
                      child: Row(children: [
                        Icon(rows[i].icon, size: 18, color: PwtColors.textSec),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(rows[i].label, style: PwtType.label(weight: FontWeight.w500).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(rows[i].sub, style: PwtType.caption().copyWith(fontSize: 11.5)),
                        ])),
                        PwtSwitch(value: _notifs[rows[i].k] ?? false, onChanged: (v) => setState(() => _notifs[rows[i].k] = v)),
                      ]),
                    ),
                ],
              ),
            ),
          ),
          Section(
            title: s['security']!,
            child: Column(children: [
              PwtField(label: s['currentPassword']!, controller: _curPw, obscure: true),
              const SizedBox(height: 10),
              PwtField(label: s['newPassword']!, controller: _newPw, obscure: true),
              const SizedBox(height: 10),
              PwtField(label: s['confirmNewPassword']!, controller: _confPw, obscure: true),
              const SizedBox(height: 8),
              Align(alignment: AlignmentDirectional.centerStart, child: Padding(padding: const EdgeInsets.only(left: 4), child: Text(s['passwordHint']!, style: PwtType.caption().copyWith(fontSize: 11.5)))),
              const SizedBox(height: 10),
              PwtButton(
                label: _pwDone ? s['passwordUpdated']! : s['updatePassword']!,
                variant: _pwDone ? PwtButtonVariant.soft : PwtButtonVariant.primary,
                full: true,
                icon: _pwDone ? PwtIcons.check : PwtIcons.lock,
                onPressed: () {
                  setState(() => _pwDone = true);
                  Future.delayed(const Duration(milliseconds: 1800), () {
                    if (mounted) setState(() => _pwDone = false);
                  });
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════ INVOICES ═══════════════════════
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key, required this.invoices});
  final List<Invoice> invoices;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return DetailScaffold(
      title: s['invoices'],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Eyebrow(s['allInvoices']!),
          const SizedBox(height: 4),
          Text(s['invoices']!, style: PwtType.headline().copyWith(fontSize: 26)),
          const SizedBox(height: 18),
          for (final inv in invoices)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: _InvoiceCard(inv: inv)),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatefulWidget {
  const _InvoiceCard({required this.inv});
  final Invoice inv;
  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _dl = false;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final inv = widget.inv;
    final paid = inv.status == 'paid';
    return Container(
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: PwtColors.hairline),
        borderRadius: BorderRadius.circular(PwtRadius.card),
        boxShadow: PwtShadows.e1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(12)),
              child: const Icon(PwtIcons.file, size: 20, color: PwtColors.textSec),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Directionality(textDirection: TextDirection.ltr, child: Text(inv.id, style: PwtType.mono(size: 11.5, color: PwtColors.brand, weight: FontWeight.w600))),
                const SizedBox(width: 8),
                Pill(label: paid ? s['paid']! : s['dueStatus']!, color: paid ? PwtColors.success : PwtColors.warning, dot: true),
              ]),
              const SizedBox(height: 4),
              Text(inv.desc, style: PwtType.label(weight: FontWeight.w500).copyWith(fontSize: 13.5)),
              const SizedBox(height: 2),
              Text(inv.date, style: PwtType.caption().copyWith(fontSize: 12)),
            ])),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Dirham(size: 12),
                const SizedBox(width: 3),
                Text(inv.amount.toStringAsFixed(2), style: PwtType.subtitle().copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ]),
        ),
        InkWell(
          onTap: () {
            setState(() => _dl = true);
            Future.delayed(const Duration(milliseconds: 1500), () { if (mounted) setState(() => _dl = false); });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_dl ? PwtIcons.check : PwtIcons.file, size: 15, color: _dl ? PwtColors.success : PwtColors.brand),
                const SizedBox(width: 8),
                Text(_dl ? s['saved']! : s['download']!, style: TextStyle(color: _dl ? PwtColors.success : PwtColors.brand, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════ ORDERS ═══════════════════════
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.role});
  final AccountKind role;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _statusFilter;
  int _page = 1;
  PaginationModel? _pagination;

  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  static const _statusFilters = <String?>[null, 'pending', 'completed', 'cancelled'];
  static const _statusFilterLabels = ['All', 'Pending', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1, bool append = false}) async {
    if (append) {
      setState(() => _loadingMore = true);
    } else {
      setState(() { _loading = true; _orders = []; });
    }
    final res = await getOrders(page: page, status: _statusFilter);
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _orders = append ? [..._orders, ...res.data!.items] : res.data!.items;
        _pagination = res.data!.pagination;
        _page = page;
      }
      _loading = false;
      _loadingMore = false;
    });
  }

  void _loadMore() => _load(page: _page + 1, append: true);

  String _fmtDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}';
    } catch (_) { return '—'; }
  }

  String _shortId(String publicId) =>
      '#${publicId.length >= 8 ? publicId.substring(0, 8).toUpperCase() : publicId.toUpperCase()}';

  Color _statusColor(String st) => switch (st) {
    'pending'   => PwtColors.warning,
    'confirmed' => PwtColors.brand,
    'scheduled' => PwtColors.brand,
    'completed' => PwtColors.success,
    'cancelled' => PwtColors.error,
    _           => PwtColors.textSec,
  };

  String _statusLabel(String st) => switch (st) {
    'pending'   => 'Pending',
    'confirmed' => 'Confirmed',
    'scheduled' => 'Scheduled',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    _           => st,
  };

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return DetailScaffold(
      title: s['orders'],
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_statusFilters.length, (i) {
                      final on = _statusFilter == _statusFilters[i];
                      return GestureDetector(
                        onTap: () {
                          setState(() { _statusFilter = _statusFilters[i]; _page = 1; });
                          _load();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: i < _statusFilters.length - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: on ? PwtColors.brandTint : PwtColors.surface,
                            border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline, width: on ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(_statusFilterLabels[i], style: PwtType.label(weight: on ? FontWeight.w700 : FontWeight.w500, color: on ? PwtColors.brand : PwtColors.textSec).copyWith(fontSize: 13)),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 14),
                for (final o in _orders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderApiDetailScreen(id: o.id))),
                      child: PwtCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Directionality(textDirection: TextDirection.ltr, child: Text(_shortId(o.publicId), style: PwtType.mono(size: 11, color: PwtColors.brand, weight: FontWeight.w600))),
                            Pill(label: _statusLabel(o.status), color: _statusColor(o.status), dot: true),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                o.firstProductName ?? 'Order #${o.id}',
                                style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (o.remainingItemsCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(color: PwtColors.brandTint, borderRadius: BorderRadius.circular(999)),
                                child: Text('+${o.remainingItemsCount}', style: PwtType.mono(size: 11, color: PwtColors.brand, weight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${s['placed']} ${_fmtDate(o.placedAt)}', style: PwtType.caption().copyWith(fontSize: 12)),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${s['total']}  ', style: PwtType.caption()),
                            Text('${o.currency} ', style: PwtType.caption().copyWith(fontWeight: FontWeight.w600)),
                            Text(o.totalAmount, style: PwtType.subtitle().copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                            if (o.term == 'rent') Text(s['perMonth']!, style: PwtType.caption()),
                          ],
                        ),
                      ]),
                    ),
                    )),
                if (_pagination != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Page $_page of ${_pagination!.lastPage ?? 1} · ${_pagination!.total ?? _orders.length} total',
                    textAlign: TextAlign.center,
                    style: PwtType.caption().copyWith(fontSize: 12),
                  ),
                  if (_page < (_pagination!.lastPage ?? 1)) ...[
                    const SizedBox(height: 12),
                    if (_loadingMore)
                      const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand),
                      ))
                    else
                      PwtButton(label: 'Load more', variant: PwtButtonVariant.soft, full: true, onPressed: _loadMore),
                  ],
                ],
              ],
            ),
    );
  }
}

// Groups card digits as "XXXX XXXX XXXX XXXX", capped at 16 digits.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) return old;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

String _accountFlagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}

// ═══════════════════════ ORDER DETAIL ═══════════════════════
class OrderApiDetailScreen extends StatefulWidget {
  const OrderApiDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<OrderApiDetailScreen> createState() => _OrderApiDetailScreenState();
}

class _OrderApiDetailScreenState extends State<OrderApiDetailScreen> {
  bool _loading = true;
  String? _error;
  OrderDetailModel? _order;

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await getOrderDetail(widget.id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success && res.data != null) _order = res.data;
      else _error = res.message ?? 'Failed to load order.';
    });
  }

  String _fmt(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
    } catch (_) { return '—'; }
  }

  String _shortId(String id) => '#${id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}';

  String _slotLabel(String? slot) => switch (slot) {
    'morning'   => 'Morning · 8AM–12PM',
    'afternoon' => 'Afternoon · 12PM–4PM',
    'evening'   => 'Evening · 4PM–7PM',
    _           => slot ?? '—',
  };

  String _addressStr(OrderDetailModel o) {
    if (o.deliveryAddressLine1 != null) {
      return [o.deliveryAddressLine1, o.deliveryCity, o.deliveryPostcode]
          .where((s) => s != null && s!.isNotEmpty).join(', ');
    }
    if (o.deliveryAddress != null) {
      final a = o.deliveryAddress!;
      final country = a['country'];
      final countryName = country is Map ? country['name'] as String? : null;
      return [a['label'], a['city'], countryName]
          .where((s) => s != null && (s as String).isNotEmpty).join(', ');
    }
    return '—';
  }

  Color _statusColor(String st) => switch (st) {
    'pending'   => PwtColors.warning,
    'confirmed' => PwtColors.brand,
    'scheduled' => PwtColors.brand,
    'completed' => PwtColors.success,
    'cancelled' => PwtColors.error,
    _           => PwtColors.textSec,
  };

  String _statusLabel(String st) => switch (st) {
    'pending'   => 'Pending',
    'confirmed' => 'Confirmed',
    'scheduled' => 'Scheduled',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    _           => st,
  };

  bool get _ongoing   => const ['pending', 'confirmed', 'scheduled'].contains(_order?.status);
  bool get _completed => _order?.status == 'completed';
  bool get _cancelled => _order?.status == 'cancelled';

  @override
  Widget build(BuildContext context) {
    final o = _order;
    return DetailScaffold(
      title: o != null ? (o.displayName ?? _shortId(o.publicId)) : 'Order',
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand))
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: PwtType.body(color: PwtColors.error))))
              : _body(o!),
    );
  }

  Widget _body(OrderDetailModel o) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // status pill
        Row(children: [Pill(label: _statusLabel(o.status), color: _statusColor(o.status), dot: true)]),
        const SizedBox(height: 14),

        // ── cancelled banner ──
        if (_cancelled) ...[
          PwtCard(
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: PwtColors.errorFill, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.cancel_outlined, color: PwtColors.error, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order cancelled', style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text('Cancelled ${_fmt(o.cancelledAt)}', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
              ])),
            ]),
          ),
          if (o.cancellationReason != null) ...[
            const SizedBox(height: 10),
            PwtCard(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(PwtIcons.info, size: 16, color: PwtColors.textSec),
                const SizedBox(width: 8),
                Expanded(child: Text('Reason: ${o.cancellationReason}', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13))),
              ]),
            ),
          ],
          const SizedBox(height: 14),
        ],

        // ── completed banner ──
        if (_completed) ...[
          PwtCard(
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFFE7F7EF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_outline, color: PwtColors.success, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order completed', style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text('Completed ${_fmt(o.completedAt)}', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
        ],

        // ── tracking steps (ongoing only) ──
        if (_ongoing) ...[
          PwtCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              _trackingStep('Order placed',           _fmt(o.placedAt),        done: true),
              _trackingStep('Confirmed',              o.confirmedAt != null ? _fmt(o.confirmedAt) : 'Awaiting confirmation', done: o.confirmedAt != null, pending: o.confirmedAt == null),
              _trackingStep('Installation scheduled', o.scheduledForAt != null ? _fmt(o.scheduledForAt) : 'To be scheduled',  done: o.scheduledForAt != null, pending: o.confirmedAt != null && o.scheduledForAt == null),
              _trackingStep('Delivered',              o.deliveredAt != null ? _fmt(o.deliveredAt) : 'Pending',               done: o.deliveredAt != null,  pending: o.scheduledForAt != null && o.deliveredAt == null),
              _trackingStep('Installed & completed',  o.installedAt != null ? _fmt(o.installedAt) : 'Pending',               done: o.installedAt != null,  pending: o.deliveredAt != null && o.installedAt == null, last: true),
            ]),
          ),
          const SizedBox(height: 14),
        ],

        // ── items ──
        PwtCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            if (o.items.isNotEmpty)
              ...o.items.asMap().entries.map((e) {
                final it = e.value;
                final last = e.key == o.items.length - 1;
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: PwtColors.hairline))),
                  child: Row(children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(color: PwtColors.brandTint, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(PwtIcons.drop, size: 22, color: PwtColors.brand),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(it.productNameSnapshot, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Qty ${it.quantity}', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 12.5)),
                    ])),
                    Text('${o.currency} ${it.lineTotal}', style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 14)),
                  ]),
                );
              })
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${o.itemsCount ?? 1} item(s) ordered', style: PwtType.body(color: PwtColors.textSec)),
              ),
          ]),
        ),
        const SizedBox(height: 14),

        // ── order summary ──
        PwtCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Order summary', style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 14)),
            const SizedBox(height: 12),
            _sumRow('Subtotal', '${o.currency} ${o.subtotalAmount}'),
            if ((double.tryParse(o.discountAmount) ?? 0) > 0)
              _sumRow('Discount', '− ${o.currency} ${o.discountAmount}', green: true),
            _sumRow('Delivery', 'Free', green: true),
            _sumRow('Installation', 'Free', green: true),
            if ((double.tryParse(o.taxAmount) ?? 0) > 0)
              _sumRow('VAT (${o.taxRate?.toInt() ?? 0}%)', '${o.currency} ${o.taxAmount}'),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: PwtColors.hairline)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total', style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 15)),
              Text('${o.currency} ${o.totalAmount}', style: PwtType.subtitle().copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),

        // ── delivery ──
        PwtCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            ListRow(leading: PwtIcons.pin, title: _addressStr(o), sub: 'Delivery address'),
            if (o.installationPreferredTime != null)
              ListRow(leading: Icons.schedule_outlined, title: _slotLabel(o.installationPreferredTime), sub: 'Preferred time slot'),
            if (o.deliveryDate != null)
              ListRow(leading: PwtIcons.cal, title: _fmt(o.deliveryDate), sub: 'Delivery date', last: o.installationPreferredTime == null),
            ListRow(leading: PwtIcons.user, title: o.customerName ?? '—', sub: 'Recipient', last: true),
          ]),
        ),

        // ── fulfilment dates (completed) ──
        if (_completed) ...[
          const SizedBox(height: 14),
          PwtCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              ListRow(leading: PwtIcons.truck, title: _fmt(o.deliveredAt), sub: 'Delivered on'),
              ListRow(leading: PwtIcons.wrench, title: _fmt(o.installedAt), sub: 'Installed on'),
              ListRow(leading: PwtIcons.check, title: _fmt(o.completedAt), sub: 'Completed on', last: true),
            ]),
          ),
        ],

        // ── payment ──
        const SizedBox(height: 14),
        PwtCard(
          padding: EdgeInsets.zero,
          child: o.paymentCard != null
              ? ListRow(
                  leading: PwtIcons.card,
                  title: '•••• ${o.paymentCard!.lastFour ?? '—'}  ·  Exp ${o.paymentCard!.expiryMonth}/${o.paymentCard!.expiryYear}',
                  sub: 'Payment card',
                  last: true,
                )
              : ListRow(
                  leading: PwtIcons.card,
                  title: switch (o.paymentMethod) {
                    'card'       => 'Credit / Debit Card',
                    'apple_pay'  => 'Apple Pay',
                    'google_pay' => 'Google Pay',
                    _            => o.paymentMethod,
                  },
                  sub: 'Payment method',
                  last: true,
                ),
        ),
      ],
    );
  }

  Widget _trackingStep(String label, String detail, {bool done = false, bool pending = false, bool last = false}) {
    final color = done ? PwtColors.success : pending ? PwtColors.brand : PwtColors.hairline2;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: last ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: PwtColors.hairline))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle, color: done ? PwtColors.success : Colors.transparent, border: Border.all(color: color, width: 2)),
            child: done ? const Icon(PwtIcons.check, size: 11, color: Colors.white) : null,
          ),
          if (!last) Container(width: 2, height: 28, margin: const EdgeInsets.symmetric(vertical: 4), color: PwtColors.hairline),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: PwtType.label(weight: done || pending ? FontWeight.w600 : FontWeight.w400, color: done || pending ? PwtColors.textPri : PwtColors.textTer).copyWith(fontSize: 13.5)),
              const SizedBox(height: 2),
              Text(detail, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 12.5)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _sumRow(String k, String v, {bool green = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5)),
      Text(v, style: PwtType.label(weight: FontWeight.w600, color: green ? PwtColors.success : PwtColors.textPri).copyWith(fontSize: 13.5)),
    ]),
  );
}
