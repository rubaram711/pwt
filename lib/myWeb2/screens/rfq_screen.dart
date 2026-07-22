import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';
import '../../Backend/Products/get_products.dart';
import '../../Backend/Rfq/create_rfq.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Models/Products/products_model.dart';
import '../../Models/Rfq/rfq_model.dart';
import '../../Models/Reference/country_model.dart';
import '../state/app_state.dart';

class RfqScreen extends StatefulWidget {
  const RfqScreen({super.key, this.preselectedProductId, this.preselectedProductName, this.preselectedProductCode});
  final int? preselectedProductId;
  final String? preselectedProductName;
  final String? preselectedProductCode;

  @override
  State<RfqScreen> createState() => _RfqScreenState();
}

class _RfqScreenState extends State<RfqScreen> {
  // Form controllers
  final _companyName      = TextEditingController();
  final _companyEmail     = TextEditingController();
  final _contactName      = TextEditingController();
  final _jobTitle         = TextEditingController();
  final _businessEmail    = TextEditingController();
  final _phone            = TextEditingController();
  final _totalQty         = TextEditingController();
  final _requiredBy       = TextEditingController();
  final _installLocation  = TextEditingController();
  final _notes            = TextEditingController();

  // Products
  String _countryCode = '+971';
  String _countryIso = 'AE';
  bool _phoneLibReady = false;
  List<CountryModel> _countries = [];

  List<ProductModel> _products = [];
  bool _loadingProducts = true;
  int _page = 1;
  int _totalPages = 1;
  final _searchCtrl = TextEditingController();
  final Set<int> _pickedIds = {};

  // Submission state
  bool _submitting = false;
  String? _error;
  RfqModel? _submitted;

  Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    final user = AppState.instance.user;
    if (user?.companyName?.isNotEmpty == true) _companyName.text = user!.companyName!;
    if (user?.email?.isNotEmpty == true) _companyEmail.text = user!.email!;
    if (user?.phoneCountryCode?.isNotEmpty == true) _countryCode = user!.phoneCountryCode!;
    if (user?.phone?.isNotEmpty == true) {
      final raw = user!.phone!;
      _phone.text = raw.startsWith(_countryCode) ? raw.substring(_countryCode.length).trim() : raw;
    }
    _fetchProducts();
    _ensurePhoneLib();
    getCountries().then((res) {
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _countries = res.data!.where((c) => (c.phoneCode ?? '').isNotEmpty).toList();
          final match = _countries.firstWhere((c) => c.phoneCode == _countryCode, orElse: () => CountryModel());
          if (match.code != null) _countryIso = match.code!.toUpperCase();
        });
      }
    });
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
    _companyName.dispose();
    _companyEmail.dispose();
    _contactName.dispose();
    _jobTitle.dispose();
    _businessEmail.dispose();
    _phone.dispose();
    _totalQty.dispose();
    _requiredBy.dispose();
    _installLocation.dispose();
    _notes.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({int page = 1}) async {
    setState(() { _loadingProducts = true; _page = page; });
    final res = await getProducts(
      page: page,
      perPage: 10,
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    );
    if (!mounted) return;
    final pagination = res.data?.pagination;
    setState(() {
      _loadingProducts = false;
      if (res.success && res.data != null) {
        _products = res.data!.items;
        _totalPages = pagination?.lastPage ?? 1;
        if (page == 1 && widget.preselectedProductId != null) {
          _pickedIds.add(widget.preselectedProductId!);
        }
      }
    });
  }

  Future<bool> _validate() async {
    final e = <String, String?>{};
    if (_companyName.text.trim().isEmpty) e['companyName'] = 'Company name is required';

    final email = _companyEmail.text.trim();
    if (email.isEmpty) {
      e['companyEmail'] = 'Email is required';
    } else if (!EmailValidator.validate(email)) {
      e['companyEmail'] = 'Please enter a valid email address.';
    }

    final phone = _phone.text.trim();
    if (phone.isEmpty) {
      e['phone'] = 'Phone number is required';
    } else {
      await _ensurePhoneLib();
      try {
        if (_phoneLibReady) await parse(phone, region: _countryIso);
      } catch (_) {
        e['phone'] = 'Please enter a valid mobile number for the selected country.';
      }
    }

    setState(() => _errors = e);
    return e.isEmpty;
  }

  Future<void> _submit() async {
    if (!await _validate()) return;
    setState(() { _submitting = true; _error = null; });

    final res = await createRfq(
      companyName:          _companyName.text.trim(),
      email:                _companyEmail.text.trim(),
      phoneCountryCode:     _countryCode,
      phone:                _phone.text.trim(),
      notes:                _notes.text.trim(),
      // contactName:          _contactName.text.trim(),
      // jobTitle:             _jobTitle.text.trim(),
      // businessEmail:        _businessEmail.text.trim(),
      // preferredProducts:    _pickedIds.toList(),
      // totalQuantity:        _totalQty.text.trim(),
      // requiredBy:           _requiredBy.text.trim(),
      // installationLocation: _installLocation.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.success && res.data != null) {
      setState(() => _submitted = res.data);
    } else {
      setState(() => _error = res.message ?? res.error ?? 'Failed to submit request. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted != null) return _successView(_submitted!);

    final wide = MediaQuery.of(context).size.width > 980;
    return StoreScaffold(active: '/shop', showFooter: false, slivers: [
      SliverToBoxAdapter(
        child: Band(
          color: AppColors.ink900,
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 34),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.description_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: const Text('FOR BUSINESS', style: TextStyle(color: Color(0xFF9CC1ED), fontWeight: FontWeight.w700, fontSize: 11)),
              ),
              const SizedBox(height: 8),
              Text('Request a Quotation', style: AppText.headline(wide ? 30 : 24).copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Text('Tell us about your business needs and our team will contact you with a custom quotation — no payment required.', style: AppText.body.copyWith(color: const Color(0xFFC4CCDD), height: 1.5)),
            ])),
          ]),
        ),
      ),
      SliverToBoxAdapter(
        child: Band(child: Flex(
          direction: wide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: wide ? 3 : 0, child: Column(children: [
              _card('Company Information', '', Column(children: [
                _field('Company name', 'Acme Facilities Ltd', _companyName, errorKey: 'companyName'),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _field('Email', 'info@company.com', _companyEmail, errorKey: 'companyEmail', keyboardType: TextInputType.emailAddress)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Phone number', style: AppText.label),
                    const SizedBox(height: 7),
                    Row(children: [
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: _errors['phone'] != null ? const Color(0xFFDC2626) : AppColors.line), borderRadius: BorderRadius.circular(AppRadius.sm)),
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
                                    child: Text('${_rfqFlagFromCode(c.code)} ${c.phoneCode}'),
                                  )).toList(),
                            onChanged: (v) => setState(() {
                              _countryCode = v!;
                              final match = _countries.firstWhere((c) => c.phoneCode == v, orElse: () => CountryModel());
                              if (match.code != null) _countryIso = match.code!.toUpperCase();
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(hintText: '50 123 4567', errorText: _errors['phone']),
                          onChanged: (_) => setState(() => _errors.remove('phone')),
                        ),
                      ),
                    ]),
                  ])),
                ]),
                const SizedBox(height: 14),
                _field('Notes / comments', 'Products, quantities, required within 1 month, address…', _notes, lines: 4),
                // Trade license upload — coming soon
              ])),
              // Step 2 — Contact Person (commented out for now)
              // _card('Contact Person', 'Step 2 of 3', Column(children: [
              //   Row(children: [
              //     Expanded(child: _field('Full name', 'Ahmed Hassan', _contactName)),
              //     const SizedBox(width: 12),
              //     Expanded(child: _field('Job title', 'Facilities Manager', _jobTitle)),
              //   ]),
              //   const SizedBox(height: 14),
              //   _field('Business email', 'ahmed@company.com', _businessEmail),
              // ])),
              // Step 3 — Your Requirements (commented out for now)
              // _card('Your Requirements', 'Step 3 of 3', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //   Text('Preferred products', style: AppText.label),
              //   ... product picker, pagination, total qty, required by, installation location ...
              //   _field('Notes / comments', '...', _notes, lines: 3),
              // ])),
            ])),
            SizedBox(width: wide ? 22 : 0, height: wide ? 0 : 22),
            Expanded(flex: wide ? 2 : 0, child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Why request a quote?', style: AppText.h3),
                const SizedBox(height: 6),
                Text('Tailored B2B pricing and support for your organisation.', style: AppText.body.copyWith(color: AppColors.ink500)),
                const SizedBox(height: 16),
                ...['Personalised volume pricing', 'Dedicated account manager', 'Flexible installation & service plans', 'Priority after-sales support'].map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [const Icon(Icons.check, size: 16, color: AppColors.blue600), const SizedBox(width: 10), Expanded(child: Text(t, style: AppText.body))]),
                )),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Row(children: [const Icon(Icons.info_outline, size: 16, color: AppColors.blue700), const SizedBox(width: 10), Expanded(child: Text('Our team will contact you with a custom quotation within 24 hours.', style: AppText.muted.copyWith(color: AppColors.blue800)))]),
                ),
                const SizedBox(height: 16),
                PwtButton(
                  _submitting ? 'Submitting…' : 'Submit Request',
                  icon: Icons.arrow_forward,
                  fullWidth: true,
                  onPressed: _submitting ? null : _submit,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: const Color(0xFFFECACA))),
                    child: Row(children: [
                      const Icon(Icons.error_outline, size: 15, color: Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: AppText.muted.copyWith(color: const Color(0xFFDC2626)))),
                    ]),
                  ),
                ],
              ]),
            )),
          ],
        )),
      ),
    ]);
  }

  Widget _successView(RfqModel rfq) {
    return StoreScaffold(active: '/', showFooter: false, slivers: [
      SliverToBoxAdapter(
        child: Band(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Column(children: [
          Container(
            width: 84, height: 84,
            decoration: const BoxDecoration(color: AppColors.badgeGreenBg, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 44, color: AppColors.green600),
          ),
          const SizedBox(height: 18),
          Text('Quotation Request Received!', style: AppText.headline(28), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text("Thank you. We've received your request. Our team will contact you with a custom quotation tailored to your business needs.", style: AppText.bodyLg.copyWith(height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Request ID chip — commented out for now
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          //   decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.pill)),
          //   child: Row(mainAxisSize: MainAxisSize.min, children: [
          //     Text('Request ID  ', style: AppText.muted),
          //     Text('PWT-RFQ-${rfq.id}', style: AppText.label),
          //   ]),
          // ),
          const SizedBox(height: 30),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            PwtButton('Back to Shop', onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/shop', (r) => false)),
            PwtButton('Go Home', variant: PwtBtn.outline, onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false)),
          ]),
        ])))),
      ),
    ]);
  }

  Widget _productTile(ProductModel p, bool wide) {
    final on = _pickedIds.contains(p.id);
    return GestureDetector(
      onTap: () => setState(() => on ? _pickedIds.remove(p.id) : _pickedIds.add(p.id!)),
      child: Container(
        width: wide ? 250 : double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? AppColors.blue50 : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: on ? AppColors.blue600 : AppColors.line, width: on ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(5),
            child: p.primaryImageUrl != null
                ? Image.network(p.primaryImageUrl!, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 22, color: AppColors.blue200))
                : const Icon(Icons.water_drop_outlined, size: 22, color: AppColors.blue200),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.code ?? p.name ?? '', style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (p.shortDescription != null)
              Text(p.shortDescription!, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Icon(on ? Icons.check_circle : Icons.circle_outlined, size: 18, color: on ? AppColors.blue700 : AppColors.ink300),
        ]),
      ),
    );
  }

  Widget _card(String title, String step, Widget child) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: AppText.h3)),
            Text(step, style: AppText.muted.copyWith(color: AppColors.blue700, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          child,
        ]),
      );

  Widget _field(String label, String hint, TextEditingController ctrl, {int lines = 1, String? errorKey, TextInputType? keyboardType}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        TextField(
          controller: ctrl,
          maxLines: lines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorKey != null ? _errors[errorKey] : null,
          ),
          onChanged: errorKey != null ? (_) => setState(() => _errors.remove(errorKey)) : null,
        ),
      ]);
}

String _rfqFlagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}

// RfqConfirmationScreen kept for backward compat with any direct /rfqConfirmation route
class RfqConfirmationScreen extends StatelessWidget {
  const RfqConfirmationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StoreScaffold(active: '/', showFooter: false, slivers: [
      SliverToBoxAdapter(
        child: Band(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: Column(children: [
          Container(width: 84, height: 84, decoration: const BoxDecoration(color: AppColors.badgeGreenBg, shape: BoxShape.circle), child: const Icon(Icons.check, size: 44, color: AppColors.green600)),
          const SizedBox(height: 18),
          Text('Quotation Request Received!', style: AppText.headline(28), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text("Thank you. Our team will contact you within 24 hours.", style: AppText.bodyLg.copyWith(height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PwtButton('Back to Shop', onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/shop', (r) => false)),
        ])))),
      ),
    ]);
  }
}
