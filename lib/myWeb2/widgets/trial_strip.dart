// Animated "7 days free" trial strip. Ported from myApp's <TrialStrip>
// (lib/myApp/widgets/trial_strip.dart): entry rise + spring-popped "7"
// badge, a pulsing ring, and a light sweep that crosses the card on a loop.
// Honours the platform reduce-motion setting.

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/app_theme.dart';

class TrialStrip extends StatefulWidget {
  const TrialStrip({super.key, this.delay = const Duration(milliseconds: 90)});

  /// Stagger the entry so the strip lands after the heading above it.
  final Duration delay;

  @override
  State<TrialStrip> createState() => _TrialStripState();
}

class _TrialStripState extends State<TrialStrip> with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));

  late final Animation<double> _rise = CurvedAnimation(parent: _enter, curve: const Cubic(.16, 1, .3, 1));
  late final Animation<double> _pop = CurvedAnimation(
    parent: _enter,
    curve: const Interval(.23, 1, curve: Cubic(.34, 1.56, .64, 1)),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _enter.forward();
      _loop.repeat();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _enter.value = 1;
      if (_loop.isAnimating) _loop.stop();
    }

    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final v = _rise.value;
        return Opacity(
          opacity: v.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - v)),
            child: Transform.scale(scale: .985 + .015 * v, child: child),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.blue200),
            boxShadow: AppShadow.card,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1F1D4ED8), Colors.white],
              stops: [0, .7],
            ),
          ),
          child: Stack(
            children: [
              // Light sweep
              if (!reduceMotion)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _loop,
                      builder: (context, _) {
                        // Travel -140% → 240% over the first 55% of the loop, then rest.
                        final p = (_loop.value / .55).clamp(0.0, 1.0);
                        return FractionalTranslation(
                          translation: Offset(-1.4 + 3.8 * Curves.easeInOut.transform(p), 0),
                          child: FractionallySizedBox(
                            widthFactor: .38,
                            alignment: Alignment.centerLeft,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0x00FFFFFF), Color(0xBFFFFFFF), Color(0x00FFFFFF)],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SevenBadge(pop: _pop, loop: _loop, reduceMotion: reduceMotion),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '7 days free, on us',
                            style: AppText.label.copyWith(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink900, letterSpacing: -.25),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Try any device for a week — cancel anytime, no charge.',
                            style: AppText.muted.copyWith(fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SevenBadge extends StatelessWidget {
  const _SevenBadge({required this.pop, required this.loop, required this.reduceMotion});
  final Animation<double> pop;
  final AnimationController loop;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing ring: scale .9 → 1.45 while fading out, every 2.4s.
          if (!reduceMotion)
            AnimatedBuilder(
              animation: loop,
              builder: (context, _) {
                final p = Curves.easeOut.transform(((loop.value * 1.5) % 1.0));
                return Transform.scale(
                  scale: .9 + .55 * p,
                  child: Opacity(
                    opacity: (.55 * (1 - p)).clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.blue700, width: 1.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          AnimatedBuilder(
            animation: pop,
            builder: (context, child) => Transform.scale(scale: .4 + .6 * pop.value, child: Opacity(opacity: pop.value.clamp(0, 1), child: child)),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.blue700, borderRadius: BorderRadius.circular(13)),
              child: const Text(
                '7',
                textDirection: TextDirection.ltr,
                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
