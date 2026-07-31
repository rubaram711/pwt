// Welcome / splash with auto-rotating product carousel. Ported from
// proto/welcome.jsx.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/asset_resolver.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onContinue, required this.onSignUp, required this.onGuest});
  final VoidCallback onContinue;
  final VoidCallback onSignUp;
  final VoidCallback onGuest;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final List<Product> _slides;
  int _idx = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _slides = MockData.products.where((p) => !p.quoteOnly).toList();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _idx = (_idx + 1) % _slides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final isAr = app.isArabic;
    final active = _slides[_idx];

    return Scaffold(
      backgroundColor: PwtColors.bg,
      body: Stack(
        children: [
          // brand backdrop
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.0,
                  colors: [PwtColors.brand.withValues(alpha: 0.18), PwtColors.brand.withValues(alpha: 0)],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/full_logo_2.png', height: 50, fit: BoxFit.contain),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // hero carousel
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          width: 360,
                          height: 360,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [active.tint.withValues(alpha: 0.22), active.tint.withValues(alpha: 0)],
                              stops: const [0, 0.7],
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(anim), child: child),
                          ),
                          child: Image(
                            key: ValueKey(active.id),
                            image: pwtImage(active.img),
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(top: 26, left: 0, child: _FloatTag(color: PwtColors.brand, icon: PwtIcons.drop, label: isAr ? 'تعبئة فورية' : 'Instant fill')),
                        Positioned(top: 90, right: 0, child: _FloatTag(color: PwtColors.teal, icon: PwtIcons.bolt, label: isAr ? 'مياه غازية' : 'Sparkling')),
                        Positioned(bottom: 24, left: 8, child: _FloatTag(color: PwtColors.warning, icon: PwtIcons.wrench, label: isAr ? 'صيانة مجانية' : 'Service incl.')),
                      ],
                    ),
                  ),
                  // label
                  Column(
                    children: [
                      Text(active.cat.toUpperCase(), style: PwtType.eyebrow(color: active.tint).copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(active.name, style: PwtType.subtitle().copyWith(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _slides.length; i++)
                        GestureDetector(
                          onTap: () => setState(() => _idx = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _idx ? 24 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _idx ? PwtColors.brand : PwtColors.hairline2,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // headline
                  Text(
                    s['welcomeTitle']!,
                    textAlign: TextAlign.center,
                    style: PwtType.headline(arabic: isAr).copyWith(fontSize: 30, height: 1.12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s['welcomeSub']!,
                    textAlign: TextAlign.center,
                    style: PwtType.body(color: PwtColors.textSec, arabic: isAr).copyWith(fontSize: 13.5, height: 1.55),
                  ),
                  const SizedBox(height: 22),
                  PwtButton(label: s['getStarted']!, full: true, trailing: PwtIcons.arrow, onPressed: widget.onContinue),
                  const SizedBox(height: 10),
                  PwtButton(label: s['createAccount']!, variant: PwtButtonVariant.ghost, full: true, onPressed: widget.onSignUp),
                  const SizedBox(height: 10),
                  PwtButton(label: s['continueAsGuest']!, variant: PwtButtonVariant.ghost, full: true, onPressed: widget.onGuest),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatTag extends StatelessWidget {
  const _FloatTag({required this.color, required this.icon, required this.label});
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: PwtColors.hairline),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x140F172A), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.13), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 6),
          Text(label, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
