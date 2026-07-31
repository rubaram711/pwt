// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/site_chrome.dart';
import '../../Backend/Reference/get_public_settings.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Backend/submit_contact_form.dart';
import '../../Models/Reference/settings_location_model.dart';
import '../../Models/Reference/country_model.dart';

// ===================== PALETTE =====================
class _C {
  static const ink900 = Color(0xFF0B1C3F);
  static const ink800 = Color(0xFF14213D);
  static const ink700 = Color(0xFF1F2A44);
  static const ink600 = Color(0xFF5B6478);
  static const ink500 = Color(0xFF5B6478);
  static const ink400 = Color(0xFF8A93A6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const navBorder = Color(0xFFEEF1F6);
  static const cardBorder = Color(0xFFE7ECF4);
  static const softBorder = Color(0xFFE4EBF5);
  static const iconBg = Color(0xFFEEF4FF);
  static const consultIcoBg = Color(0xFFE3EDFF);
  static const inputBg = Color(0xFFF8FAFD);
  static const segBg = Color(0xFFF0F5FC);
  static const waGreen = Color(0xFF25A05A);
  static const waBg = Color(0xFFE4F7EC);
  static const checkBg = Color(0xFFDCEFE4);
  static const checkFg = Color(0xFF1F8A5B);
  static const red = Color(0xFFE5484D);
  static const placeholder = Color(0xFF9AA3B5);
  static const methodBlueBg = Color(0xFFE6EFFF);
  static const softBtnBg = Color(0xFFEAF2FF);
}

// ===================== SCREEN =====================
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  int _inq = 0;
  bool _sent = false;
  bool _submitting = false;
  String? _formError;
  int _faqOpen = -1;
  String _country = '+971';
  List<CountryModel> _countries = [];
  String? _inqType;
  String? _phoneNumber;
  String? _whatsappNumber;
  String? _contactEmail;
  SettingsLocationModel? _location;

  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl     = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCountryCodes();
    getPublicSettings().then((result) {
      if (mounted && result.success && result.data != null) {
        setState(() {
          _phoneNumber    = result.data!.phoneNumber;
          _whatsappNumber = result.data!.whatsappNumber;
          _contactEmail   = result.data!.contactEmail;
          _location       = result.data!.location;
        });
      }
    });
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
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _openLocation() {
    final String? url;
    if (_location?.mapUrl != null && _location!.mapUrl!.isNotEmpty) {
      url = _location!.mapUrl!;
    } else if (_location?.latitude != null && _location?.longitude != null) {
      url = 'https://www.google.com/maps?q=${_location!.latitude},${_location!.longitude}';
    } else if (_location?.address != null && _location!.address!.isNotEmpty) {
      url = 'https://www.google.com/maps/search/${Uri.encodeComponent(_location!.address!)}';
    } else {
      url = null;
    }
    if (url == null) return;
    js.context.callMethod('open', [url, '_blank']);
  }

  void _openWhatsAppTrialChat() {
    final digits = ('971556539575').replaceAll(RegExp(r'\D'), '');
    final text = Uri.encodeComponent('I want to try one week for free');
    html.window.open('https://web.whatsapp.com/send?phone=$digits&text=$text', '_blank');
  }

  Future<void> _submit() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final phone   = '$_country${_phoneCtrl.text.trim()}';
    final subject = _subjectCtrl.text.trim();
    final message = _msgCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || subject.isEmpty || message.isEmpty) {
      setState(() => _formError = 'Please fill in all required fields.');
      return;
    }
    setState(() { _submitting = true; _formError = null; });
    final result = await submitContactForm(
      name: name,
      email: email,
      phone: phone,
      subject: subject,
      message: message,
      type: _inq == 0 ? 'general' : 'business',
    );
    if (!mounted) return;
    if (result.success) {
      setState(() { _sent = true; _submitting = false; });
    } else {
      setState(() { _formError = result.message ?? 'Failed to send. Please try again.'; _submitting = false; });
    }
  }

  static const _faqs = [
    ['How does the rental plan work?', 'Choose a plan, we install your system, and you pay a fixed monthly fee that covers servicing and filter changes — cancel or upgrade anytime.'],
    ['Is installation included?', 'Yes. Professional installation by a certified PWT technician is included with every rental and most purchases.'],
    ['How long does delivery take?', 'Standard delivery is 3–5 business days. Same-week installation slots are usually available in major cities.'],
    ['Do you offer maintenance and filter replacement?', 'Absolutely. We schedule proactive filter reminders and send a technician for every service visit — included on all rental plans.'],
    ['Can companies request custom pricing?', 'Yes — submit an RFQ and our business team will prepare volume pricing, multi-site rollout and account terms tailored to you.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SiteHeader(active: '/contact'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble, size: 28),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(),
            Transform.translate(
              offset: const Offset(0, -58),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Band(top: 0, bottom: 0, child: _buildMethods()),
                  _Band(top: 44, bottom: 8, child: _buildMain()),
                  _Band(top: 8, bottom: 36, child: _buildLower()),
                  _Band(top: 0, bottom: 0, child: _buildTrustBar()),
                  _buildCta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== HERO ===================
  Widget _buildHero() {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth;
      final narrow = w < 760;
      final stacked = w <= 980;
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEF5FF), Color(0xFFE7F0FD), Color(0xFFEAF3FE)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Padding(
              padding: EdgeInsets.fromLTRB(narrow ? 20 : 40, 18, narrow ? 20 : 40, 88),
              child: stacked
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [_heroCopy(w), const SizedBox(height: 20), _heroArt(w)],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 100, child: _heroCopy(w)),
                  const SizedBox(width: 24),
                  Expanded(flex: 108, child: _heroArt(w)),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _heroCopy(double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('CONTACT US',
            style: TextStyle(color: _C.blue600, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2.1)),
        const SizedBox(height: 14),
        Text("We're Here to Help",
            style: TextStyle(
                fontSize: w < 760 ? 34 : 46,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
                height: 1.08,
                color: _C.ink900)),
        const SizedBox(height: 18),
        SizedBox(
          width: 430,
          child: Text(
            'Our water experts are ready to help you choose, install, and maintain the perfect water solution for your home or business.',
            style: const TextStyle(fontSize: 16, height: 1.6, color: _C.ink500),
          ),
        ),
        const SizedBox(height: 26),
        _audCard(w),
      ],
    );
  }

  Widget _audCard(double w) {
    final stacked = w < 760;
    Widget item(IconData ic, String h, String p) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: _C.iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(ic, size: 19, color: _C.blue700)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(h, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _C.ink900)),
                const SizedBox(height: 3),
                Text(p, style: const TextStyle(fontSize: 12.5, height: 1.45, color: _C.ink500)),
              ],
            ),
          ),
        ],
      ),
    );

    final a = item(Icons.person_outline, 'For Home Users', 'Questions about products, rentals or orders');
    final b = item(Icons.apartment, 'For Businesses', 'Consultations, quotes and bulk solutions');

    return Container(
      width: w <= 980 ? double.infinity : 520,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _C.softBorder),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF10254E).withOpacity(.07), blurRadius: 30, offset: const Offset(0, 12))]),
      child: stacked
          ? Column(mainAxisSize: MainAxisSize.min, children: [a, const Divider(height: 1, color: _C.navBorder), b])
      // KEY FIX: no crossAxisAlignment: stretch on Row inside scroll
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          Container(width: 1, height: 70, color: _C.navBorder),
          Expanded(child: b),
        ],
      ),
    );
  }

  Widget _heroArt(double w) {
    final h = w <= 980 ? 340.0 : 420.0;
    final scale = w <= 980 ? 0.8 : 1.0;
    return SizedBox(
      height: h,
      child: Stack(alignment: Alignment.center, children: [
        Center(
          child: Container(
            width: 480 * scale, height: 480 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                  colors: [Color(0xA6FFFFFF), Color(0x59DDEBFF), Color(0x00DDEBFF)],
                  stops: [0.0, 0.5, 0.72]),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _unit('assets/images/hero-u1.png', 322 * scale),
                  SizedBox(width: 18 * scale),
                  _unit('assets/images/hero-u2.png', 312 * scale),
                  SizedBox(width: 18 * scale),
                  _unit('assets/images/hero-u3.png', 228 * scale),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _unit(String path, double height) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(path,
          height: height, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => SizedBox(height: height, width: height * 0.42)),
      Container(
        margin: const EdgeInsets.only(top: 2),
        width: height * 0.5, height: 16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: RadialGradient(
              colors: [
                const Color(0xFF10254E).withOpacity(.30),
                const Color(0xFF10254E).withOpacity(.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.44, 0.72]),
        ),
      ),
    ],
  );

  // =================== CONTACT METHODS ===================
  Widget _buildMethods() {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth;
      final twoCol = w > 820;

      // KEY FIX: _cmPair no longer uses IntrinsicHeight or crossAxisAlignment: stretch
      Widget cmPair(List<Widget> items) {
        final stacked = w < 520;
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _C.cardBorder),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF10254E).withOpacity(.08), blurRadius: 34, offset: const Offset(0, 14))]),
          clipBehavior: Clip.antiAlias,
          child: stacked
              ? Column(mainAxisSize: MainAxisSize.min, children: [
            items[0],
            const Divider(height: 1, color: _C.navBorder),
            items[1],
          ])
              : Row(
            // FIX: start, not stretch — avoids h=Infinity propagation
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: items[0]),
              Container(width: 1, height: 88, color: _C.navBorder),
              Expanded(child: items[1]),
            ],
          ),
        );
      }

      Widget cmItem(IconData ic, String h, String p, String val, Color fg, Color bg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(ic, size: 23, color: fg)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(h, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.ink900)),
                  const SizedBox(height: 3),
                  Text(p, style: const TextStyle(fontSize: 12.5, color: _C.ink500)),
                  const SizedBox(height: 3),
                  Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.blue700)),
                ],
              ),
            ),
          ],
        ),
      );

      final call  = cmItem(Icons.call, 'Call Us', 'Speak with our experts', _phoneNumber ?? '+971 4 123 4567', _C.blue700, _C.methodBlueBg);
      final wa    = cmItem(Icons.chat_bubble_outline, 'WhatsApp', 'Instant support', _whatsappNumber ?? '+971 50 123 4567', _C.waGreen, _C.waBg);
      final email = cmItem(Icons.mail_outline, 'Email Us', 'We reply within 24h', _contactEmail ?? 'info@pwtwater.com', _C.blue700, _C.methodBlueBg);
      final loc   = MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: _openLocation, child: cmItem(Icons.location_on_outlined, 'Our Location', 'Visit our showroom', _location?.address ?? 'View on Map →', _C.blue700, _C.methodBlueBg)));

      if (twoCol) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cmPair([call, wa])),
            const SizedBox(width: 22),
            Expanded(child: cmPair([email, loc])),
          ],
        );
      }
      return Column(children: [cmPair([call, wa]), const SizedBox(height: 22), cmPair([email, loc])]);
    });
  }

  // =================== MAIN 3-COL ===================
  Widget _buildMain() {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth;

      final form  = _buildFormCard();
      final mid   = _colStack([_buildConsultCard(), _buildExistCard()]);
      final right = _colStack([_buildFaqCard(), _buildHoursCard()]);

      if (w > 1180) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 118, child: form),
            const SizedBox(width: 24),
            Expanded(flex: 90, child: mid),
            const SizedBox(width: 24),
            Expanded(flex: 90, child: right),
          ],
        );
      }
      if (w > 760) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            form,
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: mid), const SizedBox(width: 24), Expanded(child: right)],
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [form, const SizedBox(height: 24), mid, const SizedBox(height: 24), right],
      );
    });
  }

  Widget _colStack(List<Widget> children) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i < children.length - 1) out.add(const SizedBox(height: 24));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: out);
  }

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(26), Gradient? gradient, Color? border}) =>
      Container(
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? Colors.white : null,
          gradient: gradient,
          border: Border.all(color: border ?? _C.cardBorder),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: const Color(0xFF10254E).withOpacity(.05), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: child,
      );

  // ---- form card ----
  Widget _buildFormCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Send Us a Message',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: _C.ink900)),
          const SizedBox(height: 5),
          const Text('Fill out the form and our team will get back to you as soon as possible.',
              style: TextStyle(fontSize: 13.5, height: 1.5, color: _C.ink500)),
          const SizedBox(height: 20),
          if (_sent)
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                  color: const Color(0xFFE6F7ED),
                  border: Border.all(color: const Color(0xFFB9E6CC)),
                  borderRadius: BorderRadius.circular(11)),
              child: const Row(children: [
                Icon(Icons.check, size: 17, color: _C.checkFg),
                SizedBox(width: 9),
                Expanded(
                    child: Text("Thanks! Your message has been sent — we'll be in touch shortly.",
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _C.checkFg))),
              ]),
            ),
          // segmented
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: _C.segBg, border: Border.all(color: _C.cardBorder), borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              _segBtn('General Inquiry', Icons.person_outline, 0),
              const SizedBox(width: 6),
              _segBtn('Business Consultation', Icons.apartment, 1),
            ]),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(builder: (_, c) {
            final twoCol = c.maxWidth > 440;
            Widget row(Widget a, Widget b) => twoCol
                ? Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: a), const SizedBox(width: 16), Expanded(child: b)])
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, b]);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                row(_field('Full Name', child: _input('Enter your full name', controller: _nameCtrl)),
                    _field('Email Address', child: _input('Enter your email', controller: _emailCtrl))),
                row(_field('Mobile Number', child: _phoneField()),
                    _field('Inquiry Type', child: _inquiryDropdown())),
                _field('Subject', child: _input('Enter subject', controller: _subjectCtrl)),
                _field('Message', child: _input('How can we help you?', lines: 4, controller: _msgCtrl)),
              ],
            );
          }),
          if (_formError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 16, color: _C.red),
                const SizedBox(width: 8),
                Expanded(child: Text(_formError!, style: const TextStyle(fontSize: 13, color: _C.red))),
              ]),
            ),
          ],
          const SizedBox(height: 6),
          LayoutBuilder(builder: (_, c) {
            final stacked = c.maxWidth < 440;
            const note = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 15, color: _C.checkFg),
                SizedBox(width: 7),
                Flexible(child: Text('Your information is secure and confidential.',
                    style: TextStyle(fontSize: 12.5, color: _C.ink500))),
              ],
            );
            final btn = GestureDetector(
              onTap: _submitting ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                    color: _submitting ? _C.blue700.withOpacity(.6) : _C.blue700,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: _submitting ? null : [BoxShadow(color: _C.blue700.withOpacity(.24), blurRadius: 22, offset: const Offset(0, 10))]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_submitting ? 'Sending…' : 'Send Message', style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 9),
                  const Icon(Icons.send, size: 16, color: Colors.white),
                ]),
              ),
            );
            return stacked
                ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [note, const SizedBox(height: 12), btn])
                : Row(children: [const Expanded(child: note), btn]);
          }),
        ],
      ),
    );
  }

  Widget _segBtn(String label, IconData ic, int i) {
    final on = _inq == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _inq = i),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: on ? [BoxShadow(color: const Color(0xFF10254E).withOpacity(.10), blurRadius: 8, offset: const Offset(0, 2))] : null),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ic, size: 16, color: on ? _C.blue700 : _C.ink500),
              const SizedBox(width: 8),
              Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: on ? _C.blue700 : _C.ink500))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, {required Widget child}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.ink800)),
          const Text(' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.red)),
        ]),
        const SizedBox(height: 7),
        child,
      ],
    ),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _C.placeholder, fontSize: 14.5),
    filled: true, fillColor: _C.inputBg, isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _C.softBorder, width: 1.5)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _C.blue600, width: 1.5)),
  );

  Widget _input(String hint, {int lines = 1, TextEditingController? controller}) =>
      TextField(controller: controller, maxLines: lines, style: const TextStyle(fontSize: 14.5, color: _C.ink900), decoration: _dec(hint));

  Widget _phoneField()
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: _C.inputBg, border: Border.all(color: _C.softBorder, width: 1.5), borderRadius: BorderRadius.circular(11)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _country, isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: _C.ink400),
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: _C.ink900),
              items: _countries.isEmpty
                  ? [DropdownMenuItem(value: _country, child: Text(_country))]
                  : _countries.map((c) => DropdownMenuItem(
                      value: c.phoneCode!,
                      child: Text('${_contactFlagFromCode(c.code)} ${c.phoneCode}'),
                    )).toList(),
              onChanged: (v) => setState(() => _country = v!),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14.5, color: _C.ink900),
              decoration: _dec('50 123 4567'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inquiryDropdown() {
    const opts = ['Buying a system', 'Renting a system', 'Business quotation (RFQ)', 'Maintenance & support', 'General question'];
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: _C.inputBg, border: Border.all(color: _C.softBorder, width: 1.5), borderRadius: BorderRadius.circular(11)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _inqType, isExpanded: true,
          hint: const Text('Select inquiry type', style: TextStyle(fontSize: 14.5, color: _C.placeholder)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: _C.ink400),
          style: const TextStyle(fontSize: 14.5, color: _C.ink900),
          items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) => setState(() => _inqType = v),
        ),
      ),
    );
  }

  // ---- consult card ----
  Widget _buildConsultCard() {
    return _card(
      gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F9FF), Color(0xFFEEF5FE)]),
      border: const Color(0xFFDFE9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: _C.consultIcoBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.water_drop_outlined, size: 22, color: _C.blue700)),
            const SizedBox(width: 14),
            // Subtitle below hidden for now.
            // SizedBox(height: 5),
            // Text('Not sure which system is right for you? Book a free call with our water experts.',
            //     style: TextStyle(fontSize: 13, height: 1.5, color: _C.ink500)),
            const Expanded(
              child: Text('Start Your Free 7-Day Trial',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _C.ink900)),
            ),
          ]),
          const SizedBox(height: 16),
          ...[
            ('Free Installation', "We'll install your system at no cost."),
            ('Free to Use for 7 Days', 'Experience clean, purified water with no commitment.'),
            ('No Obligation', "Decide only after you've tried it."),
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 18, height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(color: _C.checkBg, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 11, color: _C.checkFg)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.$1, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _C.ink700)),
                const SizedBox(height: 2),
                Text(item.$2, style: const TextStyle(fontSize: 12, color: _C.ink500)),
              ])),
            ]),
          )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _openWhatsAppTrialChat,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: _C.blue700, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _C.blue700.withOpacity(.26), blurRadius: 24, offset: const Offset(0, 10))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Chat with us', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(width: 9),
                SvgPicture.string(_kContactWaSvg, width: 17, height: 17),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ---- existing customer card ----
  Widget _buildExistCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Existing Customer?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _C.ink900)),
                SizedBox(height: 5),
                Text('Need support or maintenance?', style: TextStyle(fontSize: 13, color: _C.ink500)),
              ]),
            ),
            const SizedBox(width: 14),
            Container(
              width: 78, height: 78,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const RadialGradient(center: Alignment(0, -0.4), radius: 0.7,
                      colors: [Color(0xFFF6F9FF), Color(0xFFE6EEF9)])),
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/images/pw90.png', fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          ]),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/maintenance'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: _C.softBtnBg, borderRadius: BorderRadius.circular(11)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.build_outlined, size: 16, color: _C.blue700),
                SizedBox(width: 9),
                Text('Request Maintenance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.blue700)),
                SizedBox(width: 9),
                Icon(Icons.arrow_forward, size: 16, color: _C.blue700),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ---- faq card ----
  Widget _buildFaqCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Frequently Asked Questions',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _C.ink900)),
          const SizedBox(height: 16),
          ...List.generate(_faqs.length, (i) {
            final open = _faqOpen == i;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: open ? const Color(0xFFD6E0EF) : _C.cardBorder),
                  borderRadius: BorderRadius.circular(11)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() => _faqOpen = open ? -1 : i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Expanded(
                            child: Text(_faqs[i][0],
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: open ? _C.blue700 : _C.ink800))),
                        const SizedBox(width: 12),
                        AnimatedRotation(
                            turns: open ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.keyboard_arrow_down, size: 16, color: _C.ink400)),
                      ]),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: open
                        ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_faqs[i][1],
                              style: const TextStyle(fontSize: 13, height: 1.55, color: _C.ink500)),
                        ))
                        : const SizedBox(width: double.infinity, height: 0),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/support'),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('View All FAQs', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _C.blue700)),
              SizedBox(width: 7),
              Icon(Icons.arrow_forward, size: 15, color: _C.blue700),
            ]),
          ),
        ],
      ),
    );
  }

  // ---- hours card ----
  Widget _buildHoursCard() {
    Widget row(String day, String time, bool closed) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(day, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: _C.ink700)),
        Text(time, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: closed ? _C.red : _C.ink900)),
      ]),
    );
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: _C.methodBlueBg, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.schedule, size: 21, color: _C.blue700)),
            const SizedBox(width: 12),
            const Text('Working Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _C.ink900)),
          ]),
          const SizedBox(height: 8),
          row('Monday – Friday', '8:00 AM - 6:00 PM', false),
          const Divider(height: 1, color: _C.navBorder),
          row('Saturday', '9:00 AM - 4:00 PM', false),
          const Divider(height: 1, color: _C.navBorder),
          row('Sunday', 'Closed', true),
        ],
      ),
    );
  }

  // =================== LOWER BAND ===================
  Widget _buildLower() {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth;
      if (w > 900) {
        // KEY FIX: crossAxisAlignment: start — never stretch inside scroll
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 185, child: _buildShowroom()),
            const SizedBox(width: 24),
            Expanded(flex: 100, child: _buildPartner()),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildShowroom(), const SizedBox(height: 24), _buildPartner()],
      );
    });
  }

  Widget _buildShowroom() {
    return LayoutBuilder(builder: (_, bc) {
      final stacked = bc.maxWidth < 640;
      final mapWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _openLocation,
          child: Container(
            height: stacked ? 200 : 260,
            decoration: const BoxDecoration(color: Color(0xFFEEF3FA)),
            child: CustomPaint(
              painter: _MapGridPainter(),
              child: const Center(child: Icon(Icons.location_on, size: 40, color: Color(0x551D4ED8))),
            ),
          ),
        ),
      );
      final body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visit Our Showroom',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _C.ink900)),
            const SizedBox(height: 14),
            Text(_location?.address ?? 'Dubai, United Arab Emirates',
                style: const TextStyle(fontSize: 14, height: 1.7, color: _C.ink600)),
            const SizedBox(height: 20),
            _lineBtn('Get Directions', solid: false, onTap: _openLocation),
          ],
        ),
      );
      return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _C.cardBorder),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: const Color(0xFF10254E).withOpacity(.05), blurRadius: 20, offset: const Offset(0, 6))]),
        clipBehavior: Clip.antiAlias,
        // FIX: stacked uses Column; wide uses Row with crossAxisAlignment: start (no stretch, no IntrinsicHeight)
        child: stacked
            ? Column(mainAxisSize: MainAxisSize.min, children: [mapWidget, body])
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 125, child: mapWidget),
            Expanded(flex: 100, child: body),
          ],
        ),
      );
    });
  }

  Widget _buildPartner() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFEAF2FF), Color(0xFFE0ECFB)]),
          border: Border.all(color: const Color(0xFFD7E4F8)),
          borderRadius: BorderRadius.circular(18)),
      child: Stack(children: [
        Positioned(
            right: -30, bottom: -30,
            child: Opacity(
                opacity: .5,
                child: Image.asset('assets/images/water-splash.png', width: 190,
                    errorBuilder: (_, __, ___) => const SizedBox()))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: const Color(0xFF10254E).withOpacity(.08), blurRadius: 18, offset: const Offset(0, 8))]),
                  child: const Icon(Icons.favorite_border, size: 28, color: _C.blue700)),
              const SizedBox(height: 16),
              const Text('Partner with PWT',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _C.ink900)),
              const SizedBox(height: 8),
              const SizedBox(
                width: 280,
                child: Text('Looking for a long-term water solution for your business?',
                    style: TextStyle(fontSize: 14, height: 1.55, color: _C.ink500)),
              ),
              const SizedBox(height: 20),
              _lineBtn('Get a Custom Quote', solid: true,
                  onTap: () => Navigator.of(context).pushNamed('/rfq')),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _lineBtn(String label, {required bool solid, required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
          color: solid ? Colors.white : Colors.transparent,
          border: Border.all(color: solid ? Colors.transparent : const Color(0xFFD8E2F1), width: 1.5),
          borderRadius: BorderRadius.circular(11),
          boxShadow: solid ? [BoxShadow(color: const Color(0xFF10254E).withOpacity(.08), blurRadius: 16, offset: const Offset(0, 6))] : null),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.blue700)),
        const SizedBox(width: 9),
        const Icon(Icons.arrow_forward, size: 16, color: _C.blue700),
      ]),
    ),
  );

  // =================== TRUST BAR ===================
  Widget _buildTrustBar() {
    final items = [
      [Icons.grid_view_rounded,      'Free Installation',  'On all orders'],
      [Icons.verified_user_outlined, 'Genuine Products',   '100% original & warranty'],
      [Icons.local_shipping_outlined,'Fast Delivery',      '3-5 business days'],
      [Icons.credit_card,            'Secure Payments',    '100% secure checkout'],
      [Icons.headset_mic_outlined,   'Expert Support',     'Always here to help'],
    ];
    Widget tile(IconData ic, String h, String p) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: _C.iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(ic, size: 22, color: _C.blue700)),
        const SizedBox(width: 14),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _C.ink900), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(p, style: const TextStyle(fontSize: 12.5, color: _C.ink500), overflow: TextOverflow.ellipsis),
        ])),
      ],
    );
    return LayoutBuilder(builder: (_, bc) {
      final tiles = items.map((it) => tile(it[0] as IconData, it[1] as String, it[2] as String)).toList();
      if (bc.maxWidth > 760) {
        final row = <Widget>[];
        for (var i = 0; i < tiles.length; i++) {
          row.add(Expanded(child: tiles[i]));
          if (i < tiles.length - 1) row.add(Container(width: 1, height: 44, color: _C.cardBorder));
        }
        return Padding(padding: const EdgeInsets.symmetric(vertical: 34), child: Row(children: row));
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Wrap(
            spacing: 20, runSpacing: 20, alignment: WrapAlignment.center,
            children: tiles.map((t) => SizedBox(width: 150, child: t)).toList()),
      );
    });
  }

  // =================== BOTTOM CTA ===================
  Widget _buildCta() {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth;
      final stacked = w < 760;
      final left = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 54, height: 54,
              decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.headset_mic_outlined, size: 26, color: Colors.white)),
          const SizedBox(width: 18),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Need immediate help?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Our team is ready to assist you right away.',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(.8))),
          ]),
        ],
      );
      final waBtn = Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(.5), width: 1.6),
            borderRadius: BorderRadius.circular(12)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline, size: 20, color: Colors.white),
          SizedBox(width: 10),
          Text('Contact Us on WhatsApp',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
      );
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0F2766), Color(0xFF16358A), Color(0xFF1A3F9E)]),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w < 760 ? 20 : 40, vertical: 30),
              child: stacked
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                  children: [left, const SizedBox(height: 18), waBtn])
                  : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Flexible(child: left), const SizedBox(width: 24), waBtn]),
            ),
          ),
        ),
      );
    });
  }
}

// =================== BAND HELPER ===================
class _Band extends StatelessWidget {
  final Widget child;
  final double top, bottom;
  const _Band({required this.child, required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 760;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(narrow ? 20 : 40, top, narrow ? 20 : 40, bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: child,
        ),
      ),
    );
  }
}

// =================== MAP PAINTER ===================
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEEF3FA));
    final line = Paint()..color = const Color(0xFFE8EEF7)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 22) canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    for (double x = 0; x < size.width; x += 26) canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

String _contactFlagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}

const _kContactWaSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
</svg>
''';
