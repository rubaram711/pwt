// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/stripe_card_field.dart';
import '../../const/stripe_config.dart';
import 'dashboard_shell.dart';
import '../../Models/address_model.dart';
import '../../Backend/Addresses/get_addresses.dart';
import '../../Backend/Addresses/create_address.dart';
import '../../Backend/Addresses/update_address.dart';
import '../../Backend/Addresses/delete_address.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Backend/Reference/get_cities_for_country.dart';
import '../../Models/Reference/country_model.dart';
import '../../Models/Reference/city_model.dart';
import '../../Backend/Users/add_update_photo_authenticated.dart';
import '../../Backend/Users/update_user.dart';
import '../../Models/payment_card_model.dart';
import '../../Backend/Users/PaymentCards/get_payment_cards.dart';
import '../../Backend/Users/PaymentCards/create_payment_card.dart';
import '../../Backend/Users/PaymentCards/delete_payment_card.dart';
import '../../Backend/Users/PaymentCards/set_default_payment_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool isCompany;
  bool _loadingAddresses = false;
  String? _addressError;
  List<AddressModel> _addresses = [];
  List<PaymentCard> _cards = [];
  bool _loadingCards = false;
  String? _cardsError;
  String _phoneCountry = '+971';
  List<CountryModel> _countries = [];
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _companyCtrl;
  bool _avatarLoading = false;
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();
    isCompany = AppState.instance.isCompany;
    _loadAddresses();
    _loadCards();
    _loadCountryCodes();
    final u = AppState.instance.user;
    final code = u?.phoneCountryCode ?? '+971';
    final rawPhone = u?.phone ?? '';
    _phoneCountry = code;
    _phoneCtrl = TextEditingController(
      text: rawPhone.startsWith(code) ? rawPhone.substring(code.length).trim() : rawPhone,
    );
    final nameParts = (u?.name ?? '').trim().split(RegExp(r'\s+'));
    _firstCtrl = TextEditingController(
      text: nameParts.isNotEmpty && nameParts.first.isNotEmpty ? nameParts.first : '',
    );
    _lastCtrl = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _companyCtrl = TextEditingController(text: u?.companyName ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() { _loadingAddresses = true; _addressError = null; });
    final result = await getAddresses();
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() { _addresses = result.data!; _loadingAddresses = false; });
    } else {
      setState(() { _loadingAddresses = false; _addressError = result.message ?? 'Failed to load addresses.'; });
    }
  }

  Future<void> _loadCards() async {
    setState(() { _loadingCards = true; _cardsError = null; });
    final result = await getPaymentCards();
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() { _cards = result.data!; _loadingCards = false; });
    } else {
      setState(() { _loadingCards = false; _cardsError = result.message ?? 'Failed to load cards.'; });
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

  Future<void> _deleteCard(PaymentCard c) async {
    final result = await deletePaymentCard(c.id);
    if (!mounted) return;
    if (result.success) {
      _loadCards();
    } else {
      _toast(result.message ?? 'Failed to delete card.');
    }
  }

  Future<void> _setDefaultCard(PaymentCard c) async {
    final result = await setDefaultPaymentCard(c.id);
    if (!mounted) return;
    if (result.success) {
      _loadCards();
    } else {
      _toast(result.message ?? 'Failed to update default card.');
    }
  }

  String _addressFull(AddressModel a) => [a.line1, a.line2, a.city, a.postalCode, a.country?.name]
      .where((s) => s != null && s!.isNotEmpty)
      .cast<String>()
      .join(', ');

  String _memberSince(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = AppState.instance.user;
    final wide = MediaQuery.of(context).size.width > 880;
    return DashboardShell(
      active: 'profile',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashHeader(
          title: 'Profile',
          subtitle: 'Manage your information, addresses and payment details',
          action: Navigator.of(context).canPop()
              ? PwtButton('Back', variant: PwtBtn.outline, icon: Icons.arrow_back, onPressed: () => Navigator.of(context).pop())
              : null,
        ),
        Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: wide ? 1 : 0, child: Column(children: [
            DashCard(title: 'Personal Information', child: Column(children: [
              Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.blue100,
                  backgroundImage: u?.avatarUrl != null ? NetworkImage(u!.avatarUrl!) : null,
                  child: u?.avatarUrl == null
                      ? Text(u?.initials ?? 'PW', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.blue800))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isCompany ? (u?.companyName ?? '') : (u?.name ?? ''), style: AppText.h3.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(_memberSince(u?.createdAt), style: AppText.muted),
                ])),
                _avatarLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue700))
                    : PwtButton('Change photo', variant: PwtBtn.outline, onPressed: _changePhoto),
              ]),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: AppColors.line)),
              if (isCompany) ...[
                _field('Company name', _companyCtrl),
                const SizedBox(height: 12),
              ],
              Row(children: [
                Expanded(child: _field('First name', _firstCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('Last name', _lastCtrl)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field('Email', _emailCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _phoneField()),
              ]),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: PwtButton(_savingProfile ? 'Saving…' : 'Save Changes', onPressed: _savingProfile ? null : _saveProfile)),
            ])),
            const SizedBox(height: 16),
            DashCard(
              title: 'Addresses',
              action: PwtButton('Add new address', variant: PwtBtn.outline, icon: Icons.add, onPressed: () => _addressSheet()),
              child: _loadingAddresses
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  : _addressError != null
                      ? Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(_addressError!, style: AppText.muted.copyWith(color: AppColors.danger)))
                      : _addresses.isEmpty
                          ? Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('No addresses saved.', style: AppText.muted))
                          : Column(children: _addresses.map(_addressItem).toList()),
            ),
          ])),
          SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 16),
          Expanded(flex: wide ? 1 : 0, child: DashCard(
            title: 'Payment Details',
            action: PwtButton('Add card', variant: PwtBtn.outline, icon: Icons.add, onPressed: () => _cardSheet()),
            child: _loadingCards
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                : _cardsError != null
                    ? Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(_cardsError!, style: AppText.muted.copyWith(color: AppColors.danger)))
                    : Column(children: _cards.isEmpty
                        ? [Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('No saved cards. Add one with "Add card".', style: AppText.muted))]
                        : _cards.map(_cardItem).toList()),
          )),
        ]),
      ]),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _savingProfile = true);
    final fullName = '${_firstCtrl.text.trim()} ${_lastCtrl.text.trim()}'.trim();
    final phoneNum = _phoneCtrl.text.trim();
    final result = await updateProfile(
      name: fullName.isEmpty ? null : fullName,
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: phoneNum,
      phoneCountryCode: _phoneCountry,
      companyName: isCompany && _companyCtrl.text.trim().isNotEmpty ? _companyCtrl.text.trim() : null,
      currentPassword: AppState.instance.currentPassword,
    );
    if (!mounted) return;
    setState(() => _savingProfile = false);
    if (result.success && result.data != null) {
      await AppState.instance.persistUser(result.data!);
      _toast('Profile updated successfully.');
    } else {
      _toast(result.message ?? result.error ?? 'Failed to save profile.');
    }
  }

  void _changePhoto() {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) async {
        final bytes = reader.result as Uint8List;
        setState(() => _avatarLoading = true);
        final result = await addUpdatePhotoAuthenticated(bytes: bytes, filename: file.name);
        if (!mounted) return;
        setState(() => _avatarLoading = false);
        if (result.success && result.data != null) {
          AppState.instance.user = result.data;
          AppState.instance.notifyListeners();
          _toast('Photo updated successfully.');
        } else {
          _toast(result.message ?? result.error ?? 'Failed to update photo.');
        }
      });
    });
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.ink900));

  Widget _phoneField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Phone', style: AppText.label),
        const SizedBox(height: 7),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _phoneCountry,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.ink400),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink900),
                onChanged: (v) => setState(() => _phoneCountry = v!),
                items: _countries.isEmpty
                    ? [DropdownMenuItem(value: _phoneCountry, child: Text(_phoneCountry))]
                    : _countries.map((c) => DropdownMenuItem(
                        value: c.phoneCode!,
                        child: Text('${_profileFlagFromCode(c.code)} ${c.phoneCode}'),
                      )).toList(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '50 123 4567'),
            ),
          ),
        ]),
      ]);

  Widget _field(String label, TextEditingController ctrl) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        TextField(controller: ctrl, decoration: const InputDecoration()),
      ]);

  Widget _addressItem(AddressModel a) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: AppColors.line)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.location_on_outlined, size: 20, color: AppColors.blue700),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(a.label ?? '', style: AppText.label),
              if (a.isDefault == true) ...[const SizedBox(width: 8), StatusBadge.green('Default')],
            ]),
            const SizedBox(height: 3),
            Text(_addressFull(a), style: AppText.muted),
          ])),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.ink400), onPressed: () => _addressSheet(edit: a)),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger), onPressed: () => _deleteAddress(a)),
        ]),
      );

  void _deleteAddress(AddressModel a) {
    if (a.id == null) return;
    deleteAddress(a.id!).then((result) {
      if (!mounted) return;
      if (result.success) {
        _loadAddresses();
      } else {
        _toast(result.message ?? 'Failed to remove address.');
      }
    });
  }

  Widget _cardItem(PaymentCard c) {
    final brandLower = c.brand.toLowerCase();
    final grad = brandLower == 'visa'
        ? const [Color(0xFF1A1F71), Color(0xFF2B3A8C)]
        : brandLower.contains('master')
            ? const [Color(0xFFEB5B2E), Color(0xFFCF4521)]
            : const [Color(0xFF334155), Color(0xFF1E293B)];
    final displayName = brandLower == 'visa' ? 'Visa' : brandLower.contains('master') ? 'Mastercard' : c.brand;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: AppColors.line)),
      child: Row(children: [
        Container(width: 48, height: 32, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: grad), borderRadius: BorderRadius.circular(6)), child: Text(c.brand.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$displayName •••• ${c.lastFour}', style: AppText.label),
          Text('Expires ${c.expiryMonth} / ${c.expiryYear}', style: AppText.muted),
        ])),
        if (c.isDefault)
          StatusBadge.green('Default')
        else
          TextButton(onPressed: () => _setDefaultCard(c), child: const Text('Make default')),
        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger), onPressed: () => _deleteCard(c)),
      ]),
    );
  }

  void _addressSheet({AddressModel? edit}) {
    final label = TextEditingController(text: edit?.label ?? '');
    final l1    = TextEditingController(text: edit?.line1 ?? '');
    final l2    = TextEditingController(text: edit?.line2 ?? '');
    final pc    = TextEditingController(text: edit?.postalCode ?? '');
    bool def = edit?.isDefault ?? false;

    // pre-select country if editing
    CountryModel? selCountry = edit?.country?.code != null
        ? _countries.where((c) => c.code?.toLowerCase() == edit!.country!.code!.toLowerCase()).firstOrNull
        : null;
    CityModel? selCity;
    List<CityModel> cities = [];
    bool loadingCities = false;
    bool citiesLoaded = false;
    bool saving = false;
    String? sheetError;

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          if (selCountry != null && !citiesLoaded && !loadingCities) {
            loadCities(set, selCountry!);
          }
          return Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 22, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [Expanded(child: Text(edit == null ? 'Add new address' : 'Edit address', style: AppText.h2.copyWith(fontSize: 19))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))]),
                const SizedBox(height: 12),
                // Label
                Padding(padding: const EdgeInsets.only(bottom: 14), child: _sheetField('Label', label, hint: 'e.g. Home, Office')),
                // Line 1
                Padding(padding: const EdgeInsets.only(bottom: 14), child: _sheetField('Address line 1', l1)),
                // Line 2
                Padding(padding: const EdgeInsets.only(bottom: 14), child: _sheetField('Address line 2 (optional)', l2)),
                // Country
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Country', style: AppText.label),
                    const SizedBox(height: 7),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CountryModel>(
                          value: selCountry,
                          isExpanded: true,
                          isDense: true,
                          hint: Text('Select country', style: AppText.muted),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.ink400),
                          items: _countries.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${_profileFlagFromCode(c.code)} ${c.name ?? c.code ?? ''}'),
                          )).toList(),
                          onChanged: (c) {
                            set(() { selCountry = c; selCity = null; cities = []; });
                            if (c != null) loadCities(set, c);
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
                // City
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('City', style: AppText.label),
                    const SizedBox(height: 7),
                    if (loadingCities)
                      const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    else
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(AppRadius.sm)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CityModel>(
                            value: selCity,
                            isExpanded: true,
                            isDense: true,
                            hint: Text(selCountry == null ? 'Select a country first' : 'Select city', style: AppText.muted),
                            icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.ink400),
                            items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name ?? ''))).toList(),
                            onChanged: selCountry == null ? null : (c) => set(() => selCity = c),
                          ),
                        ),
                      ),
                  ]),
                ),
                // Postcode
                Padding(padding: const EdgeInsets.only(bottom: 14), child: _sheetField('Postcode', pc)),
                // Default toggle
                Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Expanded(child: Text('Set as default address', style: AppText.label)), PwtToggle(value: def, onChanged: (v) => set(() => def = v))])),
                const SizedBox(height: 14),
                if (sheetError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(sheetError!, style: AppText.muted.copyWith(color: AppColors.danger)),
                  ),
                Row(children: [
                  Expanded(child: PwtButton('Cancel', variant: PwtBtn.outline, fullWidth: true, onPressed: saving ? null : () => Navigator.pop(ctx))),
                  const SizedBox(width: 12),
                  Expanded(child: saving
                    ? const SizedBox(height: 44, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    : PwtButton(edit == null ? 'Save address' : 'Save changes', fullWidth: true, onPressed: () async {
                        set(() { saving = true; sheetError = null; });
                        final u = AppState.instance.user;
                        final cityName = selCity?.name ?? '';
                        final res = edit != null && edit.id != null
                            ? await updateAddress(
                                addressId: edit.id!,
                                label: label.text.trim(),
                                line1: l1.text.trim(),
                                line2: l2.text.trim().isEmpty ? null : l2.text.trim(),
                                city: cityName.isEmpty ? null : cityName,
                                postalCode: pc.text.trim().isEmpty ? null : pc.text.trim(),
                                countryId: selCountry?.id,
                                isDefault: def,
                                recipientName: u?.name,
                                recipientPhone: u?.phone,
                              )
                            : await createAddress(
                                label: label.text.trim().isEmpty ? 'Address' : label.text.trim(),
                                line1: l1.text.trim(),
                                line2: l2.text.trim().isEmpty ? null : l2.text.trim(),
                                city: cityName.isEmpty ? null : cityName,
                                postalCode: pc.text.trim().isEmpty ? null : pc.text.trim(),
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
                      }),
                  ),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }

  void _cardSheet() {
    final formKey       = GlobalKey<FormState>();
    final holderCtrl    = TextEditingController();
    final stripeCardKey = GlobalKey<StripeCardFieldsState>();
    bool def = false;
    bool cardComplete = false;
    bool cardTouched = false;
    String? cardError;
    bool submitting = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 22, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (ctx, set) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(child: Text('Add card', style: AppText.h2.copyWith(fontSize: 19))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 12),
                _formField('Cardholder name', holderCtrl, hint: 'John Doe'),
                const SizedBox(height: 14),
                Text('Card details', style: AppText.label),
                const SizedBox(height: 7),
                // Card number/expiry/CVV are typed straight into Stripe's own
                // embedded Card Element (an iframe Stripe controls) — those
                // digits go directly to Stripe and never pass through our
                // Flutter code or our backend.
                StripeCardFields(
                  key: stripeCardKey,
                  publishableKey: kStripePublishableKey,
                  onChange: (complete, error) => set(() { cardComplete = complete; cardError = error; }),
                ),
                if (cardError != null) ...[
                  const SizedBox(height: 6),
                  Text(cardError!, style: AppText.muted.copyWith(color: AppColors.danger, fontSize: 12)),
                ] else if (cardTouched && !cardComplete) ...[
                  const SizedBox(height: 6),
                  Text('Enter your card details to continue.', style: AppText.muted.copyWith(color: AppColors.danger, fontSize: 12)),
                ],
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: Text('Set as default card', style: AppText.label)),
                  PwtToggle(value: def, onChanged: (v) => set(() => def = v)),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: PwtButton('Cancel', variant: PwtBtn.outline, fullWidth: true, onPressed: () => Navigator.pop(ctx))),
                  const SizedBox(width: 12),
                  Expanded(child: PwtButton(
                    submitting ? 'Saving…' : 'Add card',
                    fullWidth: true,
                    onPressed: submitting ? null : () async {
                      if (!formKey.currentState!.validate()) return;
                      if (!cardComplete) { set(() => cardTouched = true); return; }
                      set(() => submitting = true);
                      final result = await stripeCardKey.currentState!.createPaymentMethod(
                        cardholderName: holderCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      if (!result.success || result.paymentMethodId == null) {
                        set(() => submitting = false);
                        _toast(result.errorMessage ?? 'Failed to save card.');
                        return;
                      }
                      // Stripe's own response — never shown to the user,
                      // console only, for verifying the tokenization step.
                      debugPrint('[Stripe createPaymentMethod] id=${result.paymentMethodId} brand=${result.brand} last4=${result.last4} exp=${result.expMonth}/${result.expYear}');
                      debugPrint('[Stripe createPaymentMethod] full response:\n${result.rawJson}');
                      final saveRes = await createPaymentCard(
                        paymentMethodId: result.paymentMethodId!,
                        isDefault: def,
                      );
                      if (!mounted) return;
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (saveRes.success) {
                        _loadCards();
                      } else {
                        _toast(saveRes.message ?? 'Failed to save card.');
                      }
                    },
                  )),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _sheet({required String title, required List<Widget> fields, required String saveLabel, required VoidCallback onSave, bool Function()? validate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 22, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [Expanded(child: Text(title, style: AppText.h2.copyWith(fontSize: 19))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))]),
            const SizedBox(height: 12),
            ...fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 14), child: f)),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: PwtButton('Cancel', variant: PwtBtn.outline, fullWidth: true, onPressed: () => Navigator.pop(ctx))),
              const SizedBox(width: 12),
              Expanded(child: PwtButton(saveLabel, fullWidth: true, onPressed: () { if (validate != null && !validate()) return; onSave(); Navigator.pop(ctx); })),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController c, {String? hint, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        TextFormField(
          controller: c,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint ?? label),
          validator: validator,
        ),
      ]);

  Widget _sheetField(String label, TextEditingController c, {String? hint}) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        TextField(controller: c, decoration: InputDecoration(hintText: hint ?? label)),
      ]);
}

String _profileFlagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}
